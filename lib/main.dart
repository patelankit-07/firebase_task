import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_task/controller/notification_controller.dart';
import 'package:firebase_task/firebase_options.dart';
import 'package:firebase_task/screen/auth_wrapper.dart';
import 'package:firebase_task/screen/login_page.dart';
import 'package:firebase_task/screen/newsfeed_page.dart';
import 'package:firebase_task/screen/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'firebase_task',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/newsfeed': (context) => NewsFeedPage(),
      },
    );
  }
}
