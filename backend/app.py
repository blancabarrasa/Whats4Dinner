from flask import Flask, request, jsonify
from spoonacular_api import find_recipes_by_ingredients, get_recipe_info

app = Flask(__name__)


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
