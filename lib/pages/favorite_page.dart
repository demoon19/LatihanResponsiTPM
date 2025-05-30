import 'package:flutter/material.dart';
import 'package:responsi/models/restaurant.dart';
import 'package:responsi/utils/shared_preferences_halper.dart';
import 'package:responsi/api/api_service.dart';
import 'package:responsi/widgets/custom_app_bar.dart'; // Using CustomAppBar

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Restaurant>> _favoriteRestaurants;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoriteRestaurants = SharedPreferencesHelper.getFavoriteRestaurants();
    });
  }

  void _removeFavorite(String restaurantId) async {
    await SharedPreferencesHelper.removeFavoriteRestaurant(restaurantId);
    _loadFavorites(); // Reload the list after removal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: const CustomAppBar(
        titleText: 'My Favorite Restaurants',
        showBackButton: true,
        actions: null, // No specific actions for this page's AppBar
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _favoriteRestaurants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorite restaurants yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final restaurant = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (restaurant.pictureId != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              _apiService.getSmallImageUrl(restaurant.pictureId!),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name ?? 'Unknown Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.city ?? 'Unknown City',
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.star, size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${restaurant.rating?.toStringAsFixed(1) ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
                          onPressed: () => _removeFavorite(restaurant.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}