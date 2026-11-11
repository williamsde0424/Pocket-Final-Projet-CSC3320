import csv
import mysql.connector
from mysql.connector import Error

def get_connection():
    """Establish connection to pocket_db."""
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='Rufusking2@', 
        database='pocket_db'
    )

def import_csv_inventory(filepath='pocket_initial_inventory.csv'):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        print("Connected to pocket_db. Importing 100 items from CSV...")

        with open(filepath, mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            count = 0
            
            for row in reader:
                group_name = row['group_name']
                loc_name = row['primary_location']
                sub_name = row['sublocation']
                cat_name = row['category']
                item_name = row['item_name']
                description = row['description']
                image_url = row['image_url']

                # 1. Resolve or Insert Inventory Group
                cursor.execute("SELECT group_id FROM inventory_group WHERE group_name = %s", (group_name,))
                group_res = cursor.fetchone()
                if group_res:
                    group_id = group_res[0]
                else:
                    cursor.execute("INSERT INTO inventory_group (group_name) VALUES (%s)", (group_name,))
                    group_id = cursor.lastrowid

                # 2. Resolve or Insert Primary Location
                cursor.execute("SELECT loc_id FROM primary_location WHERE group_id = %s AND name = %s", (group_id, loc_name))
                loc_res = cursor.fetchone()
                if loc_res:
                    loc_id = loc_res[0]
                else:
                    cursor.execute("INSERT INTO primary_location (group_id, name) VALUES (%s, %s)", (group_id, loc_name))
                    loc_id = cursor.lastrowid

                # 3. Resolve or Insert Sublocation (if present)
                sub_id = None
                if sub_name and sub_name.strip():
                    cursor.execute("SELECT sub_id FROM sublocation WHERE loc_id = %s AND name = %s", (loc_id, sub_name))
                    sub_res = cursor.fetchone()
                    if sub_res:
                        sub_id = sub_res[0]
                    else:
                        cursor.execute("INSERT INTO sublocation (loc_id, name) VALUES (%s, %s)", (loc_id, sub_name))
                        sub_id = cursor.lastrowid

                # 4. Resolve or Insert Category
                cursor.execute("SELECT cat_id FROM category WHERE group_id = %s AND name = %s", (group_id, cat_name))
                cat_res = cursor.fetchone()
                if cat_res:
                    cat_id = cat_res[0]
                else:
                    cursor.execute("INSERT INTO category (group_id, name) VALUES (%s, %s)", (group_id, cat_name))
                    cat_id = cursor.lastrowid

                # 5. Insert Item Record
                cursor.execute("""
                    INSERT INTO item (loc_id, sub_id, name, description, image_url)
                    VALUES (%s, %s, %s, %s, %s)
                """, (loc_id, sub_id, item_name, description, image_url))
                item_id = cursor.lastrowid

                # 6. Link Item to Category in Bridge Table
                cursor.execute("""
                    INSERT IGNORE INTO item_category (item_id, cat_id)
                    VALUES (%s, %s)
                """, (item_id, cat_id))
                
                count += 1

            conn.commit()
            print(f"\nSUCCESS: Imported {count} items successfully, fully segregated by group!")

    except Error as e:
        print(f"Database error during CSV import: {e}")
        if 'conn' in locals() and conn.is_connected():
            conn.rollback()
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    import_csv_inventory()