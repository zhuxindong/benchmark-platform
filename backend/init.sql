-- 基准测试评分平台数据库初始化脚本

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `benchmark`
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `benchmark`;

-- 用户表 - 存储通过 linux.do 认证的用户信息
CREATE TABLE `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(100) NOT NULL COMMENT 'linux.do 用户名',
    `user_id` VARCHAR(100) NOT NULL COMMENT 'linux.do 用户ID',
    `email` VARCHAR(255) DEFAULT NULL COMMENT '邮箱地址',
    `avatar_url` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_user_id` (`user_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

-- 基准测试结果表 - 存储用户提交的基准测试结果
CREATE TABLE `benchmark_results` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID，关联users表',
    `username` VARCHAR(100) NOT NULL COMMENT '提交时的用户名（冗余字段，便于查询）',

    -- 系统信息
    `cpu_model` VARCHAR(255) DEFAULT NULL COMMENT 'CPU型号',
    `cpu_cores` INT DEFAULT NULL COMMENT '逻辑核心数',
    `memory_gb` DECIMAL(10,2) DEFAULT NULL COMMENT '内存大小(GB)',

    -- 性能数据
    `phase1_wall_time` DECIMAL(15,6) DEFAULT NULL COMMENT 'Phase 1 耗时(秒)',
    `phase2_wall_time` DECIMAL(15,6) DEFAULT NULL COMMENT 'Phase 2 耗时(秒)',
    `overall_wall_time` DECIMAL(15,6) DEFAULT NULL COMMENT '总耗时(秒)',

    -- 计算得出的性能指标
    `throughput_keys_per_sec` BIGINT DEFAULT NULL COMMENT 'Phase 1 吞吐量(密钥/秒)',
    `performance_score` DECIMAL(15,6) DEFAULT NULL COMMENT '综合性能分数',

    -- 元数据
    `raw_result_text` TEXT DEFAULT NULL COMMENT '原始基准测试结果文本',
    `ip_address` VARCHAR(45) DEFAULT NULL COMMENT '提交者IP地址',
    `user_agent` TEXT DEFAULT NULL COMMENT '用户代理字符串',
    `submission_source` VARCHAR(50) DEFAULT 'web' COMMENT '提交来源: web, api, cli',
    `is_verified` BOOLEAN DEFAULT FALSE COMMENT '是否已验证通过',
    `notes` TEXT DEFAULT NULL COMMENT '备注信息',

    -- 时间戳
    `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_username` (`username`),
    INDEX `idx_submitted_at` (`submitted_at`),
    INDEX `idx_performance_score` (`performance_score`),
    INDEX `idx_overall_time` (`overall_wall_time`),
    INDEX `idx_is_verified` (`is_verified`),

    -- 复合索引用于排行榜查询
    INDEX `idx_ranking` (`is_verified`, `overall_wall_time`, `submitted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='基准测试结果表';

-- 排行榜快照表 - 定期生成排行榜快照，提高查询性能
CREATE TABLE `leaderboard_snapshots` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `snapshot_date` DATE NOT NULL COMMENT '快照日期',
    `rank_position` INT UNSIGNED NOT NULL COMMENT '排名位置',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
    `username` VARCHAR(100) NOT NULL COMMENT '用户名',
    `benchmark_result_id` BIGINT UNSIGNED NOT NULL COMMENT '基准测试结果ID',
    `overall_wall_time` DECIMAL(15,6) NOT NULL COMMENT '总耗时(秒)',
    `performance_score` DECIMAL(15,6) NOT NULL COMMENT '性能分数',
    `cpu_model` VARCHAR(255) DEFAULT NULL COMMENT 'CPU型号',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_snapshot_rank` (`snapshot_date`, `rank_position`),
    INDEX `idx_snapshot_date` (`snapshot_date`),
    INDEX `idx_user_snapshot` (`user_id`, `snapshot_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='排行榜快照表';

-- 系统配置表 - 存储系统配置信息
CREATE TABLE `system_config` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `config_key` VARCHAR(100) NOT NULL COMMENT '配置键',
    `config_value` TEXT DEFAULT NULL COMMENT '配置值',
    `config_type` VARCHAR(20) DEFAULT 'string' COMMENT '配置类型: string, number, boolean, json',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '配置描述',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 插入初始配置数据
INSERT INTO `system_config` (`config_key`, `config_value`, `config_type`, `description`) VALUES
('leaderboard_enabled', 'true', 'boolean', '是否启用排行榜功能'),
('max_results_per_user', '10', 'number', '每个用户最多提交的结果数量'),
('auto_verify_enabled', 'true', 'boolean', '是否自���验证新提交的结果'),
('snapshot_retention_days', '90', 'number', '排行榜快照保留天数'),
('site_name', '基准测试评分平台', 'string', '网站名称'),
('linuxdo_client_id', '', 'string', 'linux.do OAuth 客户端ID'),
('linuxdo_client_secret', '', 'string', 'linux.do OAuth 客户端密钥');

-- 创建视图：最佳成绩排行（用于快速查询）
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

-- 创建视图：实时排行榜
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