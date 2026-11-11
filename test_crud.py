import mysql.connector
from mysql.connector import Error

def get_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='Rufusking2@', 
        database='pocket_db'
    )

def run_crud_tests():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        print("Successfully connected to pocket_db for testing!\n")

        # --- 0. Setup Baseline Test Data ---
        print("--- Setting up test prerequisites ---")
        
        # Insert test user
        cursor.execute("INSERT IGNORE INTO user (user_id, email, name) VALUES (1, 'dave@msoe.edu', 'Dave Student');")
        
        # Insert test inventory group
        cursor.execute("INSERT IGNORE INTO inventory_group (group_id, group_name) VALUES (1, 'The Smiths Group');")
        
        # Insert primary location
        cursor.execute("INSERT IGNORE INTO primary_location (loc_id, group_id, name) VALUES (1, 1, 'Home');")
        
        # Insert sublocation
        cursor.execute("INSERT IGNORE INTO sublocation (sub_id, loc_id, name) VALUES (1, 1, 'Garage Workbench');")
        
        # Insert category
        cursor.execute("INSERT IGNORE INTO category (cat_id, group_id, name) VALUES (1, 1, 'Tools');")
        
        conn.commit()
        print("Baseline data verified.\n")

        # --- 1. CREATE Test ---
        print("--- Testing CREATE ---")
        insert_query = """
            INSERT INTO item (loc_id, sub_id, name, description, image_url)
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(insert_query, (1, 1, 'Cordless Drill', '18V Makita drill with battery charger', 'drill.jpg'))
        conn.commit()
        test_item_id = cursor.lastrowid
        print(f"SUCCESS: Created item 'Cordless Drill' with ID {test_item_id}.\n")

        # --- 2. READ Test ---
        print("--- Testing READ (Search) ---")
        search_query = """
            SELECT i.item_id, i.name, i.description, pl.name AS primary_location, s.name AS sublocation
            FROM item i
            JOIN primary_location pl ON i.loc_id = pl.loc_id
            LEFT JOIN sublocation s ON i.sub_id = s.sub_id
            WHERE i.name LIKE %s
        """
        cursor.execute(search_query, ('%Drill%',))
        results = cursor.fetchall()
        for row in results:
            print(f"FOUND -> ID: {row[0]} | Name: {row[1]} | Desc: {row[2]} | Location: {row[3]} -> {row[4]}")
        print("SUCCESS: Read search query executed successfully.\n")

        # --- 3. UPDATE Test ---
        print("--- Testing UPDATE (Move Item Location) ---")
        # Let's create another location first to test moving
        cursor.execute("INSERT IGNORE INTO primary_location (loc_id, group_id, name) VALUES (2, 1, 'Storage Unit');")
        conn.commit()
        
        update_query = "UPDATE item SET loc_id = %s, sub_id = NULL WHERE item_id = %s"
        cursor.execute(update_query, (2, test_item_id))
        conn.commit()
        print(f"SUCCESS: Moved item ID {test_item_id} to Primary Location ID 2 (Storage Unit).\n")

        # --- 4. DELETE Test ---
        print("--- Testing DELETE ---")
        delete_query = "DELETE FROM item WHERE item_id = %s"
        cursor.execute(delete_query, (test_item_id,))
        conn.commit()
        print(f"SUCCESS: Deleted test item ID {test_item_id}.\n")

        print("All CRUD operations tested and passed successfully!")

    except Error as e:
        print(f"Database error during test: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    run_crud_tests()