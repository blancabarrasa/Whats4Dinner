import 'package:flutter/material.dart';
import 'RecipePage.dart';
import 'services/food_service.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final FoodService _foodService = FoodService();
  Map<String, List<String>> ingredientsByCategory = {};
  List<String> fridgeContents = [];
  List<String> selectedForRecipe = [];
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);
      final foods = await _foodService.getFoodsByCategory();
      final contents = await _foodService.getFridgeContents();
      setState(() {
        ingredientsByCategory = foods;
        fridgeContents = contents;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _addToFridge(String ingredient) async {
    try {
      await _foodService.addToFridge(ingredient);
      setState(() {
        if (!fridgeContents.contains(ingredient)) {
          fridgeContents.add(ingredient);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to fridge: $e')),
        );
      }
    }
  }

  Future<void> _removeFromFridge(String ingredient) async {
    try {
      await _foodService.removeFromFridge(ingredient);
      setState(() {
        fridgeContents.remove(ingredient);
        selectedForRecipe.remove(ingredient);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing from fridge: $e')),
        );
      }
    }
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
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
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
