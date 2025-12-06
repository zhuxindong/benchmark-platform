#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
简化的数据库初始化脚本
"""

import os
import mysql.connector
from mysql.connector import Error

# 数据库连接配置 - 从环境变量读取，避免硬编码敏感信息
DB_CONFIG = {
    'host': os.getenv('DB_HOST', '127.0.0.1'),
    'port': int(os.getenv('DB_PORT', '3306')),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'charset': 'utf8mb4'
}

def init_database():
    """初始化数据库"""
    try:
        print("正在连接数据库...")

        # 连接MySQL服务器（不指定数据库）
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        # 创建数���库
        cursor.execute("CREATE DATABASE IF NOT EXISTS benchmark DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cursor.execute("USE benchmark")

        print("数据库 'benchmark' 创建/选择成功")

        # 读取并执行SQL文件
        with open('init.sql', 'r', encoding='utf-8') as file:
            sql_content = file.read()

        # 分割SQL语句
        sql_statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip() and not stmt.strip().startswith('--')]

        executed_count = 0
        for statement in sql_statements:
            try:
                cursor.execute(statement)
                connection.commit()
                executed_count += 1
            except Error as e:
                if "already exists" in str(e) or "Duplicate" in str(e):
                    continue  # 忽略已存在的错误
                print(f"执行SQL错误: {e}")
                print(f"SQL: {statement[:100]}...")

        print(f"成功执行 {executed_count} 条SQL语句")

        # 验证表创建
        cursor.execute("SHOW TABLES;")
        tables = cursor.fetchall()
        print(f"数据库中的表数量: {len(tables)}")

        if tables:
            print("表列表:")
            for table in tables:
                print(f"   - {table[0]}")

        cursor.close()
        connection.close()

        print("数据库初始化完成！")
        return True

    except Error as e:
        print(f"数据库初始化失败: {e}")
        return False
    except FileNotFoundError:
        print("找不到 init.sql 文件")
        return False

if __name__ == "__main__":
    print("基准测试平台 - 数据库初始化")
    print("=" * 40)

    if init_database():
        print("初始化成功！")
    else:
        print("初始化失败！")