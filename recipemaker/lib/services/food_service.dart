import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodService {
  static const String baseUrl = 'http://localhost:5000';

  Future<Map<String, List<String>>> getFoodsByCategory() async {
    final response = await http.get(Uri.parse('$baseUrl/foods'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Map<String, List<String>>.from(
        data.map((key, value) => MapEntry(
          key,
          List<String>.from(value),
        )),
      );
    } else {
      throw Exception('Failed to load foods');
    }
  }

  Future<List<String>> getFridgeContents() async {
    final response = await http.get(Uri.parse('$baseUrl/fridge'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load fridge contents');
    }
  }

  Future<void> addToFridge(String foodName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fridge'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': foodName}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add food to fridge');
    }
  }

  Future<void> removeFromFridge(String foodName) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/fridge'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': foodName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove food from fridge');
    }
  }
} 