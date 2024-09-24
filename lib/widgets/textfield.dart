import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

Widget customTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required visibilityOnOffIcon,
})
{
  final AuthController authController = Get.find<AuthController>();

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    ),
    child: visibilityOnOffIcon
        ? Obx(
          () => TextField(
        controller: controller,
        obscureText: authController.isPasswordVisible.value,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: visibilityOnOffIcon
              ? IconButton(
            icon: Icon(
              authController.isPasswordVisible.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              if (authController.isPasswordVisible.value) {
                authController.isPasswordVisible.value = false;
              } else {
                authController.isPasswordVisible.value = true;
              }
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    )
        : TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    ),
  );
}


