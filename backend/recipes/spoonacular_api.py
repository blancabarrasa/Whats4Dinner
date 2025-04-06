import os
import requests
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.getenv("SPOONACULAR_API_KEY")

BASE_URL = "https://api.spoonacular.com/recipes"


def find_recipes_by_ingredients(ingredients, number=5):
    params = {
        "ingredients": ",".join(ingredients),
        "number": number,
        "ranking": 1,
        "ignorePantry": True,
        "apiKey": API_KEY,
    }

    res = requests.get(f"{BASE_URL}/findByIngredients", params=params)

    if res.status_code != 200:
        return {
            "error": f"API call failed with status {res.status_code}"
        }, res.status_code

    return res.json(), 200


def get_recipe_info(recipe_id):
    params = {"apiKey": API_KEY}
    res = requests.get(f"{BASE_URL}/{recipe_id}/information", params=params)

    if res.status_code != 200:
        return None

    data = res.json()
    return {
        "title": data.get("title"),
        "image": data.get("image"),
        "vegetarian": data.get("vegetarian"),
        "time": data.get("readyInMinutes"),
        "ingredients": [i["name"] for i in data.get("extendedIngredients", [])],
        "instructions": data.get("instructions"),
    }