# 数据库设计文档

## 数据库连接信息
- **主机**: 127.0.0.1:3306
- **用户名**: root
- **密码**: root
- **数据库名**: benchmark

## 表结构设计

### 1. users 表 - 用户信息
用于存储通过 linux.do 认证的用户信息。

```sql
CREATE TABLE `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,        -- 用户ID（主键）
    `username` VARCHAR(100) NOT NULL,                     -- linux.do 用户名（唯一）
    `user_id` VARCHAR(100) NOT NULL,                      -- linux.do 用户ID（唯一）
    `email` VARCHAR(255) DEFAULT NULL,                    -- 邮箱地址
    `avatar_url` VARCHAR(500) DEFAULT NULL,               -- 头像URL
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- 创建时间
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  -- 更新时间
);
```

### 2. benchmark_results 表 - 基准测试结果
核心表，存储用户提交的所有基准测试结果。

```sql
CREATE TABLE `benchmark_results` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,         -- 结果ID（主键）
    `user_id` BIGINT UNSIGNED NOT NULL,                   -- 用户ID（外键）
    `username` VARCHAR(100) NOT NULL,                     -- 冗余用户名字段

    -- 系统信息
    `cpu_model` VARCHAR(255) DEFAULT NULL,                -- CPU型号
    `cpu_cores` INT DEFAULT NULL,                         -- 逻辑核心数
    `memory_gb` DECIMAL(10,2) DEFAULT NULL,               -- 内存大小(GB)

    -- 性能数据
    `phase1_wall_time` DECIMAL(15,6) DEFAULT NULL,        -- Phase 1 耗时(秒)
    `phase2_wall_time` DECIMAL(15,6) DEFAULT NULL,        -- Phase 2 耗时(秒)
    `overall_wall_time` DECIMAL(15,6) DEFAULT NULL,       -- 总耗时(秒)

    -- 计算得出的性能指标
    `throughput_keys_per_sec` BIGINT DEFAULT NULL,        -- Phase 1 吞吐量(密钥/秒)
    `performance_score` DECIMAL(15,6) DEFAULT NULL,       -- 综合性能分数

    -- 元数据
    `raw_result_text` TEXT DEFAULT NULL,                  -- 原始基准测试结果文本
    `ip_address` VARCHAR(45) DEFAULT NULL,                -- 提交者IP地址
    `user_agent` TEXT DEFAULT NULL,                       -- 用户代理字符串
    `submission_source` VARCHAR(50) DEFAULT 'web',        -- 提交来源: web, api, cli
    `is_verified` BOOLEAN DEFAULT FALSE,                  -- 是否已验证通过
    `notes` TEXT DEFAULT NULL,                            -- 备注信息

    -- 时间戳
    `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- 提交时间
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 3. leaderboard_snapshots 表 - 排行榜快照
定期生成的排行榜快照，提高查询性能。

```sql
CREATE TABLE `leaderboard_snapshots` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `snapshot_date` DATE NOT NULL,                        -- 快照日期
    `rank_position` INT UNSIGNED NOT NULL,                -- 排名位置
    `user_id` BIGINT UNSIGNED NOT NULL,                   -- 用户ID
    `username` VARCHAR(100) NOT NULL,                     -- 用户名
    `benchmark_result_id` BIGINT UNSIGNED NOT NULL,       -- 基准测试结果ID
    `overall_wall_time` DECIMAL(15,6) NOT NULL,           -- 总耗时(秒)
    `performance_score` DECIMAL(15,6) NOT NULL,           -- 性能分数
    `cpu_model` VARCHAR(255) DEFAULT NULL,                -- CPU型号
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. system_config 表 - 系统配置
存储系统配置信息，便于运维管理。

```sql
CREATE TABLE `system_config` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `config_key` VARCHAR(100) NOT NULL,                   -- 配置键
    `config_value` TEXT DEFAULT NULL,                     -- 配置值
    `config_type` VARCHAR(20) DEFAULT 'string',           -- 配置类型: string, number, boolean, json
    `description` VARCHAR(255) DEFAULT NULL,              -- 配置描述
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 视图设计

### 1. v_user_best_results 视图 - 用户最佳成绩
每个用户的最快成绩（时间最短）。

```sql
CREATE VIEW `v_user_best_results` AS
SELECT
    u.id as user_id,
    u.username,
    u.avatar_url,
    br.id as result_id,
    br.cpu_model,
    br.cpu_cores,
    br.memory_gb,
    br.phase1_wall_time,
    br.phase2_wall_time,
    br.overall_wall_time,
    br.performance_score,
    br.submitted_at
FROM users u
INNER JOIN benchmark_results br ON u.id = br.user_id
WHERE br.is_verified = TRUE
AND br.overall_wall_time IS NOT NULL
AND br.id = (
    SELECT id
    FROM benchmark_results br2
    WHERE br2.user_id = u.id
    AND br2.is_verified = TRUE
    AND br2.overall_wall_time IS NOT NULL
    ORDER BY br2.overall_wall_time ASC
    LIMIT 1
);
```

### 2. v_leaderboard 视图 - 实时排行榜
基于用户最佳成绩的实时排行榜。

```sql
CREATE VIEW `v_leaderboard` AS
SELECT
    ROW_NUMBER() OVER (ORDER BY overall_wall_time ASC, submitted_at ASC) as rank_position,
    username,
    cpu_model,
    cpu_cores,
    memory_gb,
    overall_wall_time,
    phase1_wall_time,
    phase2_wall_time,
    performance_score,
    submitted_at
FROM v_user_best_results
ORDER BY overall_wall_time ASC, submitted_at ASC;
```

## 索引策略

### 主要索引
- `users`: `uk_username`, `uk_user_id`
- `benchmark_results`: `idx_user_id`, `idx_username`, `idx_submitted_at`, `idx_performance_score`, `idx_overall_time`, `idx_is_verified`, `idx_ranking`
- `leaderboard_snapshots`: `uk_snapshot_rank`, `idx_snapshot_date`, `idx_user_snapshot`
- `system_config`: `uk_config_key`

### 复合索引
- `idx_ranking` (`is_verified`, `overall_wall_time`, `submitted_at`) - 专门用于排行榜查询

## 初始配置数据

系统预设的配置项：

| 配置键 | 默认值 | 类型 | 说明 |
|--------|--------|------|------|
| leaderboard_enabled | true | boolean | 是否启用排行榜功能 |
| max_results_per_user | 10 | number | 每个用户最多提交的结果数量 |
| auto_verify_enabled | true | boolean | 是否自动验证新提交的结果 |
| snapshot_retention_days | 90 | number | 排行榜快照保留天数 |
| site_name | 基准测试评分平台 | string | 网站名称 |
| linuxdo_client_id | '' | string | linux.do OAuth 客户端ID |
| linuxdo_client_secret | '' | string | linux.do OAuth 客户端密钥 |

## 数据特点

### 性能优化
1. **冗余字段**: `benchmark_results.username` 冗余存储用户名，避免频繁 JOIN
2. **索引优化**: 针对排行榜查询优化的复合索引
3. **视图预计算**: 使用视图预先计算排行榜数据
4. **快照表**: 定期生成排行榜快照，提高查询性能

### 扩展性考虑
1. **提交来源**: 支持多种提交来源（web, api, cli）
2. **验证机制**: 支持手动和自动验证
3. **配置系统**: 通过数据库配置管理功能开关

### 数据完整性
1. **外键约束**: 确保 `benchmark_results.user_id` 引用有效的用户
2. **唯一约束**: 确保用户名和 linux.do 用户ID的唯一性
3. **NOT NULL**: 关键字段设置 NOT NULL 约束