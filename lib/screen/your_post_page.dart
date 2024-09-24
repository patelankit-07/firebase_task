import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_task/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/news_post_artical_controller.dart';
import '../controller/theme_controller.dart';
import 'comment_page.dart';
import 'edit_article_page.dart';

class YourPostPage extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());
  final ThemeController themeController = Get.put(ThemeController());
  final NewsPostController newsPostController = Get.put(NewsPostController());


  YourPostPage({super.key});

  Future<void> toggleLike(String articleId, String userId, bool isLiked) async {
    DocumentReference articleRef =
    FirebaseFirestore.instance.collection('articles').doc(articleId);

    if (isLiked) {
      await articleRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await articleRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void goToComments(String articleId) {
    Get.to(() => CommentsPage(articleId: articleId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2C5364),
        title: const Text("Your Posts", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
      body: Obx(() {
        if (newsPostController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = _authController.user.value;

        if (user == null) {
          return const Center(child: Text("No user logged in."));
        }

        final userArticles = newsPostController.articles
            .where((article) => article.userId == FirebaseAuth.instance.currentUser?.uid)
            .toList();

        if (userArticles.isEmpty) {
          return const Center(child: Text("No posts available for this user"));
        }

        return LayoutBuilder(builder: (context, constraints) {
          return ListView.separated(
            itemBuilder: (_, index) {
              final article = userArticles[index];
              bool isLiked = article.likedBy.contains(user.uid);
              final isWide = constraints.maxWidth > 600;

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isWide ? 150 : 100,
                      height: isWide ? 100 : 80,
                      margin: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: article.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey,
                            child: const Center(child: Text('Image not available')),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: TextStyle(
                              fontSize: isWide ? 20 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            article.content,
                            style: TextStyle(
                              fontSize: isWide ? 16 : 12,
                              color: Colors.grey,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      toggleLike(article.id, user.uid, isLiked);
                                    },
                                  ),
                                  Text(
                                    '${article.likes} Likes',
                                    style: TextStyle(fontSize: isWide ? 16 : 12),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  goToComments(article.id);
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.comment),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${article.comments.length} Comments',
                                      style: TextStyle(fontSize: isWide ? 16 : 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Get.to(EditArticlePage(article: article));
                        } else if (value == 'delete') {
                          Get.defaultDialog(
                            title: "Delete Article",
                            middleText: "Are you sure you want to delete this article?",
                            onConfirm: () {
                              newsPostController.deleteArticle(article.id);
                              Get.back();
                            },
                            onCancel: () {},
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, i) => const Divider(height: 1, thickness: 1),
            itemCount: userArticles.length,
          );
        });
      }),
    );
  }
}
