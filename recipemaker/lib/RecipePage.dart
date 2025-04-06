import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RecipeDetailPage.dart';

class RecipePage extends StatefulWidget {
  final List<String> ingredients;

  const RecipePage({super.key, required this.ingredients});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<dynamic> recipes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    const String apiKey = "422d0703e5bc4d4b8f404a5adede8af7";
    final String joinedIngredients = widget.ingredients.join(',');
    final Uri url = Uri.parse(
        'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$joinedIngredients&number=5&ranking=1&ignorePantry=true&apiKey=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          recipes = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'API call failed: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Widget buildIngredientList(String title, List<dynamic> ingredients) {
    return ExpansionTile(
      title: Text(title),
      children: ingredients
          .map<Widget>((ingredient) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text("• ${ingredient['original']}"),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generated Recipes")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    final usedIngredients = recipe['usedIngredients'] ?? [];
                    final missedIngredients = recipe['missedIngredients'] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(recipe['title']),
                              subtitle: Text(
                                '${recipe['usedIngredientCount']} used, '
                                '${recipe['missedIngredientCount']} missing',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailPage(
                                      recipeId: recipe['id'],
                                      title: recipe['title'],
                                    ),
                                  ),
                                );
                              },
                            ),
                            buildIngredientList("🟢 Ingredients You Have", usedIngredients),
                            buildIngredientList("🔴 Ingredients You Need", missedIngredients),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
