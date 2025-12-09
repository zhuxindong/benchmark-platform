/*
 Navicat Premium Dump SQL

 Source Server         : cc-148.135.17.225
 Source Server Type    : MySQL
 Source Server Version : 80043 (8.0.43)
 Source Host           : 148.135.17.225:3306
 Source Schema         : benchmark

 Target Server Type    : MySQL
 Target Server Version : 80043 (8.0.43)
 File Encoding         : 65001

 Date: 08/12/2025 16:40:22
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for benchmark_results
-- ----------------------------
DROP TABLE IF EXISTS `benchmark_results`;
CREATE TABLE `benchmark_results`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID，关联users表',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '提交时的用户名（冗余字段，便于查询）',
  `cpu_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CPU型号',
  `cpu_cores` int NULL DEFAULT NULL COMMENT '逻辑核心数',
  `memory_gb` decimal(10, 2) NULL DEFAULT NULL COMMENT '内存大小(GB)',
  `device_type` enum('server','consumer','unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'unknown' COMMENT '设备类型: server(服务器级), consumer(消费级), unknown(未知)',
  `device_type_confidence` decimal(3, 2) NULL DEFAULT 0.00 COMMENT '设备类型识别置信度 (0.00-1.00)',
  `device_type_manually_corrected` tinyint(1) NULL DEFAULT 0 COMMENT '设备类型是否被用户手动修正',
  `phase1_wall_time` decimal(15, 6) NULL DEFAULT NULL COMMENT 'Phase 1 耗时(秒)',
  `phase2_wall_time` decimal(15, 6) NULL DEFAULT NULL COMMENT 'Phase 2 耗时(秒)',
  `overall_wall_time` decimal(15, 6) NULL DEFAULT NULL COMMENT '总耗时(秒)',
  `throughput_keys_per_sec` bigint NULL DEFAULT NULL COMMENT 'Phase 1 吞吐量(密钥/秒)',
  `performance_score` decimal(15, 6) NULL DEFAULT NULL COMMENT '综合性能分数',
  `raw_result_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '原始基准测试结果文本',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '提交者IP地址',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '用户代理字符串',
  `submission_source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'web' COMMENT '提交来源: web, api, cli',
  `is_verified` tinyint(1) NULL DEFAULT 0 COMMENT '是否已验证通过',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注信息',
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_submitted_at`(`submitted_at` ASC) USING BTREE,
  INDEX `idx_performance_score`(`performance_score` ASC) USING BTREE,
  INDEX `idx_overall_time`(`overall_wall_time` ASC) USING BTREE,
  INDEX `idx_is_verified`(`is_verified` ASC) USING BTREE,
  INDEX `idx_ranking`(`is_verified` ASC, `overall_wall_time` ASC, `submitted_at` ASC) USING BTREE,
  INDEX `idx_device_type_ranking`(`is_verified` ASC, `device_type` ASC, `overall_wall_time` ASC, `submitted_at` ASC) USING BTREE,
  CONSTRAINT `benchmark_results_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 162 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '基准测试结果表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of benchmark_results
-- ----------------------------
INSERT INTO `benchmark_results` VALUES (1, 1, 'wozulong', 'AMD Ryzen 7 9700X 8-Core Processor', 16, 23.10, 'consumer', 0.95, 0, 31.414000, 34.393000, 63.062000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 08:51:20', '2025-12-05 23:10:41');
INSERT INTO `benchmark_results` VALUES (2, 2, 'steve5wutongyu6', 'AMD EPYC 9T95 192-Core Processor', 192, 365.30, 'server', 0.95, 0, 3.529000, 5.240000, 9.122000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:04:54', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (3, 5, 'onewhite', 'Intel(R) Core(TM) i7-14650HX', 24, 31.70, 'consumer', 0.70, 0, 73.784000, 62.154000, 137.749000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:24:39', '2025-12-05 20:12:07');
INSERT INTO `benchmark_results` VALUES (4, 7, 'haorwen', 'AMD EPYC 9K65 192-Core Processor', 64, 128.00, 'server', 0.95, 0, 10.709000, 17.899000, 28.985000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:27:05', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (5, 14, 'Yuki_28', '13th Gen Intel(R) Core(TM) i5-13420H', 12, 7.60, 'consumer', 0.70, 0, 219.521000, 373.752000, 593.932000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:43:51', '2025-12-05 20:12:07');
INSERT INTO `benchmark_results` VALUES (6, 16, 'diffusion', 'AMD EPYC 9654 96-Core Processor', 384, 1007.40, 'server', 0.95, 0, 3.875000, 4.536000, 8.780000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:48:29', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (7, 13, 'coderZoe', 'Apple M4', 10, 32.00, 'consumer', 0.90, 0, 57.312000, 74.627000, 132.245000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:49:09', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (8, 25, 'code0', 'Apple M4 Pro', 12, 24.00, 'consumer', 0.90, 0, 29.691000, 39.865000, 69.792000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:56:03', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (9, 28, 'Max1012', 'AMD Ryzen 7 8845HS w/ Radeon 780M Graphics', 16, 23.30, 'consumer', 0.95, 0, 73.298000, 78.496000, 152.360000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:58:17', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (10, 29, 'Chen10', 'Apple M1', 8, 16.00, 'consumer', 0.90, 0, 117.451000, 135.768000, 253.616000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 09:58:47', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (11, 32, 'ghwolf', 'Apple M4 Max', 16, 128.00, 'consumer', 0.90, 0, 20.935000, 35.249000, 56.443000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:02:10', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (12, 31, 'cf123', 'Intel(R) Core(TM) Ultra 9 275HX', 24, 31.10, 'consumer', 0.70, 0, 20.945000, 35.185000, 56.483000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:02:59', '2025-12-05 20:12:08');
INSERT INTO `benchmark_results` VALUES (13, 20, 'Shino', 'Intel(R) Core(TM) Ultra 5 245K', 14, 46.50, 'consumer', 0.70, 0, 22.809000, 36.906000, 59.987000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:04:30', '2025-12-05 20:12:08');
INSERT INTO `benchmark_results` VALUES (14, 27, 'fan2016cc', 'Apple M4', 10, 16.00, 'consumer', 0.90, 0, 43.227000, 66.951000, 110.413000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:04:45', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (15, 37, 'ballen', 'Apple M2', 8, 16.00, 'consumer', 0.90, 0, 89.982000, 103.737000, 194.040000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:04:55', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (16, 34, 'Roy_yu', 'Apple M3 Max', 14, 36.00, 'consumer', 0.90, 0, 39.381000, 50.680000, 90.448000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:05:40', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (17, 42, 'Edenn', 'Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz', 40, 125.70, 'server', 0.95, 0, 43.039000, 51.901000, 95.512000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:07:17', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (18, 45, 'Binbim', '12th Gen Intel(R) Core(TM) i7-12700H', 20, 31.70, 'consumer', 0.70, 0, 93.253000, 91.212000, 186.308000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:09:02', '2025-12-05 20:12:08');
INSERT INTO `benchmark_results` VALUES (19, 22, 'ATRI', 'Intel(R) Xeon(R) Platinum 8167M CPU @ 2.00GHz', 104, 190.70, 'server', 0.95, 0, 35.118000, 41.212000, 80.395000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:09:40', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (20, 36, 'by9858', '12th Gen Intel(R) Core(TM) i7-12700F', 20, 31.80, 'consumer', 0.70, 0, 75.072000, 79.003000, 156.326000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:09:52', '2025-12-05 20:12:08');
INSERT INTO `benchmark_results` VALUES (21, 3, 'BIN2450', 'AMD Ryzen AI 9 H 365 w/ Radeon 880M', 20, 30.50, 'consumer', 0.95, 0, 36.176000, 61.070000, 97.504000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:12:48', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (22, 47, '8484', 'Intel(R) Core(TM) Ultra 7 265KF', 20, 15.70, 'consumer', 0.70, 0, 24.314000, 27.235000, 53.644000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:14:31', '2025-12-05 20:12:09');
INSERT INTO `benchmark_results` VALUES (23, 51, 'saiban-kk', 'Apple M3 Pro', 12, 36.00, 'consumer', 0.90, 0, 58.349000, 75.070000, 133.797000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:15:53', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (24, 49, 'MiiZeus', 'Apple M4 Max', 16, 128.00, 'consumer', 0.90, 0, 21.349000, 29.931000, 51.508000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:17:09', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (25, 52, 'akin_akin', 'Apple M4', 10, 16.00, 'consumer', 0.90, 0, 80.742000, 99.333000, 180.406000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:18:19', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (26, 55, 'tuan2046', 'Apple M1 Pro', 8, 16.00, 'consumer', 0.90, 0, 59.818000, 79.209000, 139.356000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:21:08', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (27, 60, 'blue_num', 'Apple M4', 10, 16.00, 'consumer', 0.90, 0, 43.039000, 62.573000, 105.851000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:24:13', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (28, 56, 'AAEE86', 'Apple M4', 10, 16.00, 'consumer', 0.90, 0, 41.347000, 60.029000, 101.585000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:28:41', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (29, 39, 'mumu_fly', 'Intel(R) Core(TM) i5-4278U CPU @ 2.60GHz', 4, 8.00, 'consumer', 0.70, 0, 664.371000, 825.359000, 1490.853000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:29:59', '2025-12-05 20:12:09');
INSERT INTO `benchmark_results` VALUES (30, 44, 'hf3862', '13th Gen Intel(R) Core(TM) i7-13700H', 20, 31.70, 'consumer', 0.70, 0, 90.635000, 90.798000, 186.144000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:30:36', '2025-12-05 20:12:09');
INSERT INTO `benchmark_results` VALUES (31, 64, 'munian390', 'AMD Ryzen AI 9 HX 370 w/ Radeon 890M', 24, 0.00, 'consumer', 0.95, 0, 54.976000, 59.152000, 117.788000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:32:07', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (32, 65, 'ChatGPT', 'Apple M1 Max', 10, 64.00, 'consumer', 0.90, 0, 52.863000, 77.309000, 130.571000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:35:47', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (34, 71, 'jamson', 'Apple M4 Pro', 14, 24.00, 'consumer', 0.90, 0, 31.877000, 36.201000, 68.329000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:49:33', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (35, 73, 'fun5572', 'Apple M1 Max', 10, 32.00, 'consumer', 0.90, 0, 74.914000, 95.749000, 171.137000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:52:27', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (36, 70, 'Mrzqd', 'AMD EPYC 9K85 128-Core Processor', 64, 247.00, 'server', 0.95, 0, 12.776000, 14.582000, 27.655000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 10:57:27', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (37, 79, 'wszszh', 'Apple M3 Max', 16, 64.00, 'consumer', 0.90, 0, 27.658000, 41.836000, 69.773000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:07:38', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (38, 75, 'lihangfu', 'Apple M2 Pro', 12, 16.00, 'consumer', 0.90, 0, 49.287000, 76.369000, 126.047000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:08:06', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (39, 77, 'Tods', '11th Gen Intel(R) Core(TM) i9-11900K @ 3.50GHz', 16, 63.80, 'consumer', 0.70, 0, 97.478000, 103.613000, 205.238000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:09:57', '2025-12-05 20:12:09');
INSERT INTO `benchmark_results` VALUES (41, 82, 'GuYudi', 'Apple M4 Max', 16, 48.00, 'consumer', 0.90, 0, 18.850000, 30.168000, 49.266000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:11:31', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (43, 84, 'Lee7777777', 'Intel(R) Xeon(R) Silver 4110 CPU @ 2.10GHz', 32, 251.40, 'server', 0.95, 0, 73.003000, 84.271000, 158.045000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:23:06', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (44, 92, 'BloomD', 'Snapdragon 8 Elite', 8, 14.80, 'consumer', 0.70, 0, 205.997000, 396.137000, 603.089000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:23:59', '2025-12-05 20:12:10');
INSERT INTO `benchmark_results` VALUES (45, 94, 'Zinc', '13th Gen Intel(R) Core(TM) i9-13905H', 20, 31.70, 'consumer', 0.70, 0, 95.484000, 70.338000, 168.002000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:26:30', '2025-12-05 20:12:10');
INSERT INTO `benchmark_results` VALUES (46, 83, 'LRWF', 'Apple M4', 10, 16.00, 'consumer', 0.90, 0, 44.326000, 74.236000, 118.830000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:32:00', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (47, 97, 'dexter', 'Intel(R) Core(TM) i7-6820HQ CPU @ 2.70GHz', 8, 16.00, 'consumer', 0.70, 0, 324.587000, 398.373000, 724.010000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:36:21', '2025-12-05 20:12:10');
INSERT INTO `benchmark_results` VALUES (48, 98, 'hoping', 'AMD Ryzen 9 5900HX with Radeon Graphics', 16, 48.00, 'consumer', 0.95, 0, 189.499000, 183.633000, 373.942000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:37:41', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (49, 96, 'Aquamarine', 'AMD EPYC 9474F 48-Core Processor', 192, 1511.30, 'server', 0.95, 0, 4.686000, 6.242000, 11.289000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:38:43', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (50, 100, 'GeneYP', 'Apple M1 Pro', 8, 16.00, 'consumer', 0.90, 0, 79.830000, 99.412000, 179.653000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 11:47:22', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (51, 108, 'unique-h', 'AMD Ryzen 9 7945HX with Radeon Graphics', 32, 63.70, 'consumer', 0.95, 0, 31.921000, 33.783000, 67.879000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 12:07:43', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (52, 110, 'Evaleanosrey', 'Intel(R) Core(TM) Ultra 5 225H', 14, 30.80, 'consumer', 0.70, 0, 31.558000, 61.414000, 93.302000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 12:21:04', '2025-12-05 20:12:10');
INSERT INTO `benchmark_results` VALUES (54, 113, 'OneRain233', 'AMD Ryzen 7 8845HS w/ Radeon 780M Graphics', 16, 29.20, 'consumer', 0.95, 0, 31.527000, 54.731000, 86.535000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 12:36:58', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (55, 118, 'nivalxer', 'Apple M2 Max', 12, 96.00, 'consumer', 0.90, 0, 40.545000, 56.942000, 97.850000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:05:19', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (56, 129, 'dunxuan', 'AMD Ryzen 7 4800H with Radeon Graphics', 16, 31.90, 'consumer', 0.95, 0, 169.875000, 214.437000, 389.371000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:29:39', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (58, 115, 'Elains', 'AMD Ryzen 7 5800H with Radeon Graphics', 16, 16.00, 'consumer', 0.95, 0, 86.649000, 105.709000, 194.508000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:40:16', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (59, 136, 'FFattiger', 'Apple M4 Pro', 12, 24.00, 'consumer', 0.90, 0, 33.945000, 52.860000, 87.095000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:46:21', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (60, 134, 'HALOGOGO', 'Intel(R) Core(TM) Ultra 5 225H', 14, 32.00, 'consumer', 0.70, 0, 75.594000, 76.410000, 156.035000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:50:57', '2025-12-05 20:12:11');
INSERT INTO `benchmark_results` VALUES (61, 137, 'Usagi', 'AMD Ryzen 7 5800H with Radeon Graphics', 16, 15.90, 'consumer', 0.95, 0, 134.658000, 122.906000, 261.697000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:53:32', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (62, 138, 'ocean-zhc', 'Intel(R) Xeon(R) Gold 6430', 128, 375.90, 'server', 0.95, 0, 13.908000, 15.305000, 29.813000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:55:31', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (63, 127, 'yuyi233', 'Intel(R) Core(TM) i9-14900KF', 24, 98.20, 'consumer', 0.70, 0, 27.161000, 32.906000, 60.549000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 13:58:51', '2025-12-05 20:12:11');
INSERT INTO `benchmark_results` VALUES (65, 144, 'nick1', 'Apple M2', 8, 24.00, 'consumer', 0.90, 0, 109.249000, 137.227000, 246.821000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:07:56', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (66, 139, 'tonyjun', 'S5000C', 128, 510.00, 'server', 0.00, 0, 22.369000, 46.182000, 70.110000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:15:37', '2025-12-05 22:22:50');
INSERT INTO `benchmark_results` VALUES (67, 146, 'jhhgiyv', 'AMD Ryzen 9 9950X 16-Core Processor', 32, 23.00, 'consumer', 0.95, 0, 15.070000, 20.804000, 36.129000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:29:51', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (68, 147, 'Ykuee', 'Intel(R) Core(TM) i9-14900HX', 32, 32.00, 'consumer', 0.70, 0, 67.508000, 68.813000, 138.926000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:30:36', '2025-12-05 20:12:11');
INSERT INTO `benchmark_results` VALUES (69, 150, 'klbq', 'Apple M4 Pro', 14, 48.00, 'consumer', 0.90, 0, 25.594000, 41.706000, 67.558000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:31:14', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (70, 21, 'zhuoshuang', 'Apple M3', 8, 24.00, 'consumer', 0.90, 0, 113.287000, 222.475000, 336.313000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:33:51', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (71, 153, 'aiyaya1006', 'Intel(R) Xeon(R) Silver 4215 CPU @ 2.50GHz', 32, 125.60, 'server', 0.95, 0, 85.158000, 87.322000, 173.319000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:37:26', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (72, 156, 'rty813', 'INTEL(R) XEON(R) PLATINUM 8581C', 240, 188.50, 'server', 0.95, 0, 7.948000, 8.948000, 17.557000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:52:00', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (73, 151, 'SumizomeAi', 'AMD Ryzen 7 8845HS w/ Radeon 780M Graphics', 16, 31.30, 'consumer', 0.95, 0, 79.807000, 98.503000, 180.754000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:52:45', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (74, 158, 'fcanlnony', '13th Gen Intel(R) Core(TM) i7-13620H', 16, 31.00, 'consumer', 0.70, 0, 75.771000, 106.558000, 182.731000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:53:35', '2025-12-05 20:12:12');
INSERT INTO `benchmark_results` VALUES (75, 155, 'nonoone', '11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz', 8, 31.10, 'consumer', 0.70, 0, 205.703000, 272.911000, 479.138000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 14:55:21', '2025-12-05 20:12:12');
INSERT INTO `benchmark_results` VALUES (76, 161, 'gyxsama', 'Intel(R) Core(TM) Ultra 5 225H', 14, 32.00, 'consumer', 0.70, 0, 33.140000, 60.372000, 93.835000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 15:18:33', '2025-12-05 20:12:12');
INSERT INTO `benchmark_results` VALUES (77, 162, 'qntm', 'Intel(R) Core(TM) Ultra 9 275HX', 24, 32.00, 'consumer', 0.70, 0, 20.842000, 24.584000, 47.045000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 15:18:37', '2025-12-05 20:12:12');
INSERT INTO `benchmark_results` VALUES (78, 166, 'zj.z', 'AMD EPYC 7K62 48-Core Processor', 192, 1007.70, 'server', 0.95, 0, 8.796000, 10.291000, 19.664000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 15:28:42', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (79, 168, 'alisws', 'Intel(R) Xeon(R) Silver 4210 CPU @ 2.20GHz', 4, 15.60, 'server', 0.95, 0, 333.760000, 380.642000, 715.423000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 15:32:15', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (80, 164, 'RyanStarFox', 'Apple M2 Pro', 12, 32.00, 'consumer', 0.90, 0, 49.468000, 67.862000, 117.710000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 15:34:09', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (81, 170, 'flyingcoding', 'Apple M3 Pro', 12, 36.00, 'consumer', 0.90, 0, 54.323000, 69.020000, 123.728000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 15:36:23', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (82, 172, 'nbb', 'Intel(R) Xeon(R) Platinum 8481C', 224, 125.50, 'server', 0.95, 0, 7.777000, 9.135000, 17.286000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 15:46:40', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (83, 160, '555hai', '11th Gen Intel(R) Core(TM) i5-1130G7 @ 1.10GHz', 8, 7.80, 'consumer', 0.70, 0, 1265.458000, 1293.343000, 2563.080000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 16:02:51', '2025-12-05 20:12:13');
INSERT INTO `benchmark_results` VALUES (84, 176, 'SKT.Shinyruo', 'AMD Ryzen 9 9950X 16-Core Processor', 32, 45.90, 'consumer', 0.95, 0, 17.425000, 28.108000, 45.861000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 16:05:53', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (85, 178, 'magot', 'INTEL(R) XEON(R) PLATINUM 8558P', 192, 1511.60, 'server', 0.95, 0, 6.352000, 9.468000, 16.320000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 16:14:41', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (86, 180, 'snowedd', 'Apple M1 Pro', 8, 16.00, 'consumer', 0.90, 0, 79.640000, 77.059000, 157.063000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 16:17:04', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (87, 179, 'mvec', '13th Gen Intel(R) Core(TM) i9-13900H', 20, 15.70, 'consumer', 0.70, 0, 117.872000, 143.967000, 266.049000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 16:19:27', '2025-12-05 20:12:13');
INSERT INTO `benchmark_results` VALUES (88, 181, 'yol1', 'AMD Ryzen 9 7950X 16-Core Processor', 32, 125.40, 'consumer', 0.95, 0, 22.999000, 29.633000, 52.956000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 16:39:29', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (89, 183, 'KGadfly', 'Intel(R) Core(TM) Ultra 7 265K', 20, 48.00, 'consumer', 0.70, 0, 23.137000, 29.634000, 54.579000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 16:59:16', '2025-12-05 20:12:13');
INSERT INTO `benchmark_results` VALUES (90, 121, 'cch_jcc', 'Intel(R) Core(TM) i7-14650HX', 16, 16.00, 'consumer', 0.70, 0, 143.528000, 135.536000, 280.817000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 18:23:26', '2025-12-05 20:12:13');
INSERT INTO `benchmark_results` VALUES (91, 185, 'Handsomedog', 'AMD Ryzen 7 9700X 8-Core Processor', 16, 48.00, 'consumer', 0.95, 0, 58.351000, 55.189000, 115.148000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 19:07:23', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (92, 186, 'journey-ad', 'Apple M4 Pro', 14, 48.00, 'consumer', 0.90, 0, 27.958000, 50.761000, 79.080000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 19:32:43', '2025-12-05 20:02:29');
INSERT INTO `benchmark_results` VALUES (93, 189, 'simonth', 'Intel(R) Core(TM) i9-14900KF', 32, 62.60, 'consumer', 0.00, 0, 19.950000, 25.003000, 45.189000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 20:51:33', '2025-12-05 20:56:25');
INSERT INTO `benchmark_results` VALUES (94, 190, 'Tom_Jerry', '12th Gen Intel(R) Core(TM) i7-12700', 20, 0.00, 'consumer', 0.00, 0, 80.975000, 80.923000, 163.688000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 20:54:51', '2025-12-05 21:00:38');
INSERT INTO `benchmark_results` VALUES (95, 30, 'a-i-r', 'AMD Ryzen 9 7945HX with Radeon Graphics', 32, 15.70, 'consumer', 0.00, 0, 38.412000, 41.608000, 82.558000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 20:57:59', '2025-12-05 22:23:40');
INSERT INTO `benchmark_results` VALUES (96, 191, 'isKEKE', '13th Gen Intel(R) Core(TM) i5-13600K', 20, 31.80, 'consumer', 0.00, 0, 55.907000, 94.041000, 152.182000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 20:58:07', '2025-12-05 22:23:43');
INSERT INTO `benchmark_results` VALUES (97, 193, 'chenxbbb', 'Intel(R) Core(TM) i5-14600KF', 20, 31.80, 'consumer', 0.00, 0, 58.274000, 52.372000, 112.284000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 21:43:01', '2025-12-05 22:23:46');
INSERT INTO `benchmark_results` VALUES (98, 194, 'bingfengfeifei', 'Phytium S5000C-64', 128, 502.80, 'server', 0.00, 0, 9.923000, 16.608000, 27.553000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 21:58:35', '2025-12-05 22:23:48');
INSERT INTO `benchmark_results` VALUES (99, 195, 'Daertard', '13th Gen Intel(R) Core(TM) i5-13400', 16, 31.80, 'consumer', 0.00, 0, 150.319000, 141.600000, 294.184000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 22:10:06', '2025-12-05 22:23:51');
INSERT INTO `benchmark_results` VALUES (100, 197, 'youyi1314', 'Intel(R) Core(TM) Ultra 9 275HX', 24, 64.00, 'consumer', 0.00, 0, 29.449000, 35.209000, 66.705000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 22:20:53', '2025-12-05 22:23:56');
INSERT INTO `benchmark_results` VALUES (101, 201, 'ImKK', '11th Gen Intel(R) Core(TM) i7-11700K @ 3.60GHz', 16, 63.80, 'consumer', 0.00, 0, 103.040000, 100.761000, 206.350000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 22:45:58', '2025-12-05 22:52:18');
INSERT INTO `benchmark_results` VALUES (104, 203, '1157', 'Apple M2', 8, 24.00, 'consumer', 0.70, 0, 102.227000, 139.090000, 241.739000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 23:04:55', '2025-12-05 23:04:55');
INSERT INTO `benchmark_results` VALUES (105, 1, 'wozulong', 'AMD Ryzen 7 9700X 8-Core Processor', 16, 23.10, 'consumer', 0.95, 0, 31.414000, 34.393000, 61.062000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 23:10:12', '2025-12-05 23:10:12');
INSERT INTO `benchmark_results` VALUES (106, 2, 'steve5wutongyu6', '倚天710', 64, 245.90, 'server', 1.00, 0, 9.943000, 15.873000, 26.394000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 23:19:13', '2025-12-05 23:19:13');
INSERT INTO `benchmark_results` VALUES (107, 205, 'ztt', 'Apple M3 Pro', 12, 36.00, 'consumer', 0.70, 0, 59.701000, 72.525000, 132.667000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 23:21:34', '2025-12-05 23:21:34');
INSERT INTO `benchmark_results` VALUES (108, 2, 'steve5wutongyu6', '11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz', 8, 23.80, 'consumer', 0.70, 0, 264.275000, 258.451000, 525.725000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 23:40:18', '2025-12-05 23:40:18');
INSERT INTO `benchmark_results` VALUES (110, 199, 'Murasame', 'Amlogic GXL Series S905L', 4, 0.80, 'unknown', 0.00, 0, 1867.744000, 2858.523000, 4733.789000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-05 23:50:03', '2025-12-05 23:50:03');
INSERT INTO `benchmark_results` VALUES (111, 96, 'Aquamarine', 'Intel(R) Core(TM) i9-14900HX', 32, 15.40, 'consumer', 0.70, 0, 38.869000, 52.521000, 91.759000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 00:14:28', '2025-12-06 00:14:28');
INSERT INTO `benchmark_results` VALUES (112, 139, 'tonyjun', 'Phytium,FT-2000+/64', 64, 252.80, 'server', 1.00, 0, 98.845000, 108.871000, 210.543000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 00:18:59', '2025-12-06 00:18:59');
INSERT INTO `benchmark_results` VALUES (113, 208, 'randname', 'AMD Ryzen 7 5700X 8-Core Processor', 16, 0.00, 'consumer', 0.95, 0, 74.616000, 73.638000, 150.007000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 00:30:50', '2025-12-06 00:30:50');
INSERT INTO `benchmark_results` VALUES (114, 210, 'ttaox', 'INTEL(R) XEON(R) PLATINUM 8558', 192, 2015.20, 'server', 0.95, 0, 6.714000, 8.087000, 15.143000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 00:50:30', '2025-12-06 00:50:30');
INSERT INTO `benchmark_results` VALUES (115, 212, 'moulai', 'AMD EPYC 9754 128-Core Processor', 512, 1511.40, 'server', 0.98, 0, 4.475000, 5.241000, 10.195000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 01:08:23', '2025-12-06 01:08:23');
INSERT INTO `benchmark_results` VALUES (116, 200, 'Einzieg', 'AMD Ryzen 9 9950X 16-Core Processor', 32, 32.00, 'consumer', 0.95, 0, 17.358000, 24.056000, 41.672000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 01:20:51', '2025-12-06 01:20:51');
INSERT INTO `benchmark_results` VALUES (117, 208, 'randname', 'AMD Embedded G-Series GX-215JJ Radeon R2E', 2, 3.50, 'consumer', 1.00, 0, 1983.387000, 1747.305000, 3732.575000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 02:19:06', '2025-12-06 02:19:06');
INSERT INTO `benchmark_results` VALUES (118, 208, 'randname', '8gen3', 8, 14.90, 'consumer', 1.00, 0, 201.476000, 341.911000, 544.064000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 02:34:44', '2025-12-06 02:34:44');
INSERT INTO `benchmark_results` VALUES (119, 216, 'hansson', 'Intel(R) Core(TM) i7-9700 CPU @ 3.00GHz', 8, 31.90, 'consumer', 0.70, 0, 212.541000, 174.071000, 390.655000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 08:18:27', '2025-12-06 08:18:27');
INSERT INTO `benchmark_results` VALUES (120, 112, 'ZKY_DW_Wait_me', 'Intel(R) Core(TM) Ultra 7 255H', 16, 32.00, 'consumer', 0.70, 0, 37.665000, 44.182000, 83.978000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 08:33:19', '2025-12-06 08:33:19');
INSERT INTO `benchmark_results` VALUES (122, 214, 'failed-to-load', 'Intel(R) Core(TM) i7-10510U CPU @ 1.80GHz', 8, 15.90, 'consumer', 0.70, 0, 797.637000, 925.156000, 1729.315000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 08:39:30', '2025-12-06 08:39:30');
INSERT INTO `benchmark_results` VALUES (123, 214, 'failed-to-load', 'Intel(R) Xeon(R) Platinum 8275CL CPU @ 3.00GHz', 4, 7.80, 'server', 0.95, 0, 202.364000, 303.881000, 506.981000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 08:53:38', '2025-12-06 08:53:38');
INSERT INTO `benchmark_results` VALUES (124, 218, 'xzygreen', 'Apple M2', 8, 16.00, 'consumer', 0.70, 0, 64.114000, 96.792000, 161.214000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 10:24:45', '2025-12-06 10:24:45');
INSERT INTO `benchmark_results` VALUES (125, 219, 'Liebesleid', 'Intel Core I9 13900K', 24, 32.00, 'consumer', 0.95, 0, 34.262000, 31.861000, 69.145000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 10:58:47', '2025-12-06 10:58:47');
INSERT INTO `benchmark_results` VALUES (126, 220, '1593109259', 'AMD Ryzen 5 9600X 6-Core Processor', 12, 31.10, 'consumer', 0.95, 0, 76.236000, 80.435000, 159.689000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 11:13:23', '2025-12-06 11:13:23');
INSERT INTO `benchmark_results` VALUES (127, 160, '555hai', '11th Gen Intel(R) Core(TM) i5-1130G7 @ 1.10GHz', 8, 7.80, 'consumer', 0.70, 0, 2418.007000, 5739.470000, 8180.086000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 11:42:11', '2025-12-06 11:42:11');
INSERT INTO `benchmark_results` VALUES (130, 223, 'ArchmageJu', 'Intel(R) Core(TM) Ultra 9 185H', 22, 31.60, 'consumer', 0.70, 0, 68.534000, 71.447000, 142.102000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 11:58:56', '2025-12-06 11:58:56');
INSERT INTO `benchmark_results` VALUES (131, 225, 'TTTEST', 'AMD Ryzen 5 5600X 6-Core Processor', 12, 15.90, 'consumer', 1.00, 0, 136.090000, 161.664000, 299.832000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 13:05:02', '2025-12-06 13:05:02');
INSERT INTO `benchmark_results` VALUES (132, 146, 'jhhgiyv', 'Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz', 28, 62.50, 'server', 0.95, 0, 78.255000, 87.538000, 166.442000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 14:19:45', '2025-12-06 14:19:45');
INSERT INTO `benchmark_results` VALUES (135, 229, 'unclesamo', 'Intel(R) Xeon(R) Gold 6240R CPU @ 2.40GHz', 48, 125.40, 'server', 0.95, 0, 27.808000, 28.469000, 57.251000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 14:48:06', '2025-12-06 14:48:06');
INSERT INTO `benchmark_results` VALUES (136, 227, 'Arxedd', 'Intel(R) Core(TM) i5-14600KF', 20, 23.50, 'consumer', 0.70, 0, 33.120000, 41.778000, 75.132000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 14:48:13', '2025-12-06 14:48:13');
INSERT INTO `benchmark_results` VALUES (137, 228, 'cliff_falling', 'Apple M4', 10, 16.00, 'consumer', 0.70, 0, 44.863000, 65.621000, 110.726000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 14:48:38', '2025-12-06 14:48:38');
INSERT INTO `benchmark_results` VALUES (138, 227, 'Arxedd', 'AMD Ryzen 9 7940HS w/ Radeon 780M Graphics', 16, 27.20, 'consumer', 0.95, 0, 42.414000, 59.507000, 102.234000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 14:54:20', '2025-12-06 14:54:20');
INSERT INTO `benchmark_results` VALUES (139, 230, 'somnambulating', 'Intel(R) Xeon(R) Gold 6326 CPU @ 2.90GHz', 64, 503.50, 'server', 0.95, 0, 28.191000, 33.483000, 62.293000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 14:58:11', '2025-12-06 14:58:11');
INSERT INTO `benchmark_results` VALUES (140, 230, 'somnambulating', '12th Gen Intel(R) Core(TM) i9-12900H', 20, 31.70, 'consumer', 0.70, 0, 131.038000, 121.653000, 256.344000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 14:59:53', '2025-12-06 14:59:53');
INSERT INTO `benchmark_results` VALUES (141, 227, 'Arxedd', 'Intel(R) Xeon(R) Platinum 8457C', 192, 251.50, 'server', 0.95, 0, 7.945000, 10.664000, 19.111000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 15:00:59', '2025-12-06 15:00:59');
INSERT INTO `benchmark_results` VALUES (142, 234, 'xing4c', 'AMD Ryzen 9 7945HX with Radeon Graphics', 32, 15.70, 'consumer', 0.95, 0, 67.772000, 101.042000, 171.248000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 15:25:15', '2025-12-06 15:25:15');
INSERT INTO `benchmark_results` VALUES (143, 232, 'atopos31', 'Apple M4', 10, 24.00, 'consumer', 0.70, 0, 47.014000, 99.176000, 146.503000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 15:25:22', '2025-12-06 15:25:22');
INSERT INTO `benchmark_results` VALUES (144, 235, 'hehehe123', 'Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz', 24, 31.80, 'consumer', 1.00, 0, 167.162000, 166.642000, 337.333000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 16:14:44', '2025-12-06 16:14:44');
INSERT INTO `benchmark_results` VALUES (145, 236, 'Suzuran', ' Intel(R) Core(TM) i7-14650HX', 24, 32.00, 'consumer', 0.70, 0, 50.059000, 45.157000, 95.667000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 17:12:46', '2025-12-06 17:12:46');
INSERT INTO `benchmark_results` VALUES (146, 239, 'trisoil', 'Apple M1 Max', 10, 64.00, 'consumer', 0.70, 0, 55.974000, 80.035000, 136.443000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 19:25:52', '2025-12-06 19:25:52');
INSERT INTO `benchmark_results` VALUES (147, 243, 'Yueby', 'AMD Ryzen 7 9800X3D 8-Core Processor', 16, 48.00, 'consumer', 0.95, 0, 55.110000, 54.655000, 111.469000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 19:43:06', '2025-12-06 19:43:06');
INSERT INTO `benchmark_results` VALUES (148, 55, 'tuan2046', 'Intel(R) Xeon(R) CPU @ 2.20GHz', 2, 0.90, 'server', 0.95, 0, 25237.353000, 20875.004000, 46147.132000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 20:03:33', '2025-12-06 20:03:33');
INSERT INTO `benchmark_results` VALUES (149, 244, 'opzc35', 'Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz', 8, 15.90, 'consumer', 1.00, 0, 485.541000, 605.809000, 1097.734000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 20:28:20', '2025-12-06 20:28:20');
INSERT INTO `benchmark_results` VALUES (150, 247, 'mmgitujw', '12th Gen Intel(R) Core(TM) i5-12500H', 16, 64.00, 'consumer', 0.70, 0, 96.794000, 88.655000, 187.560000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 21:11:35', '2025-12-06 21:11:35');
INSERT INTO `benchmark_results` VALUES (152, 244, 'opzc35', 'AMD EPYC 7K83 64-Core Processor', 2, 1.90, 'server', 1.00, 0, 712.795000, 836.874000, 1550.308000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-06 21:48:12', '2025-12-06 21:48:12');
INSERT INTO `benchmark_results` VALUES (154, 250, 'zhaox', 'AMD Ryzen 9 8945HX with Radeon Graphics', 32, 64.00, 'consumer', 1.00, 0, 33.595000, 38.950000, 74.282000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-07 10:29:03', '2025-12-07 10:29:03');
INSERT INTO `benchmark_results` VALUES (155, 249, 'chenpan', 'Intel(R) Core(TM) i7-14700K', 28, 63.80, 'consumer', 0.70, 0, 48.392000, 41.723000, 91.775000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-07 10:31:32', '2025-12-07 10:31:32');
INSERT INTO `benchmark_results` VALUES (156, 251, 'jrerrq', 'Intel(R) Core(TM) Ultra 9 285K', 24, 0.00, 'consumer', 0.70, 0, 23.491000, 25.818000, 50.896000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-07 16:31:23', '2025-12-07 16:31:23');
INSERT INTO `benchmark_results` VALUES (157, 252, 'zkogow', 'Apple M1 Pro', 8, 16.00, 'consumer', 0.70, 0, 86.984000, 100.829000, 188.270000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-07 17:24:49', '2025-12-07 17:24:49');
INSERT INTO `benchmark_results` VALUES (158, 252, 'zkogow', 'AMD Ryzen 5 7500F 6-Core Processor', 12, 15.40, 'consumer', 0.95, 0, 48.719000, 64.948000, 114.001000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-07 17:31:26', '2025-12-07 17:31:26');
INSERT INTO `benchmark_results` VALUES (159, 253, 'xjtu_wang', 'AMD Ryzen 7 7840HS with Radeon 780M Graphics', 16, 27.10, 'consumer', 0.95, 0, 52.749000, 88.823000, 142.082000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-07 17:34:56', '2025-12-07 17:34:56');
INSERT INTO `benchmark_results` VALUES (160, 254, 'daisheng', '13th Gen Intel(R) Core(TM) i5-13500H', 16, 15.30, 'consumer', 1.00, 0, 61.206000, 78.912000, 140.462000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-07 21:22:07', '2025-12-07 21:22:07');
INSERT INTO `benchmark_results` VALUES (161, 216, 'hansson', 'Intel(R) Core(TM) i9-14900KF', 32, 63.70, 'consumer', 0.70, 0, 37.112000, 31.305000, 70.317000, NULL, NULL, NULL, NULL, NULL, 'web', 0, NULL, '2025-12-08 09:19:07', '2025-12-08 09:19:07');

-- ----------------------------
-- Table structure for leaderboard_snapshots
-- ----------------------------
DROP TABLE IF EXISTS `leaderboard_snapshots`;
CREATE TABLE `leaderboard_snapshots`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `snapshot_date` date NOT NULL COMMENT '快照日期',
  `rank_position` int UNSIGNED NOT NULL COMMENT '排名位置',
  `user_id` bigint UNSIGNED NOT NULL COMMENT '用户ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `benchmark_result_id` bigint UNSIGNED NOT NULL COMMENT '基准测试结果ID',
  `overall_wall_time` decimal(15, 6) NOT NULL COMMENT '总耗时(秒)',
  `performance_score` decimal(15, 6) NOT NULL COMMENT '性能分数',
  `device_type` enum('server','consumer','unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'unknown' COMMENT '设备类型: server(服务器级), consumer(消费级), unknown(未知)',
  `cpu_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CPU型号',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_snapshot_rank`(`snapshot_date` ASC, `rank_position` ASC) USING BTREE,
  INDEX `idx_snapshot_date`(`snapshot_date` ASC) USING BTREE,
  INDEX `idx_user_snapshot`(`user_id` ASC, `snapshot_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '排行榜快照表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of leaderboard_snapshots
-- ----------------------------

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '配置值',
  `config_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'string' COMMENT '配置类型: string, number, boolean, json',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配置描述',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'leaderboard_enabled', 'true', 'boolean', '是否启用排行榜功能', '2025-12-04 17:06:59', '2025-12-04 17:06:59');
INSERT INTO `system_config` VALUES (2, 'max_results_per_user', '3', 'number', '每个用户最多提交的结果数量', '2025-12-04 17:06:59', '2025-12-05 20:02:29');
INSERT INTO `system_config` VALUES (3, 'auto_verify_enabled', 'true', 'boolean', '是否自���验证新提交的结果', '2025-12-04 17:06:59', '2025-12-04 17:06:59');
INSERT INTO `system_config` VALUES (4, 'snapshot_retention_days', '90', 'number', '排行榜快照保留天数', '2025-12-04 17:06:59', '2025-12-04 17:06:59');
INSERT INTO `system_config` VALUES (5, 'site_name', '基准测试评分平台', 'string', '网站名称', '2025-12-04 17:06:59', '2025-12-04 17:06:59');
INSERT INTO `system_config` VALUES (6, 'linuxdo_client_id', '', 'string', 'linux.do OAuth 客户端ID', '2025-12-04 17:06:59', '2025-12-04 17:06:59');
INSERT INTO `system_config` VALUES (7, 'linuxdo_client_secret', '', 'string', 'linux.do OAuth 客户端密钥', '2025-12-04 17:06:59', '2025-12-04 17:06:59');
INSERT INTO `system_config` VALUES (8, 'enable_device_classification', 'true', 'boolean', '是否启用设备类型自动分类', '2025-12-05 20:02:29', '2025-12-05 20:02:29');
INSERT INTO `system_config` VALUES (9, 'device_type_confidence_threshold', '0.7', 'number', '设备类型自动分类的置信度阈值', '2025-12-05 20:02:29', '2025-12-05 20:02:29');
INSERT INTO `system_config` VALUES (10, 'enable_manual_device_type_correction', 'true', 'boolean', '是否允许用户手动修正设备类型', '2025-12-05 20:02:29', '2025-12-05 20:02:29');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'linux.do 用户名',
  `user_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'linux.do 用户ID',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱地址',
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 255 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'wozulong', '14', '1ygw5lf6g3cwyzk3thdmvkostyf0lsi5cb6ngb7nb3upmn8pkw@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wozulong/288/15_2.png', '2025-12-05 00:50:46', '2025-12-08 01:55:36');
INSERT INTO `users` VALUES (2, 'steve5wutongyu6', '65269', 'w4egn7j5uwykcb6locbup065yvpald77j2xxhe8qlljv1heoh@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/steve5wutongyu6/288/928175_2.png', '2025-12-05 00:52:48', '2025-12-07 00:50:32');
INSERT INTO `users` VALUES (3, 'BIN2450', '151600', '2vhhnz29crenwrd8aw3hxb0ktffkj6pxvfd6xvtv3ph3zm7y6u@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/bin2450/288/791610_2.png', '2025-12-05 01:19:37', '2025-12-05 02:12:30');
INSERT INTO `users` VALUES (4, 'Threeau25', '138106', '6ayrw8oerputevi6z2s2sqq9vbbsvt5qfwfx9mrb6blzvx49or@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/threeau25/288/718954_2.png', '2025-12-05 01:21:02', '2025-12-05 01:21:02');
INSERT INTO `users` VALUES (5, 'onewhite', '13210', '1k2jg0sxrhvttzbn37bvnc39p691mlux0oc5bih4f30ds4qts8@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/onewhite/288/22852_2.png', '2025-12-05 01:21:26', '2025-12-05 01:21:26');
INSERT INTO `users` VALUES (6, 'FreedomPanda', '137988', '3bu5olvw6hbar5tkh5t3ipcudjtm35gxsi3iyd5prg5w3zk8p0@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/freedompanda/288/692677_2.png', '2025-12-05 01:21:37', '2025-12-05 01:21:37');
INSERT INTO `users` VALUES (7, 'haorwen', '159865', 'val5ednvsjj0mu65gfz1sub4mgyhtyy897qva7av5jhf1ec9t@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/haorwen/288/1050871_2.png', '2025-12-05 01:24:10', '2025-12-05 01:24:10');
INSERT INTO `users` VALUES (8, 'orangearms', '81937', '4eys3u3oau8mno26dl7yif1dlms81qkbgu7b347ponmfyktxx0@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/orangearms/288/386181_2.png', '2025-12-05 01:24:41', '2025-12-05 01:24:41');
INSERT INTO `users` VALUES (9, 'w928028422', '204452', '4r1vljc729mdllhd6brv61dir9mp3ryndgmgd9bzvx8qpprml3@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/w928028422/288/1171403_2.png', '2025-12-05 01:26:55', '2025-12-05 01:26:55');
INSERT INTO `users` VALUES (10, 'user1647', '151679', '4ql0nhd6il9lk43gja2q9kxejywn7wjba4znb84ryg7b1xl3zm@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/user1647/288/792215_2.png', '2025-12-05 01:32:00', '2025-12-05 01:32:00');
INSERT INTO `users` VALUES (11, 'UwU', '254581', '43zpr12ya4exy8t1yhiy7ite3436mx4b0rqxekd1r09bubdr6r@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/uwu/288/1177948_2.png', '2025-12-05 01:39:59', '2025-12-05 01:39:59');
INSERT INTO `users` VALUES (12, 'Egdon', '107767', 'fy7if52pt3ayr2lrnud8tcumpeoacr2is021y98t3e89h2flb@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/egdon/288/687462_2.png', '2025-12-05 01:40:08', '2025-12-05 01:40:08');
INSERT INTO `users` VALUES (13, 'coderZoe', '34718', '2th3gpd6d9f2zunj37jzda37h7083ln275qtjcvz2eow28rwr7@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/coderzoe/288/522289_2.png', '2025-12-05 01:40:21', '2025-12-05 01:40:21');
INSERT INTO `users` VALUES (14, 'Yuki_28', '139568', '4azp3pbgrkdjiz9t0oft6qugrvaf2ehfut3anewq3vghz3vi1c@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yuki_28/288/721376_2.png', '2025-12-05 01:43:24', '2025-12-05 01:43:24');
INSERT INTO `users` VALUES (15, 'Misunderstood', '3627', 'ggvtrd3dtrsnut25o76lov9ub15nlso8o1g5mrcvzs3ppecym@privaterelay.linux.do', 'https://linux.do/letter_avatar/misunderstood/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 01:46:01', '2025-12-05 01:46:01');
INSERT INTO `users` VALUES (16, 'diffusion', '64215', '5e69dem0ipy9hnpjuoub6ldccztmqcem8dlcoizg83efixsy3e@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/diffusion/288/493124_2.png', '2025-12-05 01:46:29', '2025-12-05 01:46:29');
INSERT INTO `users` VALUES (17, 'Antec', '99408', '49sbhz72526xjgn5gc2bu9lpjle36yl5jk75t3oxqzshkltvih@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/antec/288/441468_2.png', '2025-12-05 01:47:22', '2025-12-05 01:47:22');
INSERT INTO `users` VALUES (18, 'Runtime_error', '120707', '41o2adsibsfp431wbwtuuwigczh9ee5gbdj8okweebjpai5mt5@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/runtime_error/288/1077861_2.png', '2025-12-05 01:48:02', '2025-12-05 01:48:02');
INSERT INTO `users` VALUES (19, 'GoldenZqqq', '104458', '7lnkqneaqaah1bq9xr9wfyxnrq9booc3dx1lkmkwhvxzydw3i@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/goldenzqqq/288/909654_2.png', '2025-12-05 01:48:03', '2025-12-05 01:48:03');
INSERT INTO `users` VALUES (20, 'Shino', '68888', '3r1e4cmwm3dvpqxjswiuh9q4xdyw913m7tulm76ts8p7pwkfhs@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/shino/288/369388_2.png', '2025-12-05 01:48:55', '2025-12-05 01:48:55');
INSERT INTO `users` VALUES (21, 'zhuoshuang', '78440', '2lumxjd9c7o21qhvo1rvr87puspqwqbg6rvjm1rp640lk29p7k@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zhuoshuang/288/588655_2.png', '2025-12-05 01:49:19', '2025-12-05 01:49:19');
INSERT INTO `users` VALUES (22, 'ATRI', '4460', '3p0edwh2ax1d29wji119j9uzkmxqecw4u0b8sr7eyiopoflz5d@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/atri/288/417770_2.png', '2025-12-05 01:52:25', '2025-12-06 04:38:16');
INSERT INTO `users` VALUES (23, 'Leo_xu', '905', 'kn94ojjq3tiqgcn5s5vtlgkdnkve12be9u94zyhgzvoraywv8@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/leo_xu/288/987255_2.png', '2025-12-05 01:53:01', '2025-12-05 01:53:01');
INSERT INTO `users` VALUES (24, 'shen2048', '38607', '50wk47b9uogynhrqqr8wh9qz0fkyopote5ogyx30eygobbdibk@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/shen2048/288/538668_2.png', '2025-12-05 01:53:05', '2025-12-05 01:53:05');
INSERT INTO `users` VALUES (25, 'code0', '21990', '2efa8ibh7mpl1lj32fpk5ssszpck98bl7iixcdwvlrsn3e0wh4@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/code0/288/102509_2.png', '2025-12-05 01:54:00', '2025-12-05 01:54:00');
INSERT INTO `users` VALUES (26, 'smwy', '24475', '5l6ecjr8sumjplox8u0awm7ntbhdwikebebp81apzpc7hlqlcs@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/smwy/288/909990_2.png', '2025-12-05 01:54:59', '2025-12-05 01:54:59');
INSERT INTO `users` VALUES (27, 'fan2016cc', '61025', '69gi25nw6ywjjaworeapd23lu7jtazcmmxwvbrjx9dl78dv1e9@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/fan2016cc/288/397017_2.png', '2025-12-05 01:56:06', '2025-12-05 02:04:27');
INSERT INTO `users` VALUES (28, 'Max1012', '56803', '5rsepg7l26rj61bsb6cdonie2pvwepcex8wmnrz4dgp69s8kzk@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/max1012/288/980864_2.png', '2025-12-05 01:56:45', '2025-12-05 01:56:45');
INSERT INTO `users` VALUES (29, 'Chen10', '82333', '1lsa5p3gkw63kc6m38lhc3a522b12998hrz0tvsaz95c8jab6n@privaterelay.linux.do', 'https://linux.do/letter_avatar/chen10/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 01:58:32', '2025-12-05 01:58:32');
INSERT INTO `users` VALUES (30, 'a-i-r', '60205', '63eil888wt5s6klbr9jg2j6ezqnw74n6czo5bw0igme8u8czos@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/a-i-r/288/193578_2.png', '2025-12-05 01:59:06', '2025-12-05 12:57:47');
INSERT INTO `users` VALUES (31, 'cf123', '15558', 'nbzdw32viyiho1wr8ud4mbfqsexz0qf4pgph88wtgfztqhqg2@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/cf123/288/35273_2.png', '2025-12-05 01:59:56', '2025-12-05 01:59:56');
INSERT INTO `users` VALUES (32, 'ghwolf', '19114', '2lvi7t6f5an097zdgsqd3obfkcuop0gpuk73tl6vqfvov0z5wm@privaterelay.linux.do', 'https://linux.do/letter_avatar/ghwolf/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:00:35', '2025-12-05 02:00:35');
INSERT INTO `users` VALUES (33, 'Yuookie', '139219', '4y03uvhj5tc4m0ow37yge9auo7sda2gxk4zt54vsrvykeh111n@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yuookie/288/704507_2.png', '2025-12-05 02:01:09', '2025-12-05 02:01:09');
INSERT INTO `users` VALUES (34, 'Roy_yu', '196592', '12q9xo9t91au4v4zrf5r6qqal89hpyxcyzn27tocu7e84psz7q@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/roy_yu/288/1083353_2.png', '2025-12-05 02:01:12', '2025-12-05 02:01:12');
INSERT INTO `users` VALUES (35, 'watermelooon', '47840', '2tz51cc628kwl89qne6m6gqz7ls3fhvctfu0v74zeonev04g6r@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/watermelooon/288/129195_2.png', '2025-12-05 02:02:28', '2025-12-05 02:02:28');
INSERT INTO `users` VALUES (36, 'by9858', '42997', '5f8fw0u96iwylq292m524qlfu66mm9iiossz234jivl3m4k28r@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/by9858/288/884402_2.png', '2025-12-05 02:03:38', '2025-12-05 02:03:38');
INSERT INTO `users` VALUES (37, 'ballen', '55138', '5kx6scb2na3u5m855h8b6aukkizgjdtf59tlr1ikajg1x9sx1x@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ballen/288/318657_2.png', '2025-12-05 02:04:38', '2025-12-05 02:04:38');
INSERT INTO `users` VALUES (38, 'liuyd', '19042', '113fpdsb6oh239xlb0n2yyest05vno024t8n4ss82fd7occbtn@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/liuyd/288/537359_2.png', '2025-12-05 02:04:42', '2025-12-05 02:04:42');
INSERT INTO `users` VALUES (39, 'mumu_fly', '279635', '4q69aqmjkthxabk8qizbvr7p0x1ihcquuc7dehf8l3o1d1wmni@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/mumu_fly/288/1225888_2.png', '2025-12-05 02:05:38', '2025-12-05 02:05:38');
INSERT INTO `users` VALUES (40, 'Tully', '22039', 'g0mx9gqsuzsgv1kn8oawunfjvvj5kdkaah3hb3wd1uuddqudz@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tully/288/96348_2.png', '2025-12-05 02:05:39', '2025-12-05 02:05:39');
INSERT INTO `users` VALUES (41, 'tiansonglin', '108808', '5hoq8kl1izqyz23r2qv97jaabyhc73ykw825zvqfar4sxz8jp4@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tiansonglin/288/527404_2.png', '2025-12-05 02:06:00', '2025-12-05 02:25:41');
INSERT INTO `users` VALUES (42, 'Edenn', '141285', 'bz1pdn7f45p651oxriu4a9vnkecjex8l20dbmnrgeogiz5htp@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/edenn/288/729848_2.png', '2025-12-05 02:06:56', '2025-12-05 03:02:55');
INSERT INTO `users` VALUES (43, 'Barrie_Gallagher', '8354', '2b9ozrlij79z8iw1ph979mb4yftah8tiq26hupvd6dj45226k2@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/barrie_gallagher/288/191189_2.png', '2025-12-05 02:07:21', '2025-12-05 02:07:21');
INSERT INTO `users` VALUES (44, 'hf3862', '94314', 'h9eh8t3jbb0881c323gdhok9h882yaj0wlsihc9o8nz2gsnyu@privaterelay.linux.do', 'https://linux.do/letter_avatar/hf3862/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:08:07', '2025-12-06 13:08:22');
INSERT INTO `users` VALUES (45, 'Binbim', '206852', '2x35ue92fq6gjoq0806v8ke2gu4efef2kmn8o51kz901b05xof@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/binbim/288/1034072_2.png', '2025-12-05 02:08:45', '2025-12-05 02:08:45');
INSERT INTO `users` VALUES (46, 'uuuukkkk', '163856', '4ge5jikf9edma4q82ifybywlgk5m6rlddppte85dwaosn71j78@privaterelay.linux.do', 'https://linux.do/letter_avatar/uuuukkkk/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:12:10', '2025-12-05 02:12:10');
INSERT INTO `users` VALUES (47, '8484', '173345', 'nklxi49trdrrtngrmzrcs63k3f1wh3bvpbiokp94na803jjwl@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/8484/288/1106584_2.png', '2025-12-05 02:14:18', '2025-12-05 02:14:18');
INSERT INTO `users` VALUES (48, 'Jayczee', '61338', '6awyl5w9vbswhsu6oiiqx5bisfmpacf1als9uip3rrzdste8bd@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/jayczee/288/702417_2.png', '2025-12-05 02:14:23', '2025-12-05 02:14:23');
INSERT INTO `users` VALUES (49, 'MiiZeus', '227158', '5q2eda3go0aebzazxwftu1bbe1c0805o9px78ebkz5lvlwdtxz@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/miizeus/288/1071846_2.png', '2025-12-05 02:14:57', '2025-12-05 02:51:59');
INSERT INTO `users` VALUES (50, 'ch6vip', '58122', '276j299m0ynkhsifcn2yq0pmt7y7tkyx4kprlpix94czayrf4z@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ch6vip/288/912116_2.png', '2025-12-05 02:15:10', '2025-12-05 02:15:10');
INSERT INTO `users` VALUES (51, 'saiban-kk', '80988', '4lxji8n0n18dam5augl6ifwcbfyei53r41ou025clo5j44y6vx@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/saiban-kk/288/377341_2.png', '2025-12-05 02:15:33', '2025-12-05 02:15:33');
INSERT INTO `users` VALUES (52, 'akin_akin', '281480', '344rhg4t9t06hspfz93rf5u4qm5lvacxwz2hzh4zte5y6t6chf@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/akin_akin/288/1219267_2.png', '2025-12-05 02:18:00', '2025-12-05 02:18:00');
INSERT INTO `users` VALUES (53, 'xiaodong', '19030', '5qntu7syxx4h47vfbhbm8vi4hcrs6wze53ghg3dk4c0cv8ap7p@privaterelay.linux.do', 'https://linux.do/letter_avatar/xiaodong/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:20:18', '2025-12-05 02:20:18');
INSERT INTO `users` VALUES (54, 'linux_hello', '106344', '4bsxncs57e0yi71972lumya69jmg6zrt7pqit1yw19xtj8walt@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/linux_hello/288/666406_2.png', '2025-12-05 02:20:32', '2025-12-05 02:20:32');
INSERT INTO `users` VALUES (55, 'tuan2046', '136318', '4m851a6gl0olp662cxp1n5norr13rfudq5qrtfosj8o2k1rm77@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tuan2046/288/1162242_2.png', '2025-12-05 02:20:47', '2025-12-06 12:03:15');
INSERT INTO `users` VALUES (56, 'AAEE86', '182982', '16t4a8qlyk6umogjxg4q06nc7rzi28jh6ccvo1sgxwpxno4ge@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/aaee86/288/906465_2.png', '2025-12-05 02:20:49', '2025-12-05 02:28:25');
INSERT INTO `users` VALUES (57, 'kbtit_25', '108569', '3rr0qm6tb5f7xoif1epmcphp1y5mq07levqmjo5wwlrxvnsmfq@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/kbtit_25/288/912675_2.png', '2025-12-05 02:21:07', '2025-12-05 02:21:07');
INSERT INTO `users` VALUES (58, 'baifa1916', '64474', '4ua85c93zno4xaciqgsylo3bzzegzev2kqjp1toqpu41lkea4m@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/baifa1916/288/766368_2.png', '2025-12-05 02:21:43', '2025-12-05 02:21:43');
INSERT INTO `users` VALUES (59, 'jeromeleong', '50130', '4qsij80egewg090h8zcj9f7opd9j028zd5r989tws5m5d72av0@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/jeromeleong/288/336333_2.png', '2025-12-05 02:22:59', '2025-12-05 02:22:59');
INSERT INTO `users` VALUES (60, 'blue_num', '95528', '55ai4yxcp4edfpptwb0e8n51cm7up9vut0b3otv7m2iu6kml4e@privaterelay.linux.do', 'https://linux.do/letter_avatar/blue_num/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:23:26', '2025-12-05 02:23:26');
INSERT INTO `users` VALUES (61, 'wendd', '62504', '374kf720xdk2ssh98jt3q12h0uzyv0ymlxrxnm8q1f6r42z9zn@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wendd/288/718509_2.png', '2025-12-05 02:23:28', '2025-12-05 02:23:28');
INSERT INTO `users` VALUES (62, 'ccqc', '14657', 't7hi1mlwn7euzgfwkza2xd55mp4dionqf8doibegflywhxhn9@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ccqc/288/110727_2.png', '2025-12-05 02:24:56', '2025-12-05 02:24:56');
INSERT INTO `users` VALUES (63, 'huajijiaojiaozhu', '58706', '4evrwmbywk48p8t43i1uwu99b1wn6wbdcr1s6fhj9vfys8wvm0@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/huajijiaojiaozhu/288/578309_2.png', '2025-12-05 02:26:51', '2025-12-05 02:26:51');
INSERT INTO `users` VALUES (64, 'munian390', '55167', '218b6v7cuulvdruhpnfr57rvge22c5c26p58ewvhv58m17wso6@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/munian390/288/241957_2.png', '2025-12-05 02:29:37', '2025-12-05 02:29:37');
INSERT INTO `users` VALUES (65, 'ChatGPT', '130', 'l8u94zgqmevpnq4hg6g1il6hr3zxjg0fd67lye4mvo2cxt8vq@privaterelay.linux.do', 'https://linux.do/letter_avatar/chatgpt/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:29:53', '2025-12-05 02:46:06');
INSERT INTO `users` VALUES (66, 'LeonShaw', '7626', '2uncq6i1c3jb5aiewfd7iki339qtlivq4iwpmtxs6037qi6xzj@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/leonshaw/288/20735_2.png', '2025-12-05 02:29:59', '2025-12-05 02:29:59');
INSERT INTO `users` VALUES (67, 'xiaolanshu', '159764', '159qixzqgnowbeswdd0zxq830gsohcuaj8g18fpvvg2bin0439@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xiaolanshu/288/848952_2.png', '2025-12-05 02:37:50', '2025-12-05 02:37:50');
INSERT INTO `users` VALUES (68, 'Oosas', '34091', '1nja007dbgx4ln1mwbl0k4fn3vmhiun0j5q79bop0bmiafhnxp@privaterelay.linux.do', 'https://linux.do/letter_avatar/oosas/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:38:11', '2025-12-05 02:38:11');
INSERT INTO `users` VALUES (69, 'bizhanrensheng', '11033', 'zijnfo7vwf04kzan2jeb9uqenwjqx5hyt9yiv25d4vqntyl16@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/bizhanrensheng/288/536753_2.png', '2025-12-05 02:45:43', '2025-12-05 02:45:43');
INSERT INTO `users` VALUES (70, 'Mrzqd', '1018', '5mvfd6kmm1rr8daufptwjiuquvxzb75p2bjmr9fyooa27z4ia6@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/mrzqd/288/307081_2.png', '2025-12-05 02:48:01', '2025-12-05 02:48:01');
INSERT INTO `users` VALUES (71, 'jamson', '253834', '42zaz2noqhiy6a0nc9swtif6ibzz46bxfs2uia75e03jvdhq3i@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/jamson/288/364905_2.png', '2025-12-05 02:49:06', '2025-12-05 02:49:06');
INSERT INTO `users` VALUES (72, 'kukegogo', '215164', '4lfl19d7se66jzc7pzi7kmcuunsttycsmslm07vcqjq0fhrg8e@privaterelay.linux.do', 'https://linux.do/letter_avatar/kukegogo/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 02:51:21', '2025-12-05 02:51:21');
INSERT INTO `users` VALUES (73, 'fun5572', '35208', '5c2kgsxtnq0rygm6yyfv57t3pcfyhymamz1qwx6ezzi0m324l4@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/fun5572/288/108828_2.png', '2025-12-05 02:51:45', '2025-12-05 02:51:45');
INSERT INTO `users` VALUES (74, 'susliks', '173283', '358xc5wn7hbofp14i1m69v82d3zvtq2xb1xvhiei0xeauqj66a@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/susliks/288/868519_2.png', '2025-12-05 02:53:31', '2025-12-05 02:53:31');
INSERT INTO `users` VALUES (75, 'lihangfu', '18417', '49crsm2mvmndxq2mwr5wwes2ybt45jk3k6mgp0ggt9ulpon6gm@privaterelay.linux.do', 'https://linux.do/letter_avatar/lihangfu/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 03:02:57', '2025-12-05 03:02:57');
INSERT INTO `users` VALUES (76, 'mavjll', '24868', '4crqylrsbcei71zubhtcoofdie65o2nw9vgvuwhj2qt6u4edvi@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/mavjll/288/315143_2.png', '2025-12-05 03:03:19', '2025-12-05 03:03:19');
INSERT INTO `users` VALUES (77, 'Tods', '157565', '9jzykipem3irijozz9tvzk7a98r4eyae4ujw2osb06q7ll7xi@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tods/288/819119_2.png', '2025-12-05 03:04:34', '2025-12-05 03:04:34');
INSERT INTO `users` VALUES (78, 'xrilang', '218320', '31qmrmzbwr1c0bcfpnl5jpg5kcsg8f2ksaospbfz5xhq84b676@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xrilang/288/1045888_2.png', '2025-12-05 03:06:44', '2025-12-05 03:06:44');
INSERT INTO `users` VALUES (79, 'wszszh', '222207', '1hf8zjpfj0nznds18qhw5msus75x5dykxclvxjqc32bumemqe7@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wszszh/288/1057676_2.png', '2025-12-05 03:07:13', '2025-12-05 03:07:13');
INSERT INTO `users` VALUES (80, 'kidsss', '38059', '3lda6wj507kra6gowwr173v77wpqug5ew96nnl6j1auz1bweaq@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/kidsss/288/1156739_2.png', '2025-12-05 03:09:52', '2025-12-05 03:09:52');
INSERT INTO `users` VALUES (81, 'dream_sail', '108886', '1cwtij0u95l87xbxo2aihjtwj2hxm79my0uh0us6u5ew3ywvsd@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/dream_sail/288/741762_2.png', '2025-12-05 03:10:56', '2025-12-05 03:10:56');
INSERT INTO `users` VALUES (82, 'GuYudi', '198113', '3zw14wzuqi00mdexf1s0ba9s7601033h9hor01srps8wmhkkka@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/guyudi/288/1074987_2.png', '2025-12-05 03:11:01', '2025-12-05 03:16:17');
INSERT INTO `users` VALUES (83, 'LRWF', '205354', '1c1u58hj5oidrqmlptibyrstzr50p3l6aszb6jxu2dtidhpmmb@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/lrwf/288/1001278_2.png', '2025-12-05 03:15:00', '2025-12-05 03:15:00');
INSERT INTO `users` VALUES (84, 'Lee7777777', '135487', '1tuv3oibvoe3tmjuqaf8barbmatgxja5eioyg933i1fzkva5su@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/lee7777777/288/911127_2.png', '2025-12-05 03:16:30', '2025-12-05 03:16:30');
INSERT INTO `users` VALUES (85, 'xtatnt', '64241', '1mgld309bjcuqnxfsojrdzo0zxuccriblcwa40ytsh9tac0jdp@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xtatnt/288/332307_2.png', '2025-12-05 03:17:18', '2025-12-05 03:17:18');
INSERT INTO `users` VALUES (86, 'abcdefg', '26494', '3f9a6wx8lwxcu1v8ix0ov12ftwiexqmwubcs3dbc58xwofo5rh@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/abcdefg/288/537923_2.png', '2025-12-05 03:18:40', '2025-12-05 03:18:40');
INSERT INTO `users` VALUES (87, 'Warma10032', '96813', '7v00r88h5l28x2gq0qvv0xs1pp36pfyawprpan9l1eng3lazb@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/warma10032/288/629373_2.png', '2025-12-05 03:19:52', '2025-12-05 03:19:52');
INSERT INTO `users` VALUES (88, 'b1ghawk119', '54048', '33tnogdn2cnetpfz4negope863qctejbs6ht51ftcrqhzl5rlj@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/b1ghawk119/288/1174606_2.png', '2025-12-05 03:21:37', '2025-12-05 03:21:37');
INSERT INTO `users` VALUES (89, 'LingHuChong_01', '266809', '48z9qqljh76oqxws9u9r2f9neoa3uku7cnm0g2h7ytn68n4323@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/linghuchong_01/288/1199373_2.png', '2025-12-05 03:22:05', '2025-12-05 03:22:05');
INSERT INTO `users` VALUES (90, 'Beiling', '76896', '3xmmhnujfyeui5t9nvpgssln4pw0co81gdwzaidhxdkyg87r17@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/beiling/288/370837_2.png', '2025-12-05 03:22:35', '2025-12-05 03:22:35');
INSERT INTO `users` VALUES (91, 'TooAme', '151223', '52udhvvs03nxfz5nauyexyd5hzo9odcg8z32mylttwki96ua0n@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tooame/288/1203886_2.png', '2025-12-05 03:22:39', '2025-12-05 03:22:39');
INSERT INTO `users` VALUES (92, 'BloomD', '21882', '21v70qftae4dzcp8eaq9yvt0ub8ng9od4gpiwmaszkvjdvu75l@privaterelay.linux.do', 'https://linux.do/letter_avatar/bloomd/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 03:23:40', '2025-12-05 03:23:40');
INSERT INTO `users` VALUES (93, 'tipsycheese', '220986', '2v5383vlmnh8y4kw6r8u52hh1sevba7vu1knf3oycqnn8c3lv@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tipsycheese/288/1053874_2.png', '2025-12-05 03:25:02', '2025-12-05 03:25:02');
INSERT INTO `users` VALUES (94, 'Zinc', '18063', 'js1crm0tiu4c9e2e3s7w0659258xakg36vb46h4hu6osxtfay@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zinc/288/1170331_2.png', '2025-12-05 03:26:13', '2025-12-05 03:26:13');
INSERT INTO `users` VALUES (95, 'user1645', '151607', '3m2du6ferhrvqqg9p788w31w91pjrl23171obztdz3piwwhlt9@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/user1645/288/791668_2.png', '2025-12-05 03:32:13', '2025-12-05 03:32:13');
INSERT INTO `users` VALUES (96, 'Aquamarine', '270184', '3a2w8hb17xcdsgszkzcaaocgu8zy85k4kozdeff4f3t9i45ojx@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/aquamarine/288/1215351_2.png', '2025-12-05 03:35:50', '2025-12-05 16:08:14');
INSERT INTO `users` VALUES (97, 'dexter', '270902', '5r8p1h7tnrg0sgzh3q6dtq1vdcda8flaasptxpb5vrtumzehug@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/dexter/288/1207604_2.png', '2025-12-05 03:36:03', '2025-12-05 03:36:03');
INSERT INTO `users` VALUES (98, 'hoping', '13092', 'owexzdp0qnrmpmh58h5zxuwq4qb6vq7ot09g2q3su5z85scmc@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/hoping/288/952866_2.png', '2025-12-05 03:36:58', '2025-12-05 03:36:58');
INSERT INTO `users` VALUES (99, 'cattie', '69243', '2pojvpuj32ewhu2x0gb6lm3tudooowcm4cfd0c9anwx8onl3ch@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/cattie/288/1168614_2.png', '2025-12-05 03:40:29', '2025-12-05 03:40:29');
INSERT INTO `users` VALUES (100, 'GeneYP', '270939', '232cz3byw2jzir4rii7916knkr3t4jnzg75qs8yfx4zdlgzick@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/geneyp/288/1210930_2.png', '2025-12-05 03:41:12', '2025-12-05 03:41:12');
INSERT INTO `users` VALUES (101, 'Madlifer', '51381', '2bmj8llynsdb9gs990vm1ei43gxztas159htnjcygk8wqhr0ta@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/madlifer/288/363771_2.png', '2025-12-05 03:47:46', '2025-12-05 03:47:46');
INSERT INTO `users` VALUES (102, 'Chenyu_Yu', '243920', '453fqxegsliwc0svb93jhypnt2t9defh7yf98zc54bfncpsmoj@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/chenyu_yu/288/363606_2.png', '2025-12-05 03:50:44', '2025-12-05 03:50:44');
INSERT INTO `users` VALUES (103, 'lejav', '240276', '2w9992f7155vrh10jpcnhpm13utv3vxgrgax5ttd2lhlv7engx@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/lejav/288/1108273_2.png', '2025-12-05 03:52:17', '2025-12-05 03:52:17');
INSERT INTO `users` VALUES (104, 'libeal', '147796', 't0g1cny2tv4m6c0nlnvfbedwxpt36sls7ids1m1n9cr10aig7@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/libeal/288/809362_2.png', '2025-12-05 03:52:36', '2025-12-05 03:52:36');
INSERT INTO `users` VALUES (105, 'GoldOring', '221549', '1rulrl287ucrck1wcw1jzvmqvqhesml06t4139zvbgs4c6zo3z@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/goldoring/288/1077919_2.png', '2025-12-05 03:56:07', '2025-12-05 03:56:07');
INSERT INTO `users` VALUES (106, 'QVQZZH', '191838', '399wu62avwlwzx8y3t57jtfdz9ian426o9ruo0anjyg5z81ivu@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/qvqzzh/288/982320_2.png', '2025-12-05 03:57:07', '2025-12-05 03:57:07');
INSERT INTO `users` VALUES (107, 'ljcsnbb', '12174', '5cu55w51230ql98d2w1w35v3tlk98cqssjy3gpsov37ngzn4xv@privaterelay.linux.do', 'https://linux.do/letter_avatar/ljcsnbb/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 04:01:30', '2025-12-05 04:01:30');
INSERT INTO `users` VALUES (108, 'unique-h', '219729', '16ivygzgsuqpj8jls5faov11lf1976ardozzkctdoyi9jlmbh1@privaterelay.linux.do', 'https://linux.do/letter_avatar/unique-h/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 04:07:08', '2025-12-05 04:07:08');
INSERT INTO `users` VALUES (109, 'oocola', '70671', '2agfutwgxq8y976p99xtpdvsvgoa0olipscsy3osb1l9ikafe2@privaterelay.linux.do', 'https://linux.do/letter_avatar/oocola/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 04:14:29', '2025-12-05 04:14:29');
INSERT INTO `users` VALUES (110, 'Evaleanosrey', '145885', '5lpz9uyeqavwkss6bcvi64oetkdq2j2p2ysvs62szvicbcmqpl@privaterelay.linux.do', 'https://linux.do/letter_avatar/evaleanosrey/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 04:20:48', '2025-12-05 04:20:48');
INSERT INTO `users` VALUES (111, 'yunshen', '27550', '1mgvh8y2iyw8sgezmqnnnyo77d9w6s9c763tghzf5he58y59zx@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yunshen/288/895919_2.png', '2025-12-05 04:20:54', '2025-12-05 04:20:54');
INSERT INTO `users` VALUES (112, 'ZKY_DW_Wait_me', '174734', '2g7xq0oj5yb4lmq8qyywr6k41jyupoqgru8744kxmdl4zuv5ab@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zky_dw_wait_me/288/875380_2.png', '2025-12-05 04:30:14', '2025-12-06 00:32:47');
INSERT INTO `users` VALUES (113, 'OneRain233', '60784', '1z35sh79ukl0gb71vukizybp7p1jh3j8l0bnf4p91dlopwyziq@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/onerain233/288/311231_2.png', '2025-12-05 04:36:43', '2025-12-05 04:36:43');
INSERT INTO `users` VALUES (114, 'xueba', '77020', '2a0pyuy02u285ez1wjjfq8z9svxmq2inziu5ej3sa64kvfttxi@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xueba/288/1049361_2.png', '2025-12-05 04:44:42', '2025-12-05 04:44:42');
INSERT INTO `users` VALUES (115, 'Elains', '245426', '4rkilqpo1kovx499vl8dz499ekkbeunxpojmr9kef77go93mug@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/elains/288/381858_2.png', '2025-12-05 04:45:01', '2025-12-05 04:45:01');
INSERT INTO `users` VALUES (116, '4242', '147746', 'h4260msxeh99vaw6g0jhgz74bxrtghplr368fiecqtn83i5x6@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/4242/288/1022839_2.png', '2025-12-05 04:51:17', '2025-12-05 04:51:17');
INSERT INTO `users` VALUES (117, 'vrt', '35090', '5vu7gfowbol4las2ln911xr5bolj712tzarhku8hqpmm4fzqw3@privaterelay.linux.do', 'https://linux.do/letter_avatar/vrt/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 05:02:16', '2025-12-05 05:02:16');
INSERT INTO `users` VALUES (118, 'nivalxer', '173396', 'vw0lvw06nn0mzgqkcggpzqzqtyzru5b7chtls6eccyq8we51@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/nivalxer/288/868433_2.png', '2025-12-05 05:02:34', '2025-12-05 05:02:34');
INSERT INTO `users` VALUES (119, '02ttt', '282101', '29v51x4niir2b7ji0rolqr955evdz15ejz9emy1s7j7mp8pmmr@privaterelay.linux.do', 'https://linux.do/letter_avatar/02ttt/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 05:10:00', '2025-12-05 05:10:00');
INSERT INTO `users` VALUES (120, 'x76yyy', '190152', '10rtknbjp7wut2rxmq7g46iyvejuec5ir1uurqw3m3npjara8v@privaterelay.linux.do', 'https://linux.do/letter_avatar/x76yyy/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 05:11:31', '2025-12-05 05:11:31');
INSERT INTO `users` VALUES (121, 'cch_jcc', '9722', '6bjx221mig6uqwlu0woyo75lm54f93o9mq1ji5qmzjsiymzeou@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/cch_jcc/288/910880_2.png', '2025-12-05 05:14:37', '2025-12-05 05:14:37');
INSERT INTO `users` VALUES (122, 'Ningx', '142149', '3rpubpizdektywche0gu06ylsg70fbhq4l1okg7jes99cizk8z@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ningx/288/816636_2.png', '2025-12-05 05:19:43', '2025-12-05 05:19:43');
INSERT INTO `users` VALUES (123, 'ius', '4879', '2xhe1p6tifox4ia7xjv2fdvrui0y7g7ihx1qxq8c6e2yf400lb@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ius/288/5982_2.png', '2025-12-05 05:19:46', '2025-12-05 05:19:46');
INSERT INTO `users` VALUES (124, 'arch_linux', '188415', '5lyzlb2u3cdgj6acoefuyqkuz71sb68723ub6krzozqar1hipq@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/arch_linux/288/1176724_2.png', '2025-12-05 05:20:20', '2025-12-05 05:20:20');
INSERT INTO `users` VALUES (125, 'user_code-cli', '225874', '3pmvea7aaa3eadjjjpr1g342mudoetny5hmm97bzxb9ylt45kd@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/user_code-cli/288/1068081_2.png', '2025-12-05 05:22:01', '2025-12-05 05:22:01');
INSERT INTO `users` VALUES (126, 'super3', '181599', 'tncepc7tpx60vyq77o5opnt1b5752mf6vqekix6h9oi8r1ep3@privaterelay.linux.do', 'https://linux.do/letter_avatar/super3/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 05:24:25', '2025-12-05 05:24:25');
INSERT INTO `users` VALUES (127, 'yuyi233', '160826', '210sfkvrei2l7b4b7fq7n03xmt4ctxe3fjsctx9inwc437qobp@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yuyi233/288/1164058_2.png', '2025-12-05 05:26:30', '2025-12-05 05:26:30');
INSERT INTO `users` VALUES (128, 'chuhe', '217069', '61vzizaigoztjy07kdfej81wkwln7tqv2bwuujfb8o7tklfem@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/chuhe/288/1046242_2.png', '2025-12-05 05:28:40', '2025-12-05 05:28:40');
INSERT INTO `users` VALUES (129, 'dunxuan', '76698', '2hvg2cpgxv8hdnnlfhmflj4uk9xtbyj8618efx9sbkuupxx11y@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/dunxuan/288/370500_2.png', '2025-12-05 05:29:20', '2025-12-05 05:29:20');
INSERT INTO `users` VALUES (130, 'alejand', '281432', '4yc59qh7zlx8a2c634ug0u1l4jkhgccs6f9divzirajizr46r6@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/alejand/288/1225087_2.png', '2025-12-05 05:36:21', '2025-12-05 05:36:21');
INSERT INTO `users` VALUES (131, 'Yukari_xvll', '205401', '260oz0zof9zo9r0r2cjmjph5uh5tg3vapc6afqau5q6qzksvea@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yukari_xvll/288/1177321_2.png', '2025-12-05 05:38:21', '2025-12-05 05:38:21');
INSERT INTO `users` VALUES (132, 'doSth', '87038', '4v44rb6roto3lscuo2gnw74xc7g4ezyzuvof5kgqa6mk8j9xw5@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/dosth/288/724832_2.png', '2025-12-05 05:39:27', '2025-12-05 05:39:27');
INSERT INTO `users` VALUES (133, 'lusheng', '17304', '5txz1cy3q05gizk69nlw61z46uocmfjq48hafobdkw3rs8izfk@privaterelay.linux.do', 'https://linux.do/letter_avatar/lusheng/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 05:39:46', '2025-12-05 05:39:46');
INSERT INTO `users` VALUES (134, 'HALOGOGO', '169329', '2ft7t021agmrj5aktk5q0bnu24gbe4dur4f609t8m60w1sufia@privaterelay.linux.do', 'https://linux.do/letter_avatar/halogogo/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 05:41:10', '2025-12-05 05:41:10');
INSERT INTO `users` VALUES (135, 'wycccc', '219323', '2v9mxy2idf5lyxsmcltct1niaaz4op0k8l47s4gunpjxdy3oap@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wycccc/288/1051774_2.png', '2025-12-05 05:41:53', '2025-12-05 05:41:53');
INSERT INTO `users` VALUES (136, 'FFattiger', '64725', '21k3miw1x5dusae2e1l41z8juboczr4db384q0e6blkxhjssrq@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ffattiger/288/471115_2.png', '2025-12-05 05:46:05', '2025-12-05 05:46:05');
INSERT INTO `users` VALUES (137, 'Usagi', '51838', '4vogj2h15io1sfjrncvy7x4ydilibc0rstm3ifkb3lj5ujnh5s@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/usagi/288/206293_2.png', '2025-12-05 05:53:15', '2025-12-05 05:53:15');
INSERT INTO `users` VALUES (138, 'ocean-zhc', '243614', '3idg7qkuq40s2o6l0uz2fugyare18qgwpf938j4vyp3barivqq@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ocean-zhc/288/1114472_2.png', '2025-12-05 05:54:55', '2025-12-05 05:54:55');
INSERT INTO `users` VALUES (139, 'tonyjun', '80687', '4glzqqkq5at8id2pu8g8wd7k5tsstehb4evuhcsv3iydx9lcl2@privaterelay.linux.do', 'https://linux.do/letter_avatar/tonyjun/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 05:55:42', '2025-12-05 16:17:31');
INSERT INTO `users` VALUES (140, 'XiangGuo', '17686', 'ayh1sn60oroslr63xu9lm96qhwx8yu5slolwy9n4zl5shkyiy@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xiangguo/288/175178_2.png', '2025-12-05 05:59:31', '2025-12-05 05:59:31');
INSERT INTO `users` VALUES (141, 'Reroaden', '149380', '5jwqe23gb3h64di36iniiy0rw2z4l2d6p4m0wujigb6knnrb4r@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/reroaden/288/903271_2.png', '2025-12-05 06:00:29', '2025-12-05 06:00:29');
INSERT INTO `users` VALUES (142, 'Neuroplexus', '66174', '6lacdx0za88terif11627lb0u1agj5bemx11gqc5srjx7f1kx@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/neuroplexus/288/917399_2.png', '2025-12-05 06:01:23', '2025-12-05 06:01:23');
INSERT INTO `users` VALUES (143, 'Kepy909', '188667', '2g3x13r0nd8pgk9slfmkw3ugpptod93dqcndxwkavxf0t4ocou@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/kepy909/288/1105028_2.png', '2025-12-05 06:02:45', '2025-12-05 06:02:45');
INSERT INTO `users` VALUES (144, 'nick1', '27772', 'bgy6l3581lwo25vme90kfytc6sdvwj8vwzng0gxs67okcgiya@privaterelay.linux.do', 'https://linux.do/letter_avatar/nick1/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 06:07:37', '2025-12-05 06:07:37');
INSERT INTO `users` VALUES (145, 'wangdakee', '207275', '3k58kc3ru5y49ht9pkkk8mzvgjqe8w43mjxn8nl6r6ft49rtnj@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wangdakee/288/1010192_2.png', '2025-12-05 06:15:55', '2025-12-05 06:15:55');
INSERT INTO `users` VALUES (146, 'jhhgiyv', '714', '1a14sjednwgo32nwbf24u6ailpp7hyxfru7q81fij79ugs56sc@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/jhhgiyv/288/734_2.png', '2025-12-05 06:29:26', '2025-12-06 06:14:39');
INSERT INTO `users` VALUES (147, 'Ykuee', '60934', '462bruxvdf3e5g79sgxm113ctyi2r896sfg9q8dligss9crl8j@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ykuee/288/540102_2.png', '2025-12-05 06:30:13', '2025-12-05 06:30:13');
INSERT INTO `users` VALUES (148, 'yc_z', '95842', '3mve4w27yuq8bdfvz4rxb5q4ov6sxza36693jylrftef25xepm@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yc_z/288/534088_2.png', '2025-12-05 06:30:23', '2025-12-05 06:30:23');
INSERT INTO `users` VALUES (149, 'user498', '10725', '1o4fd4ohxlsvy3qqk2yvbdccjx75da3x6bfta9ouf4zow4w7cm@privaterelay.linux.do', 'https://linux.do/letter_avatar/user498/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 06:30:59', '2025-12-05 06:30:59');
INSERT INTO `users` VALUES (150, 'klbq', '138384', '2eldfd7jnsmk53izlwz42b2qdvzx1r0moopvz7v3ovjpnxwbob@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/klbq/288/739002_2.png', '2025-12-05 06:31:00', '2025-12-05 06:31:00');
INSERT INTO `users` VALUES (151, 'SumizomeAi', '265964', '10h7n84z4571j85w7eux7gs22gmhg7emaifqf2f0p9yduoqcs@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/sumizomeai/288/1193554_2.png', '2025-12-05 06:32:30', '2025-12-05 06:32:30');
INSERT INTO `users` VALUES (152, 'codedogQBY', '103226', '3ttc2pv56rvshux2c2jto4f1gaotkne8xgv55ox9m9ei3yzbqe@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/codedogqby/288/462805_2.png', '2025-12-05 06:36:58', '2025-12-05 06:36:58');
INSERT INTO `users` VALUES (153, 'aiyaya1006', '196333', '311u8renwnkjkohdo7yadv8y1kch58h9l2p215roxcbr7p6fve@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/aiyaya1006/288/1135333_2.png', '2025-12-05 06:37:07', '2025-12-05 06:37:07');
INSERT INTO `users` VALUES (154, 'user695', '45280', '5sxlb6hgm4zbdr70dn8s5a07pto6qeag9ci5w1w60ipgzytwc7@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/user695/288/306859_2.png', '2025-12-05 06:40:52', '2025-12-05 06:40:52');
INSERT INTO `users` VALUES (155, 'nonoone', '16611', '6cdz3frqigb4esgemrwrbnrsslwdhr549w1iev6ei78pt1yr19@privaterelay.linux.do', 'https://linux.do/letter_avatar/nonoone/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 06:50:09', '2025-12-05 06:50:09');
INSERT INTO `users` VALUES (156, 'rty813', '77018', '26rgwdqfq9pown9uvdmejdpgb3gzu637gqq354sjpokh6xkuy9@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/rty813/288/377146_2.png', '2025-12-05 06:51:52', '2025-12-05 06:51:52');
INSERT INTO `users` VALUES (157, 'wuan', '56645', 'zfa2orxmte3q603w9jidn314dp4l0aywqbeqv0r8k0p5fsagw@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wuan/288/539739_2.png', '2025-12-05 06:52:37', '2025-12-05 06:52:37');
INSERT INTO `users` VALUES (158, 'fcanlnony', '157490', '50wpss506oezyan43diz73k2dm23v1f93bx77fcp2ln5epl2h3@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/fcanlnony/288/1130536_2.png', '2025-12-05 06:53:12', '2025-12-05 06:53:12');
INSERT INTO `users` VALUES (159, 'think960', '205834', '5ii6q60yj21azfsbjh2060g5d0xc4k0hbr3jqp6ylcpz4mpbqu@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/think960/288/1076850_2.png', '2025-12-05 07:08:52', '2025-12-05 07:08:52');
INSERT INTO `users` VALUES (160, '555hai', '186105', '3c6dd9mmn1xecicuxsrqfuex6e320iv9alpd0v09zcix50zua2@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/555hai/288/921191_2.png', '2025-12-05 07:12:07', '2025-12-06 03:41:28');
INSERT INTO `users` VALUES (161, 'gyxsama', '23943', '2slf572hoffmaks0myvt81zppa47hlg9o24ykrfiqxwayagb97@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/gyxsama/288/671900_2.png', '2025-12-05 07:15:15', '2025-12-05 07:15:15');
INSERT INTO `users` VALUES (162, 'qntm', '142964', '1gzoe92cmdwzps3ozhbz0xjd5ad6a391gqwkxb4crn3ncyu2d8@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/qntm/288/738653_2.png', '2025-12-05 07:18:10', '2025-12-05 07:18:10');
INSERT INTO `users` VALUES (163, 'boliliu', '235342', '3cjwlsj14cq1ia71mbdxd4k97z6mybdgoaegv9gru1temvwnqe@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/boliliu/288/1224341_2.png', '2025-12-05 07:19:47', '2025-12-05 07:19:47');
INSERT INTO `users` VALUES (164, 'RyanStarFox', '227958', '69ox3cuwjrmanlzyk9lj2s82iv5kpd4ypi4n7axzlc3dbrvh6y@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ryanstarfox/288/1075018_2.png', '2025-12-05 07:24:30', '2025-12-05 07:24:30');
INSERT INTO `users` VALUES (165, 'leitianyu999', '165365', 'wl6ag3vsdwkb5ao50ai4podmsmzslexwqvhakbcp3c58euael@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/leitianyu999/288/841603_2.png', '2025-12-05 07:24:32', '2025-12-05 07:24:32');
INSERT INTO `users` VALUES (166, 'zj.z', '137751', '5a77xgat8igm0e70vgb56g4pm2vqu80qgazwg0svlql5wxh5vl@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zj.z/288/1127599_2.png', '2025-12-05 07:27:43', '2025-12-05 07:27:43');
INSERT INTO `users` VALUES (167, 'agromgt', '18163', '4bsvfa6whogle2li1hgfgwxurxtb9qrhfhi7wgib8cutveeqqb@privaterelay.linux.do', 'https://linux.do/letter_avatar/agromgt/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 07:30:36', '2025-12-05 16:22:32');
INSERT INTO `users` VALUES (168, 'alisws', '15940', '5xj5u79qc8q2sx8d62s3hasxqep3ulhmk1kdf5ysyl8sifyx6x@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/alisws/288/435207_2.png', '2025-12-05 07:31:16', '2025-12-05 07:31:16');
INSERT INTO `users` VALUES (169, 'xyl', '151448', '5dhl9hx0pkpuczfagyvebgi5vhrqy2qkr4ivpg8tnms7wemmob@privaterelay.linux.do', 'https://linux.do/letter_avatar/xyl/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 07:32:53', '2025-12-05 07:32:53');
INSERT INTO `users` VALUES (170, 'flyingcoding', '216206', '24cnjfzrd0nhziuyepywfazzjc8xnawmm17l2mh6089v9pazb6@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/flyingcoding/288/1038648_2.png', '2025-12-05 07:35:49', '2025-12-05 07:35:49');
INSERT INTO `users` VALUES (171, 'wangzai', '3551', '5rl4x486tkyk4oc7qmq0ag52j6b5w7e3zvjg874kecnkzod8ih@privaterelay.linux.do', 'https://linux.do/letter_avatar/wangzai/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 07:35:58', '2025-12-05 07:35:58');
INSERT INTO `users` VALUES (172, 'nbb', '19779', 'nwb98aw4x09wb4s9es86yt023tlk68o5v3mkh96swypfyrynl@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/nbb/288/107542_2.png', '2025-12-05 07:46:28', '2025-12-05 07:46:28');
INSERT INTO `users` VALUES (173, 'jorn_lin', '201651', 'zaj7qmk07bexpe9dmjmmm5dwcv2t2b71yofymu23xmlqijewt@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/jorn_lin/288/1021556_2.png', '2025-12-05 07:50:52', '2025-12-05 07:50:52');
INSERT INTO `users` VALUES (174, 'chnhjf', '101906', 'njf7haycz1el6o808n4zqhhm2nm0xmezzuyjhq1857hp3m8e2@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/chnhjf/288/669949_2.png', '2025-12-05 07:53:16', '2025-12-05 07:53:16');
INSERT INTO `users` VALUES (175, 'mumujie', '115522', '69e5igiro2ocv977lcva5dmylplcxq41qi01ufpyb9ibdmj23d@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/mumujie/288/932370_2.png', '2025-12-05 07:56:22', '2025-12-05 07:56:22');
INSERT INTO `users` VALUES (176, 'SKT.Shinyruo', '182704', '43mr26a48m1z62lhtod0xxj40eyus3c5eg3gwsimnmw8wgq54f@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/skt.shinyruo/288/1042868_2.png', '2025-12-05 08:04:20', '2025-12-05 08:04:20');
INSERT INTO `users` VALUES (177, 'ndllz', '8590', 'azd02pkpodkuhiktxo6ydnfk4pehgpuivdxtxchitrnwm8810@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ndllz/288/547691_2.png', '2025-12-05 08:06:45', '2025-12-05 08:06:45');
INSERT INTO `users` VALUES (178, 'magot', '18488', '1pl707b3l3s9dfviqcyvyxu6xg9l0sgu9wj9f7rk1j7m4jwvc6@privaterelay.linux.do', 'https://linux.do/letter_avatar/magot/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 08:12:43', '2025-12-05 08:12:43');
INSERT INTO `users` VALUES (179, 'mvec', '4353', '47av83j5wm7at1maxbe84vlf7ym9x9328o3bwgfiyoi6pgr3tt@privaterelay.linux.do', 'https://linux.do/letter_avatar/mvec/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 08:13:04', '2025-12-05 08:13:04');
INSERT INTO `users` VALUES (180, 'snowedd', '9339', '1yxjtzbp24wq3vxvfs1t918so797zr5d34pxqkkm7s1jj8v8g9@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/snowedd/288/13773_2.png', '2025-12-05 08:16:31', '2025-12-05 08:16:31');
INSERT INTO `users` VALUES (181, 'yol1', '22791', '1h5hvufnaq5cfdonwv901a6z4ao0nvhj4awsf0bvybsjwppzrx@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yol1/288/56818_2.png', '2025-12-05 08:37:25', '2025-12-05 08:37:25');
INSERT INTO `users` VALUES (182, 'Kimi', '16440', '56fju4m1n5bo1zf5kqn26cbohhsz75fcjeed78nmtkvggcnyns@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/kimi/288/34069_2.png', '2025-12-05 08:58:27', '2025-12-05 08:58:27');
INSERT INTO `users` VALUES (183, 'KGadfly', '200167', '6muswi3m6o452epueddz0o6z4b05tj2v85ovdmaj5f168xtb7@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/kgadfly/288/370311_2.png', '2025-12-05 08:58:29', '2025-12-05 08:58:29');
INSERT INTO `users` VALUES (184, 'GG_Bond', '60715', '4hmwwflus5jndbvj7cckswqqtf3rvij9wv8c324sjj5fc7l3lm@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/gg_bond/288/298157_2.png', '2025-12-05 09:55:49', '2025-12-05 09:55:49');
INSERT INTO `users` VALUES (185, 'Handsomedog', '280983', '28j0dkts3afofmrt7f2v2vye79z6mxihjruk7lfowhorodd3p2@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/handsomedog/288/1202467_2.png', '2025-12-05 10:57:37', '2025-12-05 10:57:37');
INSERT INTO `users` VALUES (186, 'journey-ad', '17577', '2l6p2n3qenn1cijopaycxgp8djt221kx1ww0k0ndktu1ex0ymr@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/journey-ad/288/38703_2.png', '2025-12-05 11:32:13', '2025-12-05 11:32:13');
INSERT INTO `users` VALUES (187, 'a156176', '9619', '5jowbz7dn4tnvck2aretv6he6hn0u4ryqhqrsmwp4ro3kq5srt@privaterelay.linux.do', 'https://linux.do/letter_avatar/a156176/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 12:28:18', '2025-12-05 12:28:18');
INSERT INTO `users` VALUES (188, 'dangerous_nagisa', '205454', '22nwf2w6d3sbnzbr73iwru5pcos53lbqmp1bdt1l0dgx3rldvw@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/dangerous_nagisa/288/1002098_2.png', '2025-12-05 12:47:24', '2025-12-05 12:47:24');
INSERT INTO `users` VALUES (189, 'simonth', '175997', '1a4nvhbv3mje46oq9m8b4qfwbwguzua8fgtcdwmtzy58qjlr09@privaterelay.linux.do', 'https://linux.do/letter_avatar/simonth/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 12:51:08', '2025-12-05 12:51:08');
INSERT INTO `users` VALUES (190, 'Tom_Jerry', '248233', '3m0vf1xiqwxpb6si9z66d9fadgmigtkysgp0jd3t3g450w3ary@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tom_jerry/288/596016_2.png', '2025-12-05 12:51:48', '2025-12-05 12:51:48');
INSERT INTO `users` VALUES (191, 'isKEKE', '21386', '3s8udajof83vh5zp318rrb5bmqgmua2q3nji82zohteakzjten@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/iskeke/288/537525_2.png', '2025-12-05 12:57:51', '2025-12-05 12:57:51');
INSERT INTO `users` VALUES (192, 'boxxd', '238792', '59rklpwt39ct5s4z1yp9qmqrdta9zmjhozcw8humiaq6ndvelw@privaterelay.linux.do', 'https://linux.do/letter_avatar/boxxd/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-05 13:01:25', '2025-12-05 13:01:25');
INSERT INTO `users` VALUES (193, 'chenxbbb', '215174', '1lyf0edxpqz4bwd8xsj28j2pri6psbffipvna60uedd2t05odj@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/chenxbbb/288/1143250_2.png', '2025-12-05 13:16:56', '2025-12-05 17:12:15');
INSERT INTO `users` VALUES (194, 'bingfengfeifei', '87508', '1158ujwcsl2u8vxte7g61b1wh93o528decci7143x5owmz7kes@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/bingfengfeifei/288/521152_2.png', '2025-12-05 13:48:07', '2025-12-05 13:48:07');
INSERT INTO `users` VALUES (195, 'Daertard', '106614', '1wwrqacske6mbxr8l4yagk2kg9g9rvvtusi91vl3x6xn4ocwh0@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/daertard/288/545665_2.png', '2025-12-05 14:02:38', '2025-12-05 14:02:38');
INSERT INTO `users` VALUES (196, 'AsherL1n', '140148', '3cc4ftlx23qt4496jahqz0x9y6d6brepwv4up5ze35m9gyk7ka@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/asherl1n/288/712762_2.png', '2025-12-05 14:03:42', '2025-12-05 14:03:42');
INSERT INTO `users` VALUES (197, 'youyi1314', '8041', '693uftp8b0cw46wv5w1ez682sm3wc49nved6oma18pxxge4av3@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/youyi1314/288/23949_2.png', '2025-12-05 14:20:07', '2025-12-05 14:20:07');
INSERT INTO `users` VALUES (198, 'wanfengp', '197739', 'mlix7xxv2z5yuzdp7t8j0swbdpo4w44oyyjubrtvc7lkc5bt0@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wanfengp/288/1009695_2.png', '2025-12-05 14:24:05', '2025-12-05 14:24:05');
INSERT INTO `users` VALUES (199, 'Murasame', '2445', '2tjleo8we8llqwdixvivdgdry7mmdec2qq5ilmlayqorfjjart@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/murasame/288/1067671_2.png', '2025-12-05 14:35:59', '2025-12-05 15:48:20');
INSERT INTO `users` VALUES (200, 'Einzieg', '194977', '2ee2zciuery8wsfqmjyr4g5211xsdvkmb7sgmytlmoj04ay0ud@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/einzieg/288/961124_2.png', '2025-12-05 14:42:08', '2025-12-05 15:33:40');
INSERT INTO `users` VALUES (201, 'ImKK', '122591', '629a448d9qlszdwna0prw6njnixfull0r9oamdxbiqr2hr2dya@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/imkk/288/572046_2.png', '2025-12-05 14:45:35', '2025-12-05 14:45:35');
INSERT INTO `users` VALUES (202, 'zetaloop', '9855', '53hr4njh9i3u6q2r2wbro66y1r7f15131img7vjab5veqgqe9c@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zetaloop/288/1206299_2.png', '2025-12-05 14:57:21', '2025-12-05 14:57:21');
INSERT INTO `users` VALUES (203, '1157', '151277', '4mfoczz965649n9sazfo1fosws5sja3o83e7suncxnm6qr6ti8@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/1157/288/789347_2.png', '2025-12-05 15:04:14', '2025-12-05 15:04:14');
INSERT INTO `users` VALUES (204, 'xiaolan2_y', '224825', '4hs86v3isjd2wcx2y709u7o4bz8bxjvo4nnsqkirwtnhy5sh49@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xiaolan2_y/288/1065303_2.png', '2025-12-05 15:08:04', '2025-12-05 15:08:04');
INSERT INTO `users` VALUES (205, 'ztt', '77126', '5a2sqqhusfipplu8t9v80ps0qz9p0wi0fmsyv2jwuqglx1hohe@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ztt/288/371022_2.png', '2025-12-05 15:21:10', '2025-12-05 15:21:10');
INSERT INTO `users` VALUES (206, 'user3009', '241168', '5lh1frurezqs9r0lwcpfhjtl2z9dg0qqzqetno54w43i28f22z@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/user3009/288/1182805_2.png', '2025-12-05 15:36:38', '2025-12-05 15:36:38');
INSERT INTO `users` VALUES (207, 'kedou', '177014', '1uiko50dw9ufkbbxvsf4lmzug1vpdq59jgdj4go320lx0629ue@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/kedou/288/1146557_2.png', '2025-12-05 16:12:10', '2025-12-05 16:12:10');
INSERT INTO `users` VALUES (208, 'randname', '89953', '1g637cmigdxbx4vbmfgytovkw7mi5246dr47i5boq4uhs4vg9p@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/randname/288/1031314_2.png', '2025-12-05 16:29:44', '2025-12-05 18:18:49');
INSERT INTO `users` VALUES (209, 'darkkid', '183161', 'k89n589k7c1jzaow40mf2g3ao8mlkenzdhybdef8kru0s4wnh@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/darkkid/288/907037_2.png', '2025-12-05 16:32:31', '2025-12-05 16:33:27');
INSERT INTO `users` VALUES (210, 'ttaox', '253351', '38xux0g3zu3x4xnaz5qjdxx1m59nu7qy4prgkqpsp68bfbstig@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ttaox/288/1156735_2.png', '2025-12-05 16:47:59', '2025-12-05 16:47:59');
INSERT INTO `users` VALUES (211, 'ipi', '183565', '2fzz48w951xta0m8pe4um85x7std56oq78jogiylakld1jsocc@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/ipi/288/909692_2.png', '2025-12-05 16:49:05', '2025-12-05 16:49:05');
INSERT INTO `users` VALUES (212, 'moulai', '90271', '2rvfrhx7voteqvdcergq7ltoxhcnp6wcxejm0so34kxv424qh@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/moulai/288/688591_2.png', '2025-12-05 16:51:58', '2025-12-05 16:51:58');
INSERT INTO `users` VALUES (213, 'xyjoey', '6978', '3fzfalx2uuj2nie576sb69w47i44yg0sbs5026428v6kxenth2@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xyjoey/288/9702_2.png', '2025-12-05 17:09:52', '2025-12-05 17:09:52');
INSERT INTO `users` VALUES (214, 'failed-to-load', '224144', '2v21ya853wq3kvgv64jrs8rr7x0eu28kxjn1rqkll6skd5vhd7@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/failed-to-load/288/1173513_2.png', '2025-12-05 23:43:16', '2025-12-06 10:47:16');
INSERT INTO `users` VALUES (215, 'Perry', '53314', '202o0vpwm5muni1gutqaxyydk06hgolyexgin8j5qfaqau3b4b@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/perry/288/292772_2.png', '2025-12-06 00:02:57', '2025-12-06 00:02:57');
INSERT INTO `users` VALUES (216, 'hansson', '10804', '51h6to7mc1x1fadka68nqbniz9fvhpphv3wytymfhcd4nywn8v@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/hansson/288/806232_2.png', '2025-12-06 00:16:58', '2025-12-08 01:18:49');
INSERT INTO `users` VALUES (217, 'sugar404', '5504', '33rrr2zt6kokueoh673a4e14q88k0dgqvzbj8meq5bm0pyk5oy@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/sugar404/288/536488_2.png', '2025-12-06 01:12:06', '2025-12-06 01:12:06');
INSERT INTO `users` VALUES (218, 'xzygreen', '48202', '4kdyk1bynr6j9wlp1h16jfrhtttonq5z9cgdc8iahw8ghv0vuz@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xzygreen/288/926079_2.png', '2025-12-06 02:18:49', '2025-12-07 06:08:30');
INSERT INTO `users` VALUES (219, 'Liebesleid', '10883', '3qypqpz245rof6cayk44l2sohkqts7yzbj2w1ncgp17su5vqua@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/liebesleid/288/1120926_2.png', '2025-12-06 02:58:05', '2025-12-06 02:58:05');
INSERT INTO `users` VALUES (220, '1593109259', '60686', 'gd1vy8im5puf1ebwz8o4nujtkzmb42sxlqspzc1yfh8p68fg1@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/1593109259/288/540079_2.png', '2025-12-06 03:12:41', '2025-12-06 03:12:41');
INSERT INTO `users` VALUES (221, 'PDLAOZEI', '183687', '66zf6liyff4xl09fbdk1xu65fqlc4nr0krh23ay9q3evi0gkls@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/pdlaozei/288/909400_2.png', '2025-12-06 03:27:43', '2025-12-06 03:27:43');
INSERT INTO `users` VALUES (222, 'Q_Sep_25', '73628', '2orlle6m8zbv01zzwnjql0dfn3w5zpdk7dfqenvawt5h82z606@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/q_sep_25/288/892772_2.png', '2025-12-06 03:47:52', '2025-12-06 03:47:52');
INSERT INTO `users` VALUES (223, 'ArchmageJu', '189832', '13ix2viyct4z0iv5dgt92dclepsav8vxgcuj8iti98bueorau4@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/archmageju/288/936214_2.png', '2025-12-06 03:58:12', '2025-12-06 03:58:12');
INSERT INTO `users` VALUES (224, 'wuya985472988', '63720', 'c031fi81saehpecxoxno75i1ooawtd0xjx4vigfhpuft289w3@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/wuya985472988/288/348375_2.png', '2025-12-06 04:02:50', '2025-12-06 04:03:11');
INSERT INTO `users` VALUES (225, 'TTTEST', '217177', '3cq51eui9kpyvka84si0otzn6kld666x6qac0kqawtn3w4qkvn@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/tttest/288/1092051_2.png', '2025-12-06 04:05:59', '2025-12-06 04:05:59');
INSERT INTO `users` VALUES (226, 'hui_662', '151141', '65j8by196d7udat9543fry6lrmztx6m4lw9dpdqjgwolaokro8@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/hui_662/288/1173771_2.png', '2025-12-06 04:06:54', '2025-12-06 04:06:54');
INSERT INTO `users` VALUES (227, 'Arxedd', '49508', 'un8qywgtsvyskb9x7u4yi6gh88hm3n2wq3xpxtva7qkadommu@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/arxedd/288/539067_2.png', '2025-12-06 06:45:12', '2025-12-06 06:45:12');
INSERT INTO `users` VALUES (228, 'cliff_falling', '261270', 'n68d2rhr76pezuywmoxskemvx5bwxon2x5c1pdzt067thy1ew@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/cliff_falling/288/1182555_2.png', '2025-12-06 06:46:02', '2025-12-06 06:46:02');
INSERT INTO `users` VALUES (229, 'unclesamo', '3711', '12q2jwvzqcuea01khv24c6b1o8i8o5mbizvyi1hmnwc45u18lu@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/unclesamo/288/4605_2.png', '2025-12-06 06:47:32', '2025-12-06 06:47:32');
INSERT INTO `users` VALUES (230, 'somnambulating', '138611', '3x8iyfelm4zit2vvy79jrocelt98qwspuowj5jkpjk8bqi1xea@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/somnambulating/288/990066_2.png', '2025-12-06 06:54:13', '2025-12-06 06:54:13');
INSERT INTO `users` VALUES (231, 'mimosa', '66424', '3nalyf0z9eug179m61ybbxjwgouofemq9b5lrwfqu7p4dn4fb6@privaterelay.linux.do', 'https://linux.do/letter_avatar/mimosa/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-06 06:58:16', '2025-12-06 06:58:16');
INSERT INTO `users` VALUES (232, 'atopos31', '96067', '5sryh7dosvos66k685kd6bxtb5o1b8377ew5uitlqjundk65bt@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/atopos31/288/427525_2.png', '2025-12-06 07:22:43', '2025-12-06 07:22:43');
INSERT INTO `users` VALUES (233, 'Timmyzzo', '169544', '3rpubpizdektywche0gu06ylsdqwvra6uz7hx03nz92qmnzgzk@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/timmyzzo/288/1201409_2.png', '2025-12-06 07:24:26', '2025-12-06 07:24:26');
INSERT INTO `users` VALUES (234, 'xing4c', '207342', 'nvcyne2hq9kurcf814v6mdgucdsb9ffivgpoxxriaylmukbmz@privaterelay.linux.do', 'https://linux.do/letter_avatar/xing4c/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-06 07:24:45', '2025-12-06 07:24:45');
INSERT INTO `users` VALUES (235, 'hehehe123', '94411', '1rpayu2wo0vsazv73kvux2n38beoiuj46n3smoh38y2qs0mgh@privaterelay.linux.do', 'https://linux.do/letter_avatar/hehehe123/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-06 08:06:21', '2025-12-06 08:06:21');
INSERT INTO `users` VALUES (236, 'Suzuran', '275215', '5htdrnzpvrqdhughalpek3961a62gcydw2mk2urkrst677iho6@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/suzuran/288/1226233_2.png', '2025-12-06 09:05:40', '2025-12-06 09:05:40');
INSERT INTO `users` VALUES (237, 'flowerjun', '7161', '2qk7joyzowna6rabvlkfvt40ae6ps2n0uveahw0xfn6bdslorb@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/flowerjun/288/324195_2.png', '2025-12-06 09:41:34', '2025-12-06 09:41:34');
INSERT INTO `users` VALUES (238, 'cloudian_F', '203826', '60stpx5q6kcy2yeyzpdxudzto2ra4wwvq99dmy4xw3180epcsy@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/cloudian_f/288/1134711_2.png', '2025-12-06 11:10:31', '2025-12-06 11:10:31');
INSERT INTO `users` VALUES (239, 'trisoil', '50296', '4jeqcrf7nthehno3c75cvc4kpwtyvn6gmzw4orvozzjvxnudux@privaterelay.linux.do', 'https://linux.do/letter_avatar/trisoil/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-06 11:22:02', '2025-12-06 11:22:02');
INSERT INTO `users` VALUES (240, 'Shikha', '76145', '2mmlhzwx1azzw2h4vus2j19dsi190y1kur296ak9qv4i8sx8et@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/shikha/288/926856_2.png', '2025-12-06 11:27:45', '2025-12-06 11:27:45');
INSERT INTO `users` VALUES (241, 'xuanxu', '118652', '3hh81beu3z3z0x78t9ln7ip6ctdeaj4nrh02ij7zhiwezo8s65@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xuanxu/288/1028522_2.png', '2025-12-06 11:29:00', '2025-12-06 11:29:00');
INSERT INTO `users` VALUES (242, 'LufsX', '151594', '12sf2mqjqlvnzr10kwoneaalxgprmrisfiq5ntxtl8cpq1p8v5@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/lufsx/288/791710_2.png', '2025-12-06 11:29:52', '2025-12-06 11:29:52');
INSERT INTO `users` VALUES (243, 'Yueby', '217875', '2ggpu8xwlxduqtkxhas6llw75x3qkywtys3tjv1hflktf81w4z@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yueby/288/1213343_2.png', '2025-12-06 11:42:28', '2025-12-06 11:42:28');
INSERT INTO `users` VALUES (244, 'opzc35', '101214', '2559mo5aqs730iwjk6etq9bgupp1eizxdxlg8snk1c75v9afca@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/opzc35/288/448896_2.png', '2025-12-06 11:48:25', '2025-12-06 11:48:25');
INSERT INTO `users` VALUES (245, 'yalis', '154221', '1k54t2zh88e0wppmaxxxb489cikpz02eiirvr3k17jonhflsuh@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/yalis/288/831100_2.png', '2025-12-06 11:52:25', '2025-12-06 11:52:25');
INSERT INTO `users` VALUES (246, 'sjxsjxsjx', '283559', '4rj07k67y78rfelkkzoq3x79n2krewcgwfr0mqbdoow2ok77s4@privaterelay.linux.do', 'https://linux.do/letter_avatar/sjxsjxsjx/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-06 12:58:54', '2025-12-06 12:58:54');
INSERT INTO `users` VALUES (247, 'mmgitujw', '4834', '2rkhi49a0y18ioa9rhvo668516v1ki4h10kocid58bo0z72fjt@privaterelay.linux.do', 'https://linux.do/letter_avatar/mmgitujw/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-06 13:07:42', '2025-12-06 13:07:42');
INSERT INTO `users` VALUES (248, 'zz12zzxx', '137741', '3k86fk8vtzm35rlbnqxjurmxekao6x9f7et94g2j9bu3evdbc3@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zz12zzxx/288/1114678_2.png', '2025-12-06 13:43:13', '2025-12-06 13:43:13');
INSERT INTO `users` VALUES (249, 'chenpan', '119325', '30b0cj9na0sxmleekjqisk4060v5890mds4my8z1q91fzco68d@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/chenpan/288/306660_2.png', '2025-12-07 02:25:13', '2025-12-07 02:25:13');
INSERT INTO `users` VALUES (250, 'zhaox', '63551', '1xm33ffhexq4b264wwc3y0hhs4c6ww4q1ocwkthikpq31fbwxl@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zhaox/288/335719_2.png', '2025-12-07 02:28:26', '2025-12-07 02:28:26');
INSERT INTO `users` VALUES (251, 'jrerrq', '72363', '11xszydreiig6t6vhc74opqy5o3ith0v0ivt0p31sgzlf64y4l@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/jrerrq/288/549702_2.png', '2025-12-07 08:30:52', '2025-12-07 08:30:52');
INSERT INTO `users` VALUES (252, 'zkogow', '28715', '5qmtv0tkdgviaso5ksdu602w26s9qoppodno7ffset1b6i6zxg@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/zkogow/288/85122_2.png', '2025-12-07 09:12:15', '2025-12-07 09:12:15');
INSERT INTO `users` VALUES (253, 'xjtu_wang', '134895', '208wzqan3r1fhfsdk7zu2j809u2x02eht6vgsiqhbhe961afnu@privaterelay.linux.do', 'https://linux.do/user_avatar/linux.do/xjtu_wang/288/641771_2.png', '2025-12-07 09:33:30', '2025-12-07 09:33:30');
INSERT INTO `users` VALUES (254, 'daisheng', '243797', '40856t1ejn2q4dntb8eqtrma2veft4hwd3xiaixxom1eisl6ve@privaterelay.linux.do', 'https://linux.do/letter_avatar/daisheng/288/5_c16b2ee14fe83ed9a59fc65fbec00f85.png', '2025-12-07 13:14:28', '2025-12-07 13:14:28');

-- ----------------------------
-- View structure for v_consumer_leaderboard
-- ----------------------------
DROP VIEW IF EXISTS `v_consumer_leaderboard`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_consumer_leaderboard` AS select row_number() OVER (ORDER BY `v_user_best_results`.`overall_wall_time`,`v_user_best_results`.`submitted_at` )  AS `rank_position`,`v_user_best_results`.`username` AS `username`,`v_user_best_results`.`cpu_model` AS `cpu_model`,`v_user_best_results`.`cpu_cores` AS `cpu_cores`,`v_user_best_results`.`memory_gb` AS `memory_gb`,`v_user_best_results`.`overall_wall_time` AS `overall_wall_time`,`v_user_best_results`.`phase1_wall_time` AS `phase1_wall_time`,`v_user_best_results`.`phase2_wall_time` AS `phase2_wall_time`,`v_user_best_results`.`performance_score` AS `performance_score`,`v_user_best_results`.`submitted_at` AS `submitted_at`,`v_user_best_results`.`device_type_confidence` AS `device_type_confidence` from `v_user_best_results` where (`v_user_best_results`.`device_type` = 'consumer') order by `v_user_best_results`.`overall_wall_time`,`v_user_best_results`.`submitted_at`;

-- ----------------------------
-- View structure for v_leaderboard
-- ----------------------------
DROP VIEW IF EXISTS `v_leaderboard`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_leaderboard` AS select row_number() OVER (ORDER BY `v_user_best_results`.`overall_wall_time`,`v_user_best_results`.`submitted_at` )  AS `rank_position`,`v_user_best_results`.`username` AS `username`,`v_user_best_results`.`cpu_model` AS `cpu_model`,`v_user_best_results`.`cpu_cores` AS `cpu_cores`,`v_user_best_results`.`memory_gb` AS `memory_gb`,`v_user_best_results`.`overall_wall_time` AS `overall_wall_time`,`v_user_best_results`.`phase1_wall_time` AS `phase1_wall_time`,`v_user_best_results`.`phase2_wall_time` AS `phase2_wall_time`,`v_user_best_results`.`performance_score` AS `performance_score`,`v_user_best_results`.`submitted_at` AS `submitted_at`,`v_user_best_results`.`device_type` AS `device_type`,`v_user_best_results`.`device_type_confidence` AS `device_type_confidence` from `v_user_best_results` order by `v_user_best_results`.`overall_wall_time`,`v_user_best_results`.`submitted_at`;

-- ----------------------------
-- View structure for v_server_leaderboard
-- ----------------------------
DROP VIEW IF EXISTS `v_server_leaderboard`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_server_leaderboard` AS select row_number() OVER (ORDER BY `v_user_best_results`.`overall_wall_time`,`v_user_best_results`.`submitted_at` )  AS `rank_position`,`v_user_best_results`.`username` AS `username`,`v_user_best_results`.`cpu_model` AS `cpu_model`,`v_user_best_results`.`cpu_cores` AS `cpu_cores`,`v_user_best_results`.`memory_gb` AS `memory_gb`,`v_user_best_results`.`overall_wall_time` AS `overall_wall_time`,`v_user_best_results`.`phase1_wall_time` AS `phase1_wall_time`,`v_user_best_results`.`phase2_wall_time` AS `phase2_wall_time`,`v_user_best_results`.`performance_score` AS `performance_score`,`v_user_best_results`.`submitted_at` AS `submitted_at`,`v_user_best_results`.`device_type_confidence` AS `device_type_confidence` from `v_user_best_results` where (`v_user_best_results`.`device_type` = 'server') order by `v_user_best_results`.`overall_wall_time`,`v_user_best_results`.`submitted_at`;

-- ----------------------------
-- View structure for v_user_best_results
-- ----------------------------
DROP VIEW IF EXISTS `v_user_best_results`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_user_best_results` AS select `u`.`id` AS `user_id`,`u`.`username` AS `username`,`u`.`avatar_url` AS `avatar_url`,`br`.`id` AS `result_id`,`br`.`cpu_model` AS `cpu_model`,`br`.`cpu_cores` AS `cpu_cores`,`br`.`memory_gb` AS `memory_gb`,`br`.`device_type` AS `device_type`,`br`.`device_type_confidence` AS `device_type_confidence`,`br`.`device_type_manually_corrected` AS `device_type_manually_corrected`,`br`.`phase1_wall_time` AS `phase1_wall_time`,`br`.`phase2_wall_time` AS `phase2_wall_time`,`br`.`overall_wall_time` AS `overall_wall_time`,`br`.`performance_score` AS `performance_score`,`br`.`submitted_at` AS `submitted_at` from (`users` `u` join `benchmark_results` `br` on((`u`.`id` = `br`.`user_id`))) where ((`br`.`is_verified` = true) and (`br`.`overall_wall_time` is not null) and (`br`.`id` = (select `br2`.`id` from `benchmark_results` `br2` where ((`br2`.`user_id` = `u`.`id`) and (`br2`.`is_verified` = true) and (`br2`.`overall_wall_time` is not null)) order by `br2`.`overall_wall_time` limit 1)));

-- ----------------------------
-- Procedure structure for CheckUserResultLimit
-- ----------------------------
DROP PROCEDURE IF EXISTS `CheckUserResultLimit`;
delimiter ;;
CREATE DEFINER=`root`@`%` PROCEDURE `CheckUserResultLimit`(
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
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for UpdateDeviceType
-- ----------------------------
DROP PROCEDURE IF EXISTS `UpdateDeviceType`;
delimiter ;;
CREATE DEFINER=`root`@`%` PROCEDURE `UpdateDeviceType`(
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
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
