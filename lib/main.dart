import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/navigation_services.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await registerServices();
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  final GetIt getIt = GetIt.instance;
  late NavigationServices _navigationServices;
  late AuthServices _authServices;

  MyApp({super.key}) {
    _navigationServices = getIt.get<NavigationServices>();
    _authServices = getIt.get<AuthServices>();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: _navigationServices.navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: _authServices.user != null ? "/home" : "/login",
      routes: _navigationServices.routes,
    );
  }
}
