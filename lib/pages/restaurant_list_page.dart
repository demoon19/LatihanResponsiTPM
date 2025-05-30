import 'package:flutter/material.dart';
import 'package:responsi/api/api_service.dart';
import 'package:responsi/models/restaurant.dart';
import 'package:responsi/pages/restaurant_detail_page.dart';
import 'package:responsi/pages/favorite_page.dart';
import 'package:responsi/widgets/custom_app_bar.dart';
import 'package:responsi/utils/shared_preferences_halper.dart';
import 'package:responsi/pages/login_page.dart';

class RestaurantListPage extends StatefulWidget {
  final String username;
  const RestaurantListPage({Key? key, required this.username})
    : super(key: key);

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  late Future<List<Restaurant>> _restaurantList;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController =
      TextEditingController(); // Search controller
  String _searchQuery = ''; // State for the current search query

  @override
  void initState() {
    super.initState();
    _fetchRestaurants(); // Initial fetch
  }

  // Method to fetch restaurants based on search query
  void _fetchRestaurants() {
    setState(() {
      _restaurantList = _apiService.searchRestaurants(_searchQuery);
    });
  }

  void _logout() async {
    await SharedPreferencesHelper.clearUsername();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _onMenuItemSelected(String value) {
    if (value == 'favorite') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritePage()),
      );
    } else if (value == 'logout') {
      _logout();
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: CustomAppBar(
        titleText: 'Hai, ${widget.username}',
        showBackButton: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _onMenuItemSelected,
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'favorite',
                    child: Row(
                      children: const [
                        Icon(Icons.favorite, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Liked Restaurants'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: const [
                        Icon(Icons.exit_to_app, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        // Use Column to place search bar above the list
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants by name or city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _fetchRestaurants(); // Fetch full list after clearing
                          },
                        )
                        : null,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                // Optional: Debounce this call for better performance on rapid typing
                _fetchRestaurants();
              },
            ),
          ),
          Expanded(
            // Expanded is crucial for ListView.builder in a Column
            child: FutureBuilder<List<Restaurant>>(
              future: _restaurantList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No restaurants found for "${_searchQuery}".'),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 0.0,
                    ), // Adjust padding
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final restaurant = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RestaurantDetailPage(
                                    restaurantId: restaurant.id!,
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (restaurant.pictureId != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      _apiService.getSmallImageUrl(
                                        restaurant.pictureId!,
                                      ),
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 180,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          height: 180,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 80,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 12.0),
                                Text(
                                  restaurant.name ?? 'Unknown Restaurant',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.city ?? 'Unknown City',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.rating?.toStringAsFixed(1) ??
                                          'N/A',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
