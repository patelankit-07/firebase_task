import 'dart:io';
import 'dart:typed_data'; // Web image support
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_task/models/article_model.dart';

class NewsPostController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var articles = <Article>[].obs;
  var isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    fetchArticles();
    super.onInit();
  }

  // Android/iOS Image Picker
  Future<XFile?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  // Web Image Picker
  Future<Uint8List?> pickWebImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? await pickedFile.readAsBytes() : null;
  }

  // Upload image for Android/iOS
  Future<String?> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.png');
      await imageRef.putFile(imageFile);
      return await imageRef.getDownloadURL();
    } catch (e) {
      Get.snackbar("Upload Error", e.toString());
      return null;
    }
  }

  // Upload image for Web
  Future<String?> uploadWebImage(Uint8List imageData) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.png');
      await imageRef.putData(imageData);
      return await imageRef.getDownloadURL();
    } catch (e) {
      Get.snackbar("Upload Error", e.toString());
      return null;
    }
  }

  // Add article with image (works for both Android and Web)
  Future<void> addArticle({
    required String title,
    required String content,
    File? imageFile,
    Uint8List? webImageFile,
  }) async {
    isLoading.value = true;
    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    } else if (webImageFile != null) {
      imageUrl = await uploadWebImage(webImageFile);
    }

    try {
      await firestore.collection("articles").add({
        "title": title,
        "content": content,
        "userId": FirebaseAuth.instance.currentUser?.uid,
        "imageUrl": imageUrl,
        "comments": [],
        "timestamp": FieldValue.serverTimestamp(),
      });
      isLoading.value = false;
    } catch (e) {
      Get.snackbar("Error", "Error adding article: $e");
    }
  }

  // Fetch articles
  void fetchArticles() {
    try {
      firestore.collection("articles").snapshots().listen((snapshot) {
        articles.value = snapshot.docs.map((doc) => Article.fromDocumentSnapshot(doc)).toList();
        isLoading.value = false;
      });
    } catch (e) {
      Get.snackbar("Error", "Error fetching articles: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Edit an article in Firestore
  void editArticle(String articleId,
      {required String title, required String content}) async {
    try {
      await firestore.collection("articles").doc(articleId).update({
        "title": title,
        "content": content,
        "timestamp": FieldValue.serverTimestamp(),
      });
      Get.snackbar("Success", "Article updated successfully.");
    } catch (e) {
      print("Error updating article: $e");
      Get.snackbar("Error", "Error updating article.");
    }
  }

  // Delete an article from Firestore
  void deleteArticle(String articleId) async {
    try {
      await firestore.collection("articles").doc(articleId).delete();
      Get.snackbar("Success", "Article deleted successfully.");
    } catch (e) {
      print("Error deleting article: $e");
      Get.snackbar("Error", "Error deleting article.");
    }
  }
}
