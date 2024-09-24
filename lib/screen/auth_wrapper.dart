import 'package:firebase_task/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_task/screen/login_page.dart';
import 'package:firebase_task/screen/newsfeed_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Obx(() {
      if (authController.user.value != null) {
        return  NewsFeedPage();
      } else if (authController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return const LoginPage();
      }
    });
  }
}
