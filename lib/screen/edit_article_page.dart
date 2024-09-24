import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_task/models/article_model.dart';
import '../controller/news_post_artical_controller.dart';

class EditArticlePage extends StatelessWidget {
  final Article article;

  final TextEditingController _titleController;
  final TextEditingController _contentController;

  EditArticlePage({super.key, required this.article})
      : _titleController = TextEditingController(text: article.title),
        _contentController = TextEditingController(text: article.content);

  final newsFeedController = Get.find<NewsPostController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Article",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF0F2027),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildInputField(
                      "Edit Title",
                      _titleController,
                      constraints.maxWidth,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      "Edit Content",
                      _contentController,
                      constraints.maxWidth,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 30),
                    _buildUpdateButton(constraints.maxWidth, context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _buildInputField(
      String labelText, TextEditingController controller, double width,
      {int maxLines = 1}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildUpdateButton(double width, BuildContext context) {
    return SizedBox(
      width: width * 0.7,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          newsFeedController.editArticle(
            article.id,
            title: _titleController.text,
            content: _contentController.text,
          );
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: const Text(
          "Update Article",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
