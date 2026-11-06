import mysql.connector
from mysql.connector import Error

def get_connection():
    """Establish and return a connection to the pocket_db database."""
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='', # Update with your MySQL password if required
        database='pocket_db'
    )

# --- 1. CREATE (Insert a new item) ---
def create_item(loc_id, name, description=None, sub_id=None, image_url=None):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        query = """
            INSERT INTO item (loc_id, sub_id, name, description, image_url)
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(query, (loc_id, sub_id, name, description, image_url))
        conn.commit()
        print(f"Success: Item '{name}' created with ID {cursor.lastrowid}.")
    except Error as e:
        print(f"Error during CREATE: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

# --- 2. READ (Search and query items) ---
def search_items(keyword):
    """Search items by name or description (supports fast lookups)."""
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT i.item_id, i.name, i.description, pl.name AS primary_location, s.name AS sublocation
            FROM item i
            JOIN primary_location pl ON i.loc_id = pl.loc_id
            LEFT JOIN sublocation s ON i.sub_id = s.sub_id
            WHERE i.name LIKE %s OR i.description LIKE %s
        """
        wildcard = f"%{keyword}%"
        cursor.execute(query, (wildcard, wildcard))
        results = cursor.fetchall()
        print(f"\n--- Search Results for '{keyword}' ---")
        for row in results:
            print(f"ID: {row['item_id']} | Name: {row['name']} | Location: {row['primary_location']} ({row['sublocation'] or 'No Sublocation'})")
        return results
    except Error as e:
        print(f"Error during READ: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

# --- 3. UPDATE (Update item location or details) ---
def update_item_location(item_id, new_loc_id, new_sub_id=None):
    """Rapidly update an item's location (QuickLocationModal action)."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        query = """
            UPDATE item 
            SET loc_id = %s, sub_id = %s
            WHERE item_id = %s
        """
        cursor.execute(query, (new_loc_id, new_sub_id, item_id))
        conn.commit()
        print(f"Success: Item ID {item_id} moved to location ID {new_loc_id}.")
    except Error as e:
        print(f"Error during UPDATE: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

# --- 4. DELETE (Permanently remove an item) ---
def delete_item(item_id):
    """Remove an item from the inventory database."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        query = "DELETE FROM item WHERE item_id = %s"
        cursor.execute(query, (item_id,))
        conn.commit()
        print(f"Success: Item ID {item_id} deleted successfully.")
    except Error as e:
        print(f"Error during DELETE: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    # Test CRUD flow
    print("Testing CRUD operations...")
    # Note: Ensure you have at least one inventory_group and primary_location inserted before running test creates.