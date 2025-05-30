import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsi/pages/login_page.dart';
import 'package:responsi/pages/restaurant_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.containsKey('username');
      _username = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          _isLoggedIn && _username != null
              ? RestaurantListPage(username: _username!)
              : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/restaurant_list':
            (context) => RestaurantListPage(
              username: _username ?? 'User',
            ), // Placeholder username
      },
    );
  }
}
