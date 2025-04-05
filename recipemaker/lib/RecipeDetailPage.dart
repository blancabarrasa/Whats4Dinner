import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeInstructions();
  }

  Future<void> fetchRecipeInstructions() async {
    const String apiKey = "422d0703e5bc4d4b8f404a5adede8af7";
    final Uri url = Uri.parse(
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          instructions = data['instructions'] ?? 'No instructions provided.';
          isLoading = false;
        });
      } else {
        setState(() {
          instructions = 'Failed to load instructions (status: ${response.statusCode}).';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(child: Text(instructions!)),
      ),
    );
  }
}
