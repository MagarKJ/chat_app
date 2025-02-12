import 'package:chat_app/auth/services/alert_services.dart';
import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/auth/services/navigation_services.dart';
import 'package:get_it/get_it.dart';

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthServices>(
    AuthServices(),
  );
  getIt.registerSingleton<NavigationServices>(
    NavigationServices(),
  );
  getIt.registerSingleton<AlertServices>(
    AlertServices(),
  );
}
