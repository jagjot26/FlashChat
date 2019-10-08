import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'dart:io';


final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();


class Auth with ChangeNotifier {
  User presentUser;
  String uidSharedPref;
  FirebaseUser user;
  String loggedInUserIDSharedPref;
  String loggedInUserContactNumber;

  bool get isAuth{
    return uidSharedPref!=null;
  }


  Future<bool> logIn(String smsCode, String verificationId, String phoneNumber) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
          verificationId: verificationId, smsCode: smsCode);
      user =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser currentUser = await FirebaseAuth.instance
          .currentUser();
      assert(user.uid == currentUser.uid);


      print('signInWithPhoneNumber succeeded: $user');
//      createUserInFireStore(user, phoneNumber, displayName);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', user.uid);
      notifyListeners();
      return false;
    }catch(e){
      print(e);
      return true;
    }
  }


  createUserInFireStore(FirebaseUser user, String phoneNumber, String displayName, File image) async {
    // 1) check if user exists in users collection in database (according to their id)
    DocumentSnapshot doc = await usersRef.document(user.uid).get();
    
    final prefs2 = await SharedPreferences.getInstance();
      prefs2.setString("loggedInUserPhoneNumber", phoneNumber);

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
//      final username = await Navigator.push(
//          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.uid).setData({
        "id": user.uid,
        "displayName": displayName,
        "bio": "",
        "phoneNumber": phoneNumber,
        "timestamp": timestamp,
      });    
    
      
      doc = await usersRef.document(user.uid).get();
    }

    presentUser = User.fromDocument(doc);
  }


  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('uid')) {
      return false;
    }
    uidSharedPref = prefs.getString("uid");
    loggedInUserContactNumber = prefs.getString("loggedInUserPhoneNumber");
    print(loggedInUserContactNumber);
  

    notifyListeners();
    return true;
  }

}