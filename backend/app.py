from flask import Flask, request, jsonify
from db.models import init_db
from db.food_loader import load_foods_from_json
from db.fridge import add_to_fridge, get_fridge_contents

app = Flask(__name__)
init_db()

@app.route("/food_loader", methods=["POST"])
def load_foods():
    load_foods_from_json("backend/foods.json")
    return jsonify({"message": "Foods loaded"}), 200

@app.route("/fridge", methods=["GET"])
def view_fridge():
    return jsonify(get_fridge_contents())

@app.route("/fridge", methods=["POST"])
def add_food():
    data = request.get_json()
    food_name = data.get("name")
    add_to_fridge(food_name)
    return jsonify({"message": f"{food_name} added to fridge"}), 201

if __name__ == "__main__":
    app.run(debug=True)