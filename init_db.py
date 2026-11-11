import mysql.connector

def create_database():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Rufusking2@'
        )
        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute('CREATE DATABASE IF NOT EXISTS pocket_db;')
            print('Database "pocket_db" created successfully!')
            
            cursor.execute('USE pocket_db;')
            
            with open('schema.sql', 'r', encoding='utf-8') as f:
                sql_script = f.read()
                
            for statement in sql_script.split(';'):
                if statement.strip():
                    cursor.execute(statement)
            
            connection.commit()
            print('All tables created successfully based on the ERD schema!')

    except mysql.connector.Error as e:
        print(f"Database error: {e}")
    finally:
        # Safely close cursor and connection without triggering is_connected() unread result checks
        if 'cursor' in locals() and cursor:
            try:
                cursor.close()
            except Exception:
                pass
        if 'connection' in locals() and connection:
            try:
                connection.close()
            except Exception:
                pass

if __name__ == '__main__':
    create_database()
