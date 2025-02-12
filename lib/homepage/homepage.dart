import 'package:chat_app/auth/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../auth/services/navigation_services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GetIt getIt = GetIt.instance;
  late AuthServices _authServices;
  late NavigationServices _navigationServices;
  @override
  void initState() {
    super.initState();
    _authServices = getIt.get<AuthServices>();
    _navigationServices = getIt.get<NavigationServices>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await _authServices.logout();
              if (result) {
                _navigationServices.pushReplacementNamed("/login");
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
