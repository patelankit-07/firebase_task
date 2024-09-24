import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../screen/your_post_page.dart';

Widget customDrawer() {
  final AuthController authController = Get.find<AuthController>();
  authController.fetchUserEmail();
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xff2C5364),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    "assets/images/profile.png",
                  )),
              const SizedBox(height: 6),
               Text(
                authController.name.value.isNotEmpty ? authController.name.value : "Hello, User!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Obx(() {
                return Text(
                  authController.email.value.isNotEmpty ? authController.email.value : 'user@gmail.com',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                );
              }),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.browse_gallery),
          title: const Text('Your Post'),
          onTap: () {
            Get.to(YourPostPage());
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            Get.back();
            authController.logout();
          },
        ),
      ],
    ),
  );
}
