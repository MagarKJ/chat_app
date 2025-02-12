import 'package:chat_app/auth/login.dart';
import 'package:chat_app/homepage/homepage.dart';
import 'package:flutter/material.dart';

class NavigationServices {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => const LoginPage(),
    "/home": (context) => const Homepage(),
  };

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  Map<String, Widget Function(BuildContext)> get routes => _routes;

  NavigationServices() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}
