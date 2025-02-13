import 'package:chat_app/auth/services/alert_services.dart';
import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/auth/services/database_service.dart';
import 'package:chat_app/auth/services/media_service.dart';
import 'package:chat_app/auth/services/navigation_services.dart';
import 'package:chat_app/auth/services/storage_service.dart';
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
  getIt.registerSingleton<MediaService>(
    MediaService(),
  );
  getIt.registerSingleton<StorageService>(
    StorageService(),
  );
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}
