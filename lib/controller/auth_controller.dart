import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_task/controller/notification_controller.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userCollection = FirebaseFirestore.instance.collection("users");
  var user = Rxn<User>();
  var isLoading = false.obs;
  Rx<String> email = ''.obs;
  RxString name = ''.obs;
  RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    user.bindStream(auth.authStateChanges());
    super.onInit();
  }

  void login(String email, String password) async {
    isLoading.value = true;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill in both email and password.");
      return;
    }

    try {
      var user = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      var token = await NotificationService().getToken();
      await userCollection.doc(user.user?.uid).update({
        "id": user.user?.uid,
        "token": token,
      });
      Get.offAllNamed('/newsfeed');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      print("error 10 :$e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void signUp(String email, String password,String name) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill in both email and password.");
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters long.");
      return;
    }

    isLoading.value = true;
    var token = await NotificationService().getToken();

    try {
      var user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      var id = user.user?.uid;
      await userCollection.doc(id).set({
        "id": id,
        "token": token,
        "email": auth.currentUser?.email ?? "Anonymous",
        "name": name,
      });
      Get.offAllNamed('/newsfeed');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred$e.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> getAllUserToken() async {
    var users = await userCollection
        .where("id", isNotEqualTo: auth.currentUser?.uid)
        .get();
    var tokens = users.docs.map((user) => user.data()['token'] as String);
    return tokens.toList();
  }

  Future<void> fetchUserEmail() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot snapshot = await userCollection.doc(userId).get();
        if (snapshot.exists) {
          email.value= snapshot['email'] ?? '';
          name.value= snapshot['name'] ?? '';
          print("Fetched email: ${email.value}");
        } else {
          print("User document does not exist.");
        }
      } else {
        print("No user is logged in.");
      }
    } catch (e) {
      print("Error fetching email: $e");
    }
  }

  void logout() async {
    await auth.signOut();
    Get.offAllNamed('/login');
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = "";

    switch (e.code) {
      case "user-not-found":
        message = "No user found for this email.";
        break;
      case "wrong-password":
        message = "Incorrect password. Please try again.";
        break;
      case "email-already-in-use":
        message = "This email is already registered.";
        break;
      case "invalid-email":
        message = "The email address is invalid.";
        break;
      default:
        message = "Authentication error: ${e.message}";
    }

    Get.snackbar("Authentication Error", message);
  }
}