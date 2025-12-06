# 数据库结构升级和数据迁移指南

## 概述

本指南详细说明如何将现有的基准测试平台数据库平滑升级到支持设备类型分类和用户记录限制的新版本。

## 🎯 升级内容

### 新增字段
- `device_type`: 设备类型 (server/consumer/unknown)
- `device_type_confidence`: 设备类型识别置信度 (0.00-1.00)
- `device_type_manually_corrected`: 是否被用户手动修正

### 新增配置
- `max_results_per_user`: 每个用户最多提交3条记录 (从10改为3)
- `enable_device_classification`: 启用设备类型自动分类
- `device_type_confidence_threshold`: 设备类型自动分类的置信度阈值

## 📋 迁移步骤

### 1. 备份数据库 (最重要！)

```sql
-- 创建数据库备份
mysqldump -u root -p benchmark > benchmark_backup_$(date +%Y%m%d_%H%M%S).sql

-- 或者使用命令行
mysqldump -h127.0.0.1 -P3306 -uroot -p benchmark > benchmark_backup.sql
```

### 2. 检查现有数据

```sql
-- 查看现有的基准测试结果数量
SELECT COUNT(*) as total_records FROM benchmark_results;

-- 查看现有的CPU型号分布
SELECT cpu_model, COUNT(*) as count
FROM benchmark_results
WHERE cpu_model IS NOT NULL
GROUP BY cpu_model
ORDER BY count DESC;

-- 查看已验证的记录数量
SELECT COUNT(*) as verified_records
FROM benchmark_results
WHERE is_verified = TRUE;

-- 查看用户提交统计
SELECT user_id, username, COUNT(*) as submission_count
FROM benchmark_results
GROUP BY user_id, username
ORDER BY submission_count DESC;
```

### 3. 执行结构迁移

运行数据库迁移脚本：

```sql
-- 执行迁移脚本
SOURCE database_migration.sql;
```

### 4. 验证迁移结果

```sql
-- 检查新字段是否添加成功
DESCRIBE benchmark_results;

-- 查看设备类型分类结果
SELECT
    device_type,
    COUNT(*) as count,
    AVG(device_type_confidence) as avg_confidence
FROM benchmark_results
GROUP BY device_type;

-- 查看具体的分类结果示例
SELECT
    cpu_model,
    device_type,
    device_type_confidence,
    device_type_manually_corrected
FROM benchmark_results
WHERE cpu_model IS NOT NULL
ORDER BY device_type_confidence DESC
LIMIT 10;

-- 检查用户记录限制配置
SELECT * FROM system_config WHERE config_key = 'max_results_per_user';
```

### 5. 处理分类不准确的数据

```sql
-- 查看低置信度的分类（可能需要手动修正）
SELECT
    id,
    cpu_model,
    device_type,
    device_type_confidence
FROM benchmark_results
WHERE device_type_confidence < 0.7
AND cpu_model IS NOT NULL
ORDER BY device_type_confidence ASC;

-- 手动修正特定记录的设备类型
UPDATE benchmark_results
SET device_type = 'server',
    device_type_confidence = 1.0,
    device_type_manually_corrected = TRUE,
    updated_at = NOW()
WHERE id = [specific_id];
```

## 🔄 回滚方案

如果迁移出现问题，可以按以下步骤回滚：

### 1. 停止应用服务
```bash
# 停止FastAPI服务
# 停止前端服务
```

### 2. 恢复数据库
```sql
-- 删除当前数据库
DROP DATABASE benchmark;

-- 重新创建数据库
CREATE DATABASE benchmark DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;

-- 恢复备份
SOURCE benchmark_backup.sql;
```

### 3. 重新启动服务
```bash
# 重新启动后端服务
# 重新启动前端服务
```

## ⚠️ 注意事项

### 数据安全
1. **务必在生产环境迁移前备份数据库**
2. 建议在测试环境先进行迁移测试
3. 迁移过程中避免用户提交新的数据

### 性能考虑
1. 大数据量迁移时，建议分批执行CPU类型分类更新
2. 在低峰期执行迁移操作
3. 迁移脚本中的分类更新可能会较慢，建议根据数据量调整

### 业务影响
1. 迁移后用户记录限制从10条改为3条
2. 现有用户如果已有超过3条已验证记录，可以保留但无法再提交新记录
3. 设备类型分类会立即生效，影响排行榜显示

## 🧪 测试建议

### 1. 功能测试
- 测试排行榜的设备类型过滤功能
- 测试用户提交限制是否生效
- 测试设备类型修正功能

### 2. 数据验证
- 验证设备类型分类的准确性
- 验证现有用户数据是否完整
- 验证排行榜排名是否正确

### 3. 性能测试
- 测试排行榜查询性能
- 测试分类过滤的性能
- 测试大量数据的处理能力

## 📞 支持联系

如果在迁移过程中遇到问题，请：
1. 立即停止迁移操作
2. 保留错误日志
3. 联系技术支持团队
4. 必要时使用回滚方案