// import 'package:firebase_task/controller/auth_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});
//
//   @override
//   SignUpPageState createState() => SignUpPageState();
// }
//
// class SignUpPageState extends State<SignUpPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   final AuthController authController = Get.put(AuthController());
//
//   signUp() {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       Get.snackbar("Error", "Please fill in both email and password.",
//           backgroundColor: Colors.redAccent, colorText: Colors.white);
//     } else if (password.length < 6) {
//       Get.snackbar("Error", "Password must be at least 6 characters.",
//           backgroundColor: Colors.redAccent, colorText: Colors.white);
//     } else {
//       authController.signUp(email, password);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xff0F2027), Color(0xff2C5364)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title
//               const Text(
//                 'Create Account',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 30),
//
//               // Email TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12.withOpacity(0.05),
//                       blurRadius: 10,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     hintText: 'Email',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Password TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12.withOpacity(0.05),
//                       blurRadius: 10,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     hintText: 'Password',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//
//               // Sign Up Button
//               Obx(() {
//                 return authController.isLoading.value
//                     ? const Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.blueAccent,
//                           backgroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 50,
//                             vertical: 15,
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         onPressed: signUp,
//                         child: const Text('Sign Up'),
//                       );
//               }),
//               const SizedBox(height: 20),
//
//               // Already have an account? Login button
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     Get.offNamed('/login');
//                   },
//                   child: const Text(
//                     'Already have an account? Login',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_task/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/textfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthController authController = Get.put(AuthController());

  signUp() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill in both email and password.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } else if (password.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } else {
      authController.signUp(email, password, _nameController.text.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0F2027), Color(0xff2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double titleFontSize = screenWidth < 350 ? 28 : 32;
              double inputVerticalPadding = screenWidth < 350 ? 12 : 16;
              double buttonPaddingHorizontal = screenWidth < 350 ? 40 : 50;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  customTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      icon: Icons.person,
                      visibilityOnOffIcon: false),
                  const SizedBox(height: 20),
                  customTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      visibilityOnOffIcon: false),
                  const SizedBox(height: 20),
                  customTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      visibilityOnOffIcon: true),
                  const SizedBox(height: 40),
                  Center(
                    child: Obx(() {
                      return authController.isLoading.value
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blueAccent,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: buttonPaddingHorizontal,
                                  vertical: inputVerticalPadding,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: signUp,
                              child: const Text('Sign Up'),
                            );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Get.offNamed('/login');
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
