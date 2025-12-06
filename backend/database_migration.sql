-- 数据库迁移脚本：添加设备类型分类功能
-- 添加时间：2025-12-05
-- 版本：1.1.0

USE `benchmark`;

-- 1. 添加设备类型字段到benchmark_results表
ALTER TABLE `benchmark_results`
ADD COLUMN `device_type` ENUM('server', 'consumer', 'unknown') DEFAULT 'unknown'
COMMENT '设备类型: server(服务器级), consumer(消费级), unknown(未知)'
AFTER `memory_gb`;

-- 2. 添加设备类型置信度字段
ALTER TABLE `benchmark_results`
ADD COLUMN `device_type_confidence` DECIMAL(3,2) DEFAULT 0.00
COMMENT '设备类型识别置信度 (0.00-1.00)'
AFTER `device_type`;

-- 3. 添加用户允许设备类型修正字段
ALTER TABLE `benchmark_results`
ADD COLUMN `device_type_manually_corrected` BOOLEAN DEFAULT FALSE
COMMENT '设备类型是否被用户手动修正'
AFTER `device_type_confidence`;

-- 4. 添加索引用于排行榜分类查询
ALTER TABLE `benchmark_results`
ADD INDEX `idx_device_type_ranking` (`is_verified`, `device_type`, `overall_wall_time`, `submitted_at`);

-- 5. 更新系统配置表，添加新的配置项
INSERT INTO `system_config` (`config_key`, `config_value`, `config_type`, `description`) VALUES
('max_results_per_user', '3', 'number', '每个用户最多提交的结果数量'),
('enable_device_classification', 'true', 'boolean', '是否启用设备类型自动分类'),
('device_type_confidence_threshold', '0.7', 'number', '设备类型自动分类的置信度阈值'),
('enable_manual_device_type_correction', 'true', 'boolean', '是否允许用户手动修正设备类型')
ON DUPLICATE KEY UPDATE
`config_value` = VALUES(`config_value`);

-- 更新现有的 max_results_per_user 配置为 3
UPDATE `system_config`
SET `config_value` = '3'
WHERE `config_key` = 'max_results_per_user';

-- 6. 更新排行榜快照表，添加设备类型支持
ALTER TABLE `leaderboard_snapshots`
ADD COLUMN `device_type` ENUM('server', 'consumer', 'unknown') DEFAULT 'unknown'
COMMENT '设备类型: server(服务器级), consumer(消费级), unknown(未知)'
AFTER `performance_score`;

-- 7. 更新视图以支持设备类型分类
DROP VIEW IF EXISTS `v_user_best_results`;
CREATE VIEW `v_user_best_results` AS
SELECT
    u.id as user_id,
    u.username,
    u.avatar_url,
    br.id as result_id,
    br.cpu_model,
    br.cpu_cores,
    br.memory_gb,
    br.device_type,
    br.device_type_confidence,
    br.device_type_manually_corrected,
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

-- 8. 创建分类排行榜视图
DROP VIEW IF EXISTS `v_server_leaderboard`;
CREATE VIEW `v_server_leaderboard` AS
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
    submitted_at,
    device_type_confidence
FROM v_user_best_results
WHERE device_type = 'server'
ORDER BY overall_wall_time ASC, submitted_at ASC;

DROP VIEW IF EXISTS `v_consumer_leaderboard`;
CREATE VIEW `v_consumer_leaderboard` AS
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
    submitted_at,
    device_type_confidence
FROM v_user_best_results
WHERE device_type = 'consumer'
ORDER BY overall_wall_time ASC, submitted_at ASC;

-- 9. 更新综合排行榜视图
DROP VIEW IF EXISTS `v_leaderboard`;
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
    submitted_at,
    device_type,
    device_type_confidence
FROM v_user_best_results
ORDER BY overall_wall_time ASC, submitted_at ASC;

-- 10. 为现有数据自动分类设备类型（可选的批量更新）
-- 注意：这个更新可能会比较慢，建议分批执行
UPDATE `benchmark_results`
SET
    `device_type` = CASE
        WHEN `cpu_model` LIKE '%Xeon%' OR `cpu_model` LIKE '%EPYC%' OR `cpu_model` LIKE '%Opteron%' OR `cpu_model` LIKE '%POWER%' THEN 'server'
        WHEN `cpu_model` LIKE '%Core i%' OR `cpu_model` LIKE '%Ryzen%' OR `cpu_model` LIKE '%Apple M%' OR `cpu_model` LIKE '%Pentium%' OR `cpu_model` LIKE '%Celeron%' THEN 'consumer'
        ELSE 'unknown'
    END,
    `device_type_confidence` = CASE
        WHEN `cpu_model` LIKE '%Xeon%' OR `cpu_model` LIKE '%EPYC%' OR `cpu_model` LIKE '%Core i%' OR `cpu_model` LIKE '%Ryzen%' THEN 0.95
        WHEN `cpu_model` LIKE '%Opteron%' OR `cpu_model` LIKE '%POWER%' OR `cpu_model` LIKE '%Apple M%' OR `cpu_model` LIKE '%Pentium%' OR `cpu_model` LIKE '%Celeron%' THEN 0.90
        ELSE 0.00
    END
WHERE `cpu_model` IS NOT NULL AND `device_type` = 'unknown';

-- 11. 创建用户提交记录限制检查的存储过程
DELIMITER $$
CREATE PROCEDURE `CheckUserResultLimit`(
    IN p_user_id BIGINT,
    IN p_max_results INT,
    OUT p_result_count INT,
    OUT p_can_submit BOOLEAN
)
BEGIN
    -- 统计用户已提交的已验证记录数
    SELECT COUNT(*) INTO p_result_count
    FROM benchmark_results
    WHERE user_id = p_user_id AND is_verified = TRUE;

    -- 判断是否可以继续提交
    SET p_can_submit = (p_result_count < p_max_results);
END$$
DELIMITER ;

-- 12. 创建更新设备类型的存储过程
DELIMITER $$
CREATE PROCEDURE `UpdateDeviceType`(
    IN p_result_id BIGINT,
    IN p_device_type VARCHAR(20),
    IN p_manually_corrected BOOLEAN
)
BEGIN
    UPDATE benchmark_results
    SET device_type = p_device_type,
        device_type_manually_corrected = p_manually_corrected,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_result_id;
END$$
DELIMITER ;

-- 迁移完成提示
SELECT '数据库迁移完成！已添加设备类型分类功能和用户记录限制支持。' AS migration_status;