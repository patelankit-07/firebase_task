import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_task/controller/auth_controller.dart';
import 'package:firebase_task/widgets/drawer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/news_post_artical_controller.dart';
import '../controller/theme_controller.dart';
import 'comment_page.dart';
import 'new_article_post.dart';

class NewsFeedPage extends StatelessWidget {
  final NewsPostController newsPostController = Get.put(NewsPostController());
  final AuthController _authController = Get.put(AuthController());
  final ThemeController themeController = Get.put(ThemeController());

  NewsFeedPage({super.key});

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
        title: const Text("News Feed", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                themeController.isDarkTheme.value
                    ? Icons.toggle_on_outlined
                    : Icons.toggle_off_outlined,
                color: themeController.isDarkTheme.value
                    ? Colors.green
                    : Colors.white,
                size: 30,
              ),
              onPressed: () {
                themeController.toggleTheme();
              },
            );
          }),
        ],
      ),
      drawer: customDrawer(),
      body: Obx(() {
        if (newsPostController.articles.isEmpty) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Center(
                  child: Text('No articles available.'),
                );
              }
            },
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 600;

            return isWideScreen
                ? GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 30,
                      childAspectRatio: 2 / 2,
                    ),
                    itemCount: newsPostController.articles.length,
                    itemBuilder: (context, index) {
                      final article = newsPostController.articles[index];
                      final user = _authController.user.value;
                      bool isLiked =
                          user != null && article.likedBy.contains(user.uid);

                      return articleCard(
                          context, article, isLiked, constraints, user);
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(15.0),
                    itemBuilder: (_, index) {
                      final article = newsPostController.articles[index];
                      final user = _authController.user.value;
                      bool isLiked =
                          user != null && article.likedBy.contains(user.uid);

                      return articleCard(
                          context, article, isLiked, constraints, user);
                    },
                    separatorBuilder: (_, i) => const SizedBox(),
                    itemCount: newsPostController.articles.length,
                  );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const NewCreateArticlePage());
        },
        backgroundColor: const Color(0xff0F2027),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.post_add, color: Colors.white),
      ),
    );
  }

  Widget articleCard(BuildContext context, article, bool isLiked,
      BoxConstraints constraints, user) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                  width: double.infinity,
                  height: constraints.maxWidth > 600 ? 300 : 200,
                  child: article.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: article.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey,
                            child: const Center(
                                child: Text('Image not available')),
                          ),
                        )
                      : SizedBox()),
            ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 24 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.content,
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 18 : 14,
              ),
            ),
            const SizedBox(height: 16),
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
                        if (user != null) {
                          toggleLike(article.id, user.uid, isLiked);
                        } else {
                          Get.snackbar("Error", "Please log in to like.");
                        }
                      },
                    ),
                    Text(
                      '${article.likes} Likes',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
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
                      Text('${article.comments.length} comments'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
