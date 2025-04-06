import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;
  final String title;

  const RecipeDetailPage({
    super.key,
    required this.recipeId,
    required this.title,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  String? instructions;
  int? time;
  bool? vegetarian;
  List<String> ingredients = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    const String apiKey = "422d0703e5bc4d4b8f404a5adede8af7";
    final Uri url = Uri.parse(
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          instructions = data['instructions'] ?? 'No instructions provided.';
          time = data['readyInMinutes'];
          vegetarian = data['vegetarian'];
          ingredients = List<String>.from(
              data['extendedIngredients'].map((item) => item['original']));
          isLoading = false;
        });
      } else {
        setState(() {
          instructions = 'Failed to load (status: ${response.statusCode}).';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        instructions = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoRow("⏱️ Time", "${time ?? "Unknown"} minutes"),
                    buildInfoRow("🥗 Vegetarian", vegetarian == true ? "Yes" : "No"),

                    const SizedBox(height: 16),
                    const Text("🧾 Ingredients",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...ingredients
                        .map((item) => Text("• $item"))
                        .toList(),

                    const SizedBox(height: 20),
                    const Text("👨‍🍳 Instructions",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Html(data: instructions),
                  ],
                ),
              ),
            ),
    );
  }
}
