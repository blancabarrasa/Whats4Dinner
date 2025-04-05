import 'package:flutter/material.dart';
import 'RecipePage.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final Map<String, List<String>> ingredientsByCategory = {
    'Staples': [
      'Salt', 'Pepper', 'Sugar', 'Flour (all-purpose)', 'Vegetable Oil',
      'Olive Oil', 'Butter', 'Eggs', 'Milk', 'Water', 'Yeast',
      'Baking Powder', 'Baking Soda', 'Cornstarch', 'Honey', 'Maple Syrup',
      'Vinegar (white)', 'Soy Sauce', 'Worcestershire Sauce', 'Mayonnaise',
      'Ketchup', 'Mustard', 'Jam/Jelly', 'Peanut Butter', 'Nutella',
      'Canola Oil', 'Shortening', 'Coconut Oil', 'Sesame Oil', 'Rice Vinegar',
      'Balsamic Vinegar', 'Lemon Juice', 'Lime Juice', 'Tomato Paste',
      'Tomato Sauce', 'Canned Tomatoes', 'Diced Tomatoes', 'Crushed Tomatoes',
      'Pureed Tomatoes', 'Broth (chicken)', 'Bouillon Cubes',
      'Instant Coffee', 'Tea Bags', 'Cocoa Powder'
    ],
    'Produce': [
      'Potatoes', 'Onions', 'Garlic', 'Carrots', 'Celery', 'Spinach',
      'Lettuce', 'Tomatoes', 'Bananas', 'Apples', 'Oranges', 'Lemons',
      'Limes', 'Avocado', 'Broccoli', 'Cauliflower', 'Zucchini',
      'Bell Peppers', 'Cucumber', 'Asparagus', 'Mushrooms', 'Peas', 'Corn',
      'Sweet Potatoes', 'Radishes', 'Beets', 'Cabbage', 'Brussels Sprouts',
      'Peaches', 'Pears', 'Strawberries', 'Blueberries', 'Raspberries',
      'Blackberries', 'Mangoes', 'Pineapple', 'Grapes', 'Watermelon', 'Melon'
    ],
    'Dairy & Alternatives': [
      'Cheese (cheddar)', 'Yogurt', 'Parmesan Cheese', 'Cheddar Cheese',
      'Mozzarella Cheese', 'Cream Cheese', 'Butter', 'Almond Milk',
      'Soy Milk', 'Oat Milk', 'Cashew Milk'
    ],
    'Meat & Alternatives': [
      'Chicken', 'Beef', 'Pork', 'Salmon', 'Tofu'
    ],
  };

  final List<String> fridgeContents = [];
  final List<String> selectedForRecipe = [];
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  void _addToFridge(String ingredient) {
    setState(() {
      if (!fridgeContents.contains(ingredient)) {
        fridgeContents.add(ingredient);
      }
    });
  }

  void _removeFromFridge(String ingredient) {
    setState(() {
      fridgeContents.remove(ingredient);
      selectedForRecipe.remove(ingredient);
    });
  }

  void _toggleRecipeIngredient(String ingredient) {
    setState(() {
      if (selectedForRecipe.contains(ingredient)) {
        selectedForRecipe.remove(ingredient);
      } else {
        selectedForRecipe.add(ingredient);
      }
    });
  }

  List<String> _getAllIngredients() {
    return ingredientsByCategory.values.expand((e) => e).toList();
  }



  @override
  Widget build(BuildContext context) {
    final allIngredients = _getAllIngredients();
    final filteredResults = searchQuery.isEmpty
        ? []
        : allIngredients
            .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    final bool showAddNew =
        searchQuery.isNotEmpty && !allIngredients.map((e) => e.toLowerCase()).contains(searchQuery.toLowerCase());

    return Scaffold(
      appBar: AppBar(
        title: const Text("What's in your fridge?"),
      ),
      body: Row(
        children: [
          // LEFT SIDE: Ingredient Categories & Search
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search or add food',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: [
                          if (filteredResults.isEmpty && showAddNew)
                            ListTile(
                              title: Text('Add "$searchQuery" to fridge'),
                              leading: const Icon(Icons.add),
                              onTap: () {
                                _addToFridge(searchQuery);
                                searchController.clear();
                                setState(() => searchQuery = '');
                              },
                            ),
                          ...filteredResults.map((item) => ListTile(
                                title: Text(item),
                                trailing: Icon(
                                  fridgeContents.contains(item)
                                      ? Icons.check_circle
                                      : Icons.add_circle_outline,
                                  color: fridgeContents.contains(item) ? Colors.green : null,
                                ),
                                onTap: () => _addToFridge(item),
                              )),
                        ],
                      ),
                    )
                  else
                    Expanded(
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
                              final inFridge = fridgeContents.contains(item);
                              return ListTile(
                                title: Text(item),
                                trailing: Icon(
                                  inFridge ? Icons.check_circle : Icons.add_circle_outline,
                                  color: inFridge ? Colors.green : null,
                                ),
                                onTap: () => _addToFridge(item),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // RIGHT SIDE: Fridge Contents List w/ Two Buttons
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fridge Contents',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: fridgeContents.isEmpty
                        ? const Center(child: Text('Your fridge is empty.'))
                        : ListView.builder(
                            itemCount: fridgeContents.length,
                            itemBuilder: (context, index) {
                              final item = fridgeContents[index];
                              final isSelected = selectedForRecipe.contains(item);
                              return ListTile(
                                title: Text(item),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isSelected ? Icons.check : Icons.add,
                                        color: isSelected ? Colors.green : Colors.grey,
                                      ),
                                      tooltip: isSelected ? 'In recipe list' : 'Add to recipe',
                                      onPressed: () => _toggleRecipeIngredient(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Remove from fridge',
                                      onPressed: () => _removeFromFridge(item),
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (selectedForRecipe.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipePage(ingredients: selectedForRecipe),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Select ingredients to cook with.")),
            );
          }
        },
        label: const Text("Generate Recipe"),
        icon: const Icon(Icons.restaurant_menu),
      ),

    );
  }
}
