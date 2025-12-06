# -*- coding: utf-8 -*-
"""
基准测试结果业务逻辑服务
"""

from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from typing import List, Optional, Tuple
from datetime import datetime, timedelta, timezone
import re

from app.models.benchmark import BenchmarkResult, DeviceType
from app.models.user import User
from app.schemas.benchmark import BenchmarkResultCreate, BenchmarkResultUpdate
from app.utils.device_classifier import get_device_type_with_confidence


class BenchmarkService:
    """基准测试结果服务"""

    def __init__(self, db: Session):
        self.db = db
        self.max_results_per_user = 3  # 每个用户最多提交3条记录

    def parse_benchmark_text(self, text: str) -> dict:
        """解析基准测试结果文本"""
        try:
            result = {
                'cpu_model': '',
                'cpu_cores': None,
                'memory_gb': None,
                'phase1_wall_time': None,
                'phase2_wall_time': None,
                'overall_wall_time': None
            }

            # 解析系统信息
            cpu_match = re.search(r'CPU\s*[:\s]\s*(.+?)(?:\n|$)', text, re.IGNORECASE)
            cores_match = re.search(r'(?:Cores|cores?|Cores?_logical)\s*[:\s]\s*(\d+)', text, re.IGNORECASE)
            memory_match = re.search(r'Memory\s*[:\s]\s*([\d.]+)\s*(?:GB|gb|GiB|gib)', text, re.IGNORECASE)

            if cpu_match:
                result['cpu_model'] = cpu_match.group(1).strip()
            if cores_match:
                result['cpu_cores'] = int(cores_match.group(1))
            if memory_match:
                result['memory_gb'] = float(memory_match.group(1))

            # 解析 Phase 1
            phase1_patterns = [
                r'\[Phase\s*1\][\s\S]*?wall_time\s*[:\s]\s*([\d.]+)\s*s',
                r'\[Phase\s*1\][\s\S]*?finished\s+in\s+([\d.]+)\s*s',
                r'Phase\s*1[\s\S]*?([\d.]+)\s*s'
            ]

            for pattern in phase1_patterns:
                match = re.search(pattern, text, re.IGNORECASE)
                if match:
                    result['phase1_wall_time'] = float(match.group(1))
                    break

            # 解析 Phase 2
            phase2_patterns = [
                r'\[Phase\s*2\][\s\S]*?wall_time\s*[:\s]\s*([\d.]+)\s*s',
                r'\[Phase\s*2\][\s\S]*?finished\s+in\s+([\d.]+)\s*s',
                r'Phase\s*2[\s\S]*?([\d.]+)\s*s'
            ]

            for pattern in phase2_patterns:
                match = re.search(pattern, text, re.IGNORECASE)
                if match:
                    result['phase2_wall_time'] = float(match.group(1))
                    break

            # 解析总体时间
            total_patterns = [
                r'\[Overall\][\s\S]*?wall_time\s*[:\s]\s*([\d.]+)\s*s',
                r'\[Overall\][\s\S]*?total\s+wall_time:\s*([\d.]+)\s*s',
                r'overall[\s\S]*?([\d.]+)\s*s',
                r'total[\s\S]*?wall_time:\s*([\d.]+)\s*s'
            ]

            for pattern in total_patterns:
                match = re.search(pattern, text, re.IGNORECASE)
                if match:
                    result['overall_wall_time'] = float(match.group(1))
                    break

            return result
        except Exception:
            return {}

    def calculate_performance_score(self, overall_time: float) -> float:
        """计算性能分数（时间越短分数越高）"""
        if not overall_time:
            return None
        # 使用基准时间（例如100秒）来计算相对分数
        baseline_time = 100.0
        return round(baseline_time / overall_time * 1000, 2)

    def calculate_throughput(self, phase1_time: float, key_bits: int = 28) -> Optional[int]:
        """计算吞吐量（密钥/秒）"""
        if not phase1_time:
            return None
        key_space = 2 ** key_bits
        return int(key_space / phase1_time)

    def check_user_submission_limit(self, user_id: int) -> Tuple[bool, int]:
        """
        检查用户是否还能提交新的基准测试结果

        Args:
            user_id: 用户ID

        Returns:
            Tuple[bool, int]: (是否可以提交, 当前已提交的验证记录数)
        """
        # 统计用户已提交的已验证记录数
        verified_count = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.user_id == user_id,
            BenchmarkResult.is_verified == True
        ).count()

        can_submit = verified_count < self.max_results_per_user
        return can_submit, verified_count

    def create_benchmark_result(
        self,
        user_id: int,
        username: str,
        benchmark_data: BenchmarkResultCreate,
        ip_address: str = None,
        user_agent: str = None,
        raw_text: str = None
    ) -> BenchmarkResult:
        """创建基准测试结果"""

        # 检查用户提交次数限制（只统计已验证的记录）
        can_submit, verified_count = self.check_user_submission_limit(user_id)
        if not can_submit:
            raise ValueError(f"每个用户最多只能提交 {self.max_results_per_user} 条已验证的基准测试结果，当前已提交 {verified_count} 条")

        # 检查未验证的记录数，如果超过限制，删除最旧的未验证记录
        unverified_count = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.user_id == user_id,
            BenchmarkResult.is_verified == False
        ).count()

        max_unverified = self.max_results_per_user - verified_count
        if unverified_count >= max_unverified and max_unverified > 0:
            # 删除最旧的未验证记录
            oldest_unverified = self.db.query(BenchmarkResult).filter(
                BenchmarkResult.user_id == user_id,
                BenchmarkResult.is_verified == False
            ).order_by(BenchmarkResult.submitted_at).first()
            if oldest_unverified:
                self.db.delete(oldest_unverified)

        # 创建新结果
        db_result = BenchmarkResult(
            user_id=user_id,
            username=username,
            cpu_model=benchmark_data.cpu_model,
            cpu_cores=benchmark_data.cpu_cores,
            memory_gb=benchmark_data.memory_gb,
            phase1_wall_time=benchmark_data.phase1_wall_time,
            phase2_wall_time=benchmark_data.phase2_wall_time,
            overall_wall_time=benchmark_data.overall_wall_time,
            raw_result_text=raw_text,
            ip_address=ip_address,
            user_agent=user_agent,
            is_verified=True,  # 暂时自动验证
            submitted_at=datetime.now(timezone.utc)
        )

        # 自动分类设备类型
        if db_result.cpu_model:
            device_type_str, confidence = get_device_type_with_confidence(db_result.cpu_model)
            if device_type_str == 'server':
                db_result.device_type = DeviceType.SERVER
            elif device_type_str == 'consumer':
                db_result.device_type = DeviceType.CONSUMER
            else:
                db_result.device_type = DeviceType.UNKNOWN
            db_result.device_type_confidence = confidence

        # 计算性能指标
        if db_result.overall_wall_time:
            db_result.performance_score = self.calculate_performance_score(float(db_result.overall_wall_time))

        if db_result.phase1_wall_time:
            db_result.throughput_keys_per_sec = self.calculate_throughput(float(db_result.phase1_wall_time))

        self.db.add(db_result)
        self.db.commit()
        self.db.refresh(db_result)

        return db_result

    def get_user_results(
        self,
        user_id: int,
        page: int = 1,
        limit: int = 20
    ) -> Tuple[List[BenchmarkResult], int]:
        """获取用户的基准测试结果"""
        offset = (page - 1) * limit

        query = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.user_id == user_id
        ).order_by(desc(BenchmarkResult.submitted_at))

        total = query.count()
        results = query.offset(offset).limit(limit).all()

        return results, total

    def get_result_by_id(self, result_id: int) -> Optional[BenchmarkResult]:
        """根据ID获取基准测试结果"""
        return self.db.query(BenchmarkResult).filter(
            BenchmarkResult.id == result_id
        ).first()

    def update_result(
        self,
        result_id: int,
        user_id: int,
        update_data: BenchmarkResultUpdate
    ) -> Optional[BenchmarkResult]:
        """更新基准测试结果"""
        result = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.id == result_id,
            BenchmarkResult.user_id == user_id
        ).first()

        if not result:
            return None

        # 更新字段
        update_dict = update_data.dict(exclude_unset=True)
        for field, value in update_dict.items():
            setattr(result, field, value)

        result.updated_at = datetime.now(timezone.utc)

        # 重新计算性能分数
        if result.overall_wall_time:
            result.performance_score = self.calculate_performance_score(float(result.overall_wall_time))

        self.db.commit()
        self.db.refresh(result)

        return result

    def delete_result(self, result_id: int, user_id: int) -> bool:
        """删除基准测试结果"""
        result = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.id == result_id,
            BenchmarkResult.user_id == user_id
        ).first()

        if not result:
            return False

        self.db.delete(result)
        self.db.commit()
        return True

    def get_leaderboard(
        self,
        device_type: Optional[str] = None,
        page: int = 1,
        limit: int = 50
    ) -> Tuple[List[dict], int]:
        """
        获取排行榜

        Args:
            device_type: 设备类型过滤 ('server', 'consumer', None表示全部)
            page: 页码
            limit: 每页数量

        Returns:
            Tuple[List[dict], int]: (排行榜数据, 总数)
        """
        offset = (page - 1) * limit

        # 基础查询：获取每个用户的最佳成绩
        subquery = self.db.query(
            BenchmarkResult.user_id,
            func.min(BenchmarkResult.overall_wall_time).label('best_time')
        ).filter(
            BenchmarkResult.is_verified == True,
            BenchmarkResult.overall_wall_time.isnot(None)
        )

        # 添加设备类型过滤
        if device_type:
            if device_type == 'server':
                subquery = subquery.filter(BenchmarkResult.device_type == DeviceType.SERVER)
            elif device_type == 'consumer':
                subquery = subquery.filter(BenchmarkResult.device_type == DeviceType.CONSUMER)

        subquery = subquery.group_by(BenchmarkResult.user_id).subquery()

        # 主查询
        query = self.db.query(BenchmarkResult).join(
            subquery,
            (BenchmarkResult.user_id == subquery.c.user_id) &
            (BenchmarkResult.overall_wall_time == subquery.c.best_time)
        ).filter(BenchmarkResult.is_verified == True)

        # 添加设备类型过滤到主查询
        if device_type:
            if device_type == 'server':
                query = query.filter(BenchmarkResult.device_type == DeviceType.SERVER)
            elif device_type == 'consumer':
                query = query.filter(BenchmarkResult.device_type == DeviceType.CONSUMER)

        query = query.order_by(BenchmarkResult.overall_wall_time.asc(), BenchmarkResult.submitted_at.asc())

        total = query.count()
        results = query.offset(offset).limit(limit).all()

        # 格式化结果
        leaderboard_data = []
        for idx, result in enumerate(results, start=offset + 1):
            leaderboard_data.append({
                'rank': idx,
                'user_id': result.user_id,
                'username': result.username,
                'cpu_model': result.cpu_model,
                'cpu_cores': result.cpu_cores,
                'memory_gb': float(result.memory_gb) if result.memory_gb else None,
                'device_type': result.device_type.value,
                'device_type_label': result.device_type_label,
                'device_type_confidence': float(result.device_type_confidence) if result.device_type_confidence else 0.0,
                'overall_wall_time': float(result.overall_wall_time) if result.overall_wall_time else None,
                'phase1_wall_time': float(result.phase1_wall_time) if result.phase1_wall_time else None,
                'phase2_wall_time': float(result.phase2_wall_time) if result.phase2_wall_time else None,
                'performance_score': float(result.performance_score) if result.performance_score else None,
                'throughput_keys_per_sec': result.throughput_keys_per_sec,
                'submitted_at': result.submitted_at.isoformat() if result.submitted_at else None
            })

        return leaderboard_data, total

    def update_device_type(
        self,
        result_id: int,
        user_id: int,
        new_device_type: str
    ) -> Optional[BenchmarkResult]:
        """
        更新设备类型（仅允许用户修正自己的记录）

        Args:
            result_id: 基准测试结果ID
            user_id: 用户ID
            new_device_type: 新的设备类型 ('server', 'consumer', 'unknown')

        Returns:
            Optional[BenchmarkResult]: 更新后的结果
        """
        result = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.id == result_id,
            BenchmarkResult.user_id == user_id
        ).first()

        if not result:
            return None

        # 检查是否允许修正
        if not result.can_be_corrected_by_user():
            raise ValueError("该结果的设备类型置信度过高，不允许手动修正")

        # 更新设备类型
        if new_device_type == 'server':
            result.device_type = DeviceType.SERVER
        elif new_device_type == 'consumer':
            result.device_type = DeviceType.CONSUMER
        elif new_device_type == 'unknown':
            result.device_type = DeviceType.UNKNOWN
        else:
            raise ValueError("无效的设备类型")

        result.device_type_manually_corrected = True
        result.device_type_confidence = 1.0  # 手动修正后置信度设为最高
        result.updated_at = datetime.now(timezone.utc)

        self.db.commit()
        self.db.refresh(result)

        return result

    def get_statistics(self) -> dict:
        """获取基准测试统计信息"""
        total_results = self.db.query(BenchmarkResult).count()
        verified_results = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.is_verified == True
        ).count()

        # 按设备类型统计
        server_count = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.is_verified == True,
            BenchmarkResult.device_type == DeviceType.SERVER
        ).count()

        consumer_count = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.is_verified == True,
            BenchmarkResult.device_type == DeviceType.CONSUMER
        ).count()

        unknown_count = self.db.query(BenchmarkResult).filter(
            BenchmarkResult.is_verified == True,
            BenchmarkResult.device_type == DeviceType.UNKNOWN
        ).count()

        # 今日提交
        today = datetime.now(timezone.utc).date()
        today_results = self.db.query(BenchmarkResult).filter(
            func.date(BenchmarkResult.submitted_at) == today
        ).count()

        # 平均完成时间
        avg_time = self.db.query(func.avg(BenchmarkResult.overall_wall_time)).filter(
            BenchmarkResult.is_verified == True,
            BenchmarkResult.overall_wall_time.isnot(None)
        ).scalar()

        # 最佳时间
        best_time = self.db.query(func.min(BenchmarkResult.overall_wall_time)).filter(
            BenchmarkResult.is_verified == True,
            BenchmarkResult.overall_wall_time.isnot(None)
        ).scalar()

        return {
            'total_results': total_results,
            'verified_results': verified_results,
            'server_results': server_count,
            'consumer_results': consumer_count,
            'unknown_results': unknown_count,
            'today_results': today_results,
            'avg_completion_time': float(avg_time) if avg_time else None,
            'best_completion_time': float(best_time) if best_time else None
        }