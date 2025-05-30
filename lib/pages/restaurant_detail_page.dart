import 'package:flutter/material.dart';
import 'package:responsi/api/api_service.dart';
import 'package:responsi/models/restaurant.dart';
import 'package:responsi/utils/shared_preferences_halper.dart';
import 'package:responsi/widgets/custom_app_bar.dart'; // Using CustomAppBar

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  late Future<Restaurant> _restaurantDetail;
  final ApiService _apiService = ApiService();
  bool _isFavorite = false;
  Restaurant? _currentRestaurant;

  @override
  void initState() {
    super.initState();
    _fetchDetailAndCheckFavorite();
  }

  void _fetchDetailAndCheckFavorite() async {
    _restaurantDetail = _apiService.getRestaurantDetail(widget.restaurantId);
    _currentRestaurant = await _restaurantDetail;
    _isFavorite = await SharedPreferencesHelper.isRestaurantFavorite(
      widget.restaurantId,
    );
    setState(() {});
  }

  void _toggleFavorite() async {
    if (_currentRestaurant == null) return;

    if (_isFavorite) {
      await SharedPreferencesHelper.removeFavoriteRestaurant(
        widget.restaurantId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await SharedPreferencesHelper.addFavoriteRestaurant(_currentRestaurant!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to favorites!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: CustomAppBar(
        titleText: 'Restaurant Detail',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
              size: 28, // Slightly larger icon
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Restaurant>(
        future: _restaurantDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Restaurant details not found.'));
          } else {
            final restaurant = snapshot.data!;
            _currentRestaurant = restaurant;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Image
                  if (restaurant.pictureId != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        _apiService.getSmallImageUrl(restaurant.pictureId!),
                        width: double.infinity,
                        height: 280, // Taller image
                        fit: BoxFit.cover,
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 280,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 280,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20.0),

                  // Restaurant Name and Basic Info
                  Text(
                    restaurant.name ?? 'Unknown Name',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        restaurant.city ?? 'Unknown City',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.star, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        restaurant.rating?.toStringAsFixed(1) ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        // Use Expanded to wrap long addresses
                        child: Text(
                          restaurant.address ?? 'Unknown Address',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          overflow:
                              TextOverflow
                                  .ellipsis, // Add ellipsis for long addresses
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1), // Separator
                  // Description
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    restaurant.description ?? 'No description available.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
