import sqlite3
import json

def load_foods_from_json(json_file):
    with open(json_file, 'r') as f:
        food_data = json.load(f)

    conn = sqlite3.connect("whats4dinner.db")
    c = conn.cursor()

    for food in food_data:
        try:
            c.execute("INSERT INTO foods (name, category) VALUES (?, ?)", (food['name'], food['category']))
        except sqlite3.IntegrityError:
            pass  # Skip duplicates

    conn.commit()
    conn.close()