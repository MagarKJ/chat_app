import 'package:chat_app/custom_widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final GestureTapCallback onTap;
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width * 0.8,
        alignment: Alignment.center,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: buttonColor,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
