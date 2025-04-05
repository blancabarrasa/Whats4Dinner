import 'package:flutter/material.dart';

class GenerateRecipePage extends StatelessWidget {
  const GenerateRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated Recipes"),
      ),
      body: const Center(
        child: Text(
          "This is where your recipes will appear!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
