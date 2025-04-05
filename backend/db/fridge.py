import sqlite3


def add_to_fridge(food_name):
    conn = sqlite3.connect("db/whats4dinner.db")
    c = conn.cursor()

    c.execute("SELECT id FROM foods WHERE name = ?", (food_name,))
    result = c.fetchone()
    if result:
        food_id = result[0]
        c.execute("INSERT INTO fridge (food_id) VALUES (?)", (food_id,))
    else:
        print(f"{food_name} not found in foods database.")

    conn.commit()
    conn.close()


def remove_from_fridge(food_name):
    conn = sqlite3.connect("db/whats4dinner.db")
    c = conn.cursor()

    c.execute("SELECT id FROM foods WHERE name = ?", (food_name,))
    result = c.fetchone()
    if result:
        food_id = result[0]
        c.execute("DELETE FROM fridge WHERE food_id = ?", (food_id,))
    
    conn.commit()
    conn.close()


def get_fridge_contents():
    conn = sqlite3.connect("db/whats4dinner.db")
    c = conn.cursor()

    c.execute('''
        SELECT foods.name FROM fridge
        JOIN foods ON fridge.food_id = foods.id
    ''')
    items = c.fetchall()
    conn.close()

    return [item[0] for item in items]