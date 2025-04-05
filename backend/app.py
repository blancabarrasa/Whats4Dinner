from flask import Flask, request, jsonify
from spoonacular_api import find_recipes_by_ingredients, get_recipe_info

app = Flask(__name__)
init_db()


@app.route("/match-recipes", methods=["POST"])
def match_recipes():
    data = request.get_json()
    ingredients = data.get("ingredients", [])

    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    # Find matching recipes
    raw_recipes, status = find_recipes_by_ingredients(ingredients)

    if status != 200:
        return jsonify(raw_recipes), status

    # Optional: get full instructions for each recipe
    final_recipes = []
    for r in raw_recipes:
        info = get_recipe_info(r["id"])
        if info:
            final_recipes.append(info)

    return jsonify(final_recipes), 200


if __name__ == "__main__":
    app.run(debug=True)
from db.models import init_db
from db.food_loader import load_foods_from_json
from db.fridge import add_to_fridge, get_fridge_contents


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
