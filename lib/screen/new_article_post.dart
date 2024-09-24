import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_task/controller/auth_controller.dart';
import 'package:firebase_task/controller/notification_controller.dart';
import '../controller/news_post_artical_controller.dart';

class NewCreateArticlePage extends StatefulWidget {
  const NewCreateArticlePage({super.key});

  @override
  CreateArticlePageState createState() => CreateArticlePageState();
}

class CreateArticlePageState extends State<NewCreateArticlePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  final NewsPostController newsPostController = Get.put(NewsPostController());

  XFile? _image;
  Uint8List? _webImage;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final pickedFile = await newsPostController.pickWebImage();
      setState(() {
        _webImage = pickedFile;
      });
    } else {
      final pickedFile = await newsPostController.pickImage();
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _submitArticle() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields.");
      return;
    }

    if ((kIsWeb && _webImage == null) || (!kIsWeb && _image == null)) {
      Get.snackbar("Error", "Please select an image.");
      return;
    }

    newsPostController.isLoading.value = true;

    try {
      await newsPostController.addArticle(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        imageFile: kIsWeb ? null : File(_image!.path), // For Android/iOS
        webImageFile: kIsWeb ? _webImage : null, // For Web
      );

      var tokens = await authController.getAllUserToken();
      await NotificationService().sendNotificationWithBearerToken(
        userTokens: tokens as List<String>,
        title: titleController.text.trim(),
        body: contentController.text.trim(),
      );

      Get.back();
      Get.snackbar("Success", "Article posted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to post article: $e");
      print("Error: $e");
    } finally {
      newsPostController.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb;
    return Scaffold(
      backgroundColor: Color(0xff2C5364),
      appBar: AppBar(
        title: const Text("Create Article", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff2C5364),
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(15),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius:
                                isWeb ? screenWidth * 0.1 : screenWidth * 0.25,
                            backgroundImage: _image != null
                                ? FileImage(File(_image!.path))
                                : _webImage != null
                                    ? MemoryImage(_webImage!)
                                    : null,
                            backgroundColor: Colors.grey[300],
                            child: _image == null && _webImage == null
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 150)
                                : null,
                          ),
                          const Positioned(
                            bottom: 10,
                            right: 10,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.green,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                        "Enter Article Title", titleController, screenWidth),
                    const SizedBox(height: 16.0),
                    _buildInputField(
                        "Enter Article Content", contentController, screenWidth,
                        maxLines: 5),
                    const SizedBox(height: 25.0),
                    _buildSubmitButton(screenWidth),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField(
      String hintText, TextEditingController controller, double screenWidth,
      {int maxLines = 1}) {
    double inputFieldWidth =
        kIsWeb || screenWidth > 600 ? 600 : screenWidth * 0.9;

    return Container(
      width: inputFieldWidth,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.black, fontSize: 18),
        maxLines: maxLines,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(double screenWidth) {
    double buttonWidth = screenWidth > 600 ? 600 : screenWidth * 0.7;

    return SizedBox(
      width: buttonWidth,
      child: Obx(() {
        return newsPostController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _submitArticle,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Post Article",
                  style: TextStyle(fontSize: 18, letterSpacing: 1),
                ),
              );
      }),
    );
  }
}
