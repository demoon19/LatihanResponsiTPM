import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsi/models/restaurant.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  static const String _usernameKey = 'username';
  static const String _favoriteRestaurantsKey = 'favoriteRestaurants';

  static Future<void> saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username); // [cite: 3]
  }

  static Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey); // [cite: 5]
  }

  static Future<void> clearUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey); // [cite: 3]
  }

  static Future<void> addFavoriteRestaurant(Restaurant restaurant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson =
        prefs.getStringList(_favoriteRestaurantsKey) ?? [];
    favoritesJson.add(jsonEncode(restaurant.toJson()));
    await prefs.setStringList(
      _favoriteRestaurantsKey,
      favoritesJson,
    ); // [cite: 23]
  }

  static Future<void> removeFavoriteRestaurant(String restaurantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson =
        prefs.getStringList(_favoriteRestaurantsKey) ?? [];
    favoritesJson.removeWhere((item) {
      final restaurant = Restaurant.fromJsonDetail(jsonDecode(item));
      return restaurant.id == restaurantId;
    });
    await prefs.setStringList(
      _favoriteRestaurantsKey,
      favoritesJson,
    ); // [cite: 23]
  }

  static Future<List<Restaurant>> getFavoriteRestaurants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson =
        prefs.getStringList(_favoriteRestaurantsKey) ?? [];
    return favoritesJson
        .map((item) => Restaurant.fromJsonDetail(jsonDecode(item)))
        .toList(); // [cite: 23]
  }

  static Future<bool> isRestaurantFavorite(String restaurantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson =
        prefs.getStringList(_favoriteRestaurantsKey) ?? [];
    return favoritesJson.any((item) {
      final restaurant = Restaurant.fromJsonDetail(jsonDecode(item));
      return restaurant.id == restaurantId;
    });
  }
}
