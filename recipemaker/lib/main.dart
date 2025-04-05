import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridge Recipe Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const FridgePage(),
    );
  }
}

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final Map<String, List<String>> ingredientsByCategory = {
    'Fruits': ['Apple', 'Banana', 'Orange', 'Grapes'],
    'Vegetables': ['Carrot', 'Broccoli', 'Spinach', 'Pepper'],
    'Dairy': ['Milk', 'Cheese', 'Yogurt', 'Butter'],
  };

  final List<String> selectedIngredients = [];

  void _selectIngredient(String ingredient) {
    setState(() {
      if (!selectedIngredients.contains(ingredient)) {
        selectedIngredients.add(ingredient);
      }
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      selectedIngredients.remove(ingredient);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What\'s in your fridge?'),
      ),
      body: Row(
        children: [
          // Left side: dropdown folders
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(8),
              child: ListView(
                children: ingredientsByCategory.entries.map((entry) {
                  final category = entry.key;
                  final items = entry.value;
                  return ExpansionTile(
                    title: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: items.map((item) {
                      final isSelected = selectedIngredients.contains(item);
                      return ListTile(
                        title: Text(item),
                        trailing: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle_outline,
                          color: isSelected ? Colors.green : null,
                        ),
                        onTap: () => _selectIngredient(item),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
          // Right side: selected ingredients
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredients to Cook With',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: selectedIngredients.isEmpty
                        ? const Center(child: Text('No ingredients selected.'))
                        : ListView.builder(
                            itemCount: selectedIngredients.length,
                            itemBuilder: (context, index) {
                              final item = selectedIngredients[index];
                              return Card(
                                child: ListTile(
                                  title: Text(item),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeIngredient(item),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
