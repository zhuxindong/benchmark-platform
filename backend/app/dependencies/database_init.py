# -*- coding: utf-8 -*-
"""
数据库初始化模块
"""
import os
import re
import pymysql
from app.dependencies.database import DB_CONFIG


def check_database_exists():
    """检查数据库和表是否存在，如果不存在则初始化"""
    try:
        # 连接到MySQL服务器
        temp_config = DB_CONFIG.copy()
        database_name = temp_config.pop('database', None)

        conn = pymysql.connect(**temp_config)
        cursor = conn.cursor()

        # 创建数据库
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{database_name}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cursor.execute(f"USE `{database_name}`")

        # 检查users表是否存在
        cursor.execute("SHOW TABLES LIKE 'users'")
        users_exists = cursor.fetchone()

        if not users_exists:
            print("数据库表不存在，开始初始化...")
            # 获取init.sql路径（在backend目录下）
            backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            init_script_path = os.path.join(backend_dir, 'init.sql')

            if os.path.exists(init_script_path):
                with open(init_script_path, 'r', encoding='utf-8') as f:
                    init_sql = f.read()
                    # 移除创建数据库的语句
                    init_sql = re.sub(r'CREATE DATABASE.*?;', '', init_sql, flags=re.MULTILINE | re.DOTALL)
                    init_sql = re.sub(r'USE `[^`]+`;', '', init_sql, flags=re.MULTILINE)

                    # 分割并执行SQL语句
                    statements = [s.strip() for s in init_sql.split(';') if s.strip()]
                    for statement in statements:
                        if statement:
                            cursor.execute(statement)
                print("数据库初始化完成")
            else:
                print("警告: init.sql文件不存在，跳过数据库初始化")
        else:
            print("数据库表已存在")

        cursor.close()
        conn.close()

    except Exception as e:
        print(f"数据库检查/初始化失败: {e}")
        raise
