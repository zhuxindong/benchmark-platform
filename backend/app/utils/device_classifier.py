# -*- coding: utf-8 -*-
"""
CPU设备类型识别工具
根据CPU型号识别服务器级或消费级处理器
"""

import re
from typing import Optional, Tuple


class DeviceTypeClassifier:
    """设备类型分类器"""

    # 服务器级CPU关键词
    SERVER_CPU_KEYWORDS = [
        # Intel Xeon系列
        'Xeon', 'Xeon®', 'Xeon(TM)',
        # AMD EPYC系列
        'EPYC', 'EPYC™', 'EPYC(R)', 'AMD EPYC',
        # AMD Opteron系列
        'Opteron', 'Opteron™', 'Opteron(R)',
        # ARM服务器系列
        'Cavium', 'ThunderX', 'Ampere', 'Altra',
        # IBM Power系列
        'POWER', 'Power', 'power',
        # Intel Itanium
        'Itanium', 'Itanium®',
        # 其他服务器标识
        'Server', 'Workstation', 'WS',
    ]

    # 消费级CPU关键词
    CONSUMER_CPU_KEYWORDS = [
        # Intel Core系列
        'Core i3', 'Core i5', 'Core i7', 'Core i9',
        'Intel Core', 'Core(TM)', 'Core(R)',
        'i3-', 'i5-', 'i7-', 'i9-',
        # AMD Ryzen系列
        'Ryzen 3', 'Ryzen 5', 'Ryzen 7', 'Ryzen 9',
        'AMD Ryzen', 'Ryzen(TM)', 'Ryzen(R)',
        # AMD FX/Athon系列
        'FX-', 'Athlon', 'Sempron',
        # Intel Pentium/Celeron
        'Pentium', 'Celeron',
        # Apple Silicon
        'Apple M1', 'Apple M2', 'Apple M3', 'Apple M4',
        'M1', 'M2', 'M3', 'M4',
        # 移动端处理器
        'Snapdragon', 'MediaTek', 'Exynos',
        'Intel(R) Core(TM) m', 'Intel(R) Pentium(R) Silver',
        # 其他消费级标识
        'Desktop', 'Laptop', 'Mobile',
    ]

    @classmethod
    def classify_cpu(cls, cpu_model: Optional[str]) -> Tuple[str, float]:
        """
        根据CPU型号分类设备类型

        Args:
            cpu_model: CPU型号字符串

        Returns:
            Tuple[str, float]: (设备类型, 置信度)
            设备类型: 'server', 'consumer', 'unknown'
            置信度: 0.0-1.0
        """
        if not cpu_model:
            return 'unknown', 0.0

        cpu_model_lower = cpu_model.lower()
        cpu_model_original = cpu_model

        # 服务器级CPU匹配
        server_score = 0.0
        for keyword in cls.SERVER_CPU_KEYWORDS:
            if keyword.lower() in cpu_model_lower:
                # 特殊处理一些高置信度的关键词
                if keyword in ['Xeon', 'EPYC', 'POWER']:
                    server_score = max(server_score, 0.95)
                elif 'eon' in cpu_model_lower or 'epyc' in cpu_model_lower:
                    server_score = max(server_score, 0.9)
                else:
                    server_score = max(server_score, 0.8)

        # 消费级CPU匹配
        consumer_score = 0.0
        for keyword in cls.CONSUMER_CPU_KEYWORDS:
            if keyword.lower() in cpu_model_lower:
                # 特殊处理一些高置信度的关键词
                if keyword in ['Core i3', 'Core i5', 'Core i7', 'Core i9',
                             'Ryzen 3', 'Ryzen 5', 'Ryzen 7', 'Ryzen 9']:
                    consumer_score = max(consumer_score, 0.95)
                elif 'core i' in cpu_model_lower or 'ryzen' in cpu_model_lower:
                    consumer_score = max(consumer_score, 0.9)
                else:
                    consumer_score = max(consumer_score, 0.7)

        # 特殊模式匹配
        # Intel Xeon Gold/Silver/Bronze等
        xeon_pattern = r'xeon\s+(?:gold|silver|bronze|platinum|w-\d+|d-\d+)'
        if re.search(xeon_pattern, cpu_model_lower):
            server_score = max(server_score, 0.98)

        # AMD EPYC 7000/9000系列
        epyc_pattern = r'epyc\s+\d+[a-z]*'
        if re.search(epyc_pattern, cpu_model_lower):
            server_score = max(server_score, 0.98)

        # Intel Core 移动版识别
        mobile_pattern = r'core\s+.*[uHQMK]$"'
        if re.search(mobile_pattern, cpu_model_lower):
            consumer_score = max(consumer_score, 0.9)

        # 判断结果
        if server_score > consumer_score:
            if server_score >= 0.7:
                return 'server', server_score
        elif consumer_score > server_score:
            if consumer_score >= 0.7:
                return 'consumer', consumer_score

        # 低置信度时的启发式判断
        # 如果包含服务器相关术语但置信度低
        if any(term in cpu_model_lower for term in ['server', 'workstation', 'ws']) and server_score > 0.3:
            return 'server', max(server_score, 0.6)

        # 如果包含消费级相关术语但置信度低
        if any(term in cpu_model_lower for term in ['desktop', 'laptop', 'mobile']) and consumer_score > 0.3:
            return 'consumer', max(consumer_score, 0.6)

        return 'unknown', 0.0

    @classmethod
    def get_device_type_label(cls, device_type: str) -> str:
        """获取设备类型的中文标签"""
        labels = {
            'server': '服务器级',
            'consumer': '消费级',
            'unknown': '未知'
        }
        return labels.get(device_type, '未知')

    @classmethod
    def is_confident_classification(cls, cpu_model: Optional[str], confidence_threshold: float = 0.7) -> Tuple[str, bool]:
        """
        判断是否为高置信度分类

        Args:
            cpu_model: CPU型号
            confidence_threshold: 置信度阈值

        Returns:
            Tuple[str, bool]: (设备类型, 是否高置信度)
        """
        device_type, confidence = cls.classify_cpu(cpu_model)
        is_confident = confidence >= confidence_threshold
        return device_type, is_confident


# 便捷函数
def classify_device_type(cpu_model: Optional[str]) -> str:
    """
    便捷函数：获取设备类型（不考虑置信度）

    Args:
        cpu_model: CPU型号

    Returns:
        str: 设备类型 ('server', 'consumer', 'unknown')
    """
    device_type, _ = DeviceTypeClassifier.classify_cpu(cpu_model)
    return device_type


def get_device_type_with_confidence(cpu_model: Optional[str]) -> Tuple[str, float]:
    """
    便捷函数：获取设备类型和置信度

    Args:
        cpu_model: CPU型号

    Returns:
        Tuple[str, float]: (设备类型, 置信度)
    """
    return DeviceTypeClassifier.classify_cpu(cpu_model)


if __name__ == "__main__":
    # 测试代码
    test_cpus = [
        "Intel Xeon E5-2670 v3",
        "Intel Xeon Gold 6248R",
        "AMD EPYC 7742",
        "Intel Core i7-9700K",
        "AMD Ryzen 9 5900X",
        "Apple M2 Pro",
        "Intel Pentium Silver J5040",
        "Unknown CPU Model",
        None,
        "Intel Xeon W-2295",
        "AMD EPYC 9654",
        "Intel Core i7-12700H",  # 移动版
    ]

    print("CPU设备类型分类测试:")
    print("-" * 60)
    for cpu in test_cpus:
        device_type, confidence = get_device_type_with_confidence(cpu)
        label = DeviceTypeClassifier.get_device_type_label(device_type)
        cpu_display = cpu if cpu else "None"
        print(f"{cpu_display:<40} -> {label} (置信度: {confidence:.2f})")