import 'dart:developer';

import 'package:chat_app/services/navigation_services.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AlertServices {
  final GetIt getIt = GetIt.instance;
  late NavigationServices _navigationServices;

  AlertServices() {
    _navigationServices = getIt.get<NavigationServices>();
  }

  void showToast({
    required String message,
    IconData icon = Icons.info,
  }) {
    try {
      DelightToastBar(
        autoDismiss: true,
        position: DelightSnackbarPosition.bottom,
        builder: (context) {
          return ToastCard(
            leading: Icon(icon, color: Colors.white),
            title: Text(message, style: const TextStyle(color: Colors.white)),
          );
        },
      ).show(_navigationServices.navigatorKey.currentContext!);
    } catch (e) {
      log(e.toString());
    }
  }
}
