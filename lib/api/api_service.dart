import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsi/models/restaurant.dart';

class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev/';
  static const String _listEndpoint = 'list';
  static const String _detailEndpoint = 'detail/';
  static const String _searchEndpoint = 'search?q='; // Added search endpoint
  static const String _imageSmallUrl = '${_baseUrl}images/small/';

  Future<List<Restaurant>> getRestaurantList() async {
    final response = await http.get(Uri.parse(_baseUrl + _listEndpoint));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> restaurantsJson = jsonResponse['restaurants'];
      return restaurantsJson
          .map((json) => Restaurant.fromJsonList(json))
          .toList();
    } else {
      throw Exception('Failed to load restaurant list');
    }
  }

  Future<Restaurant> getRestaurantDetail(String id) async {
    final response = await http.get(Uri.parse(_baseUrl + _detailEndpoint + id));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Restaurant.fromJsonDetail(jsonResponse['restaurant']);
    } else {
      throw Exception('Failed to load restaurant detail');
    }
  }

  // --- New method for searching restaurants ---
  Future<List<Restaurant>> searchRestaurants(String query) async {
    if (query.isEmpty) {
      return getRestaurantList(); // If query is empty, return the full list
    }
    final response = await http.get(
      Uri.parse(_baseUrl + _searchEndpoint + query),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> restaurantsJson = jsonResponse['restaurants'];
      return restaurantsJson
          .map((json) => Restaurant.fromJsonList(json))
          .toList();
    } else {
      throw Exception('Failed to search restaurants');
    }
  }

  String getSmallImageUrl(String pictureId) {
    return _imageSmallUrl + pictureId;
  }
}
