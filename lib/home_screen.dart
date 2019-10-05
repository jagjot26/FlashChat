import 'package:flutter/material.dart';
import 'package:flash_chat/create_account.dart';
import 'screens/chatList_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'progress.dart';

final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
User currentUser;

class HomeScreen extends StatefulWidget {
  static const id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAuth = false;

  handleAuth() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      isAuth = true;
    } else {
      isAuth = false;
      createUserInFirestore();
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot doc = await usersRef.document(user.uid).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.uid).setData({
        "id": user.uid,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await usersRef.document(user.uid).get();
    }

    currentUser = User.fromDocument(doc);
    isAuth = true;
  }

  @override
  void initState() {
    handleAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? ChatListScreen() : circularProgress();
  }
}
