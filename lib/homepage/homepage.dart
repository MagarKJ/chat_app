import 'dart:developer';

import 'package:chat_app/homepage/chat_page.dart';
import 'package:chat_app/model/user_profile.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/navigation_services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GetIt getIt = GetIt.instance;
  late AuthServices _authServices;
  late NavigationServices _navigationServices;
  late DatabaseService _databaseService;
  @override
  void initState() {
    super.initState();
    _authServices = getIt.get<AuthServices>();
    _navigationServices = getIt.get<NavigationServices>();
    _databaseService = getIt.get<DatabaseService>();
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
      body: StreamBuilder(
          stream: _databaseService.getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error fetching data"),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              final users = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = users[index].data();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: ListTile(
                      onTap: () async {
                        final chatExists =
                            await _databaseService.checkChatExists(
                          uid1: _authServices.user!.uid,
                          uid2: user.uid,
                        );
                        log("Chat exists: $chatExists");
                        if (!chatExists) {
                          await _databaseService.createNewChat(
                            uid1: _authServices.user!.uid,
                            uid2: user.uid,
                          );
                        }
                        _navigationServices.push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatUser: user,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        onBackgroundImageError: (exception, stackTrace) {
                          log("❌ Error loading image: $exception");
                        },
                        backgroundImage: NetworkImage(user.pfpUrl ?? ""),
                      ),
                      title: Text(user.name ?? "User"),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
