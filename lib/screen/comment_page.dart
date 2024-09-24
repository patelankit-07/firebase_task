import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_task/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentsPage extends StatelessWidget {
  final String articleId;
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController _commentController = TextEditingController();

  CommentsPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching comments'));
                }

                final data = snapshot.data?.data();
                var comments = data!['comments'];

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment['content']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      _addComment(articleId, _commentController.text);
                      _commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment(String articleId, String content) async {
    final user = _authController.user.value;
    if (user != null) {
      final userId = user.uid;

      await FirebaseFirestore.instance
          .collection('articles')
          .doc(articleId)
          .update({
        "comments": FieldValue.arrayUnion([
          {
            'userId': userId,
            'content': content,
          }
        ])
      });
    } else {
      Get.snackbar("Error", "User is not logged in.");
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getComments() {
    return FirebaseFirestore.instance
        .collection('articles')
        .doc(articleId)
        .snapshots();
  }
}
