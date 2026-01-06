import mysql.connector
from mysql.connector import pooling

db_config = {
    "host": "localhost",
    "user": "root",
    "password": "PASSWORD",
    "database": "bank"
}

connection_pool = pooling.MySQLConnectionPool(
    pool_name="fraud_pool",
    pool_size=5,
    **db_config
)

def get_db():
    return connection_pool.get_connection()
