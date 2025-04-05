import sqlite3

def init_db():
    conn = sqlite3.connect("whats4dinner.db")
    c = conn.cursor()

    c.execute('''
        CREATE TABLE IF NOT EXISTS foods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            category TEXT
        )
    ''')

    c.execute('''
        CREATE TABLE IF NOT EXISTS fridge (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_id INTEGER,
            FOREIGN KEY (food_id) REFERENCES foods (id)
        )
    ''')

    conn.commit()
    conn.close()