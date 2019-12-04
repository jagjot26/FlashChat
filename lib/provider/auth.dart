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
QuerySnapshot qs;
bool userExistsInFirebase = false;

class Auth with ChangeNotifier {
  User presentUser;
  String uidSharedPref;
  FirebaseUser user;
  String loggedInUserIDSharedPref;
  String loggedInUserContactNumber;
  String loggedInUserName;

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


  createUserInFireStore(FirebaseUser user, String phoneNumber, String displayName, String downloadUrl) async {
    // 1) check if user exists in users collection in database (according to their id)
    DocumentSnapshot doc;
    
    final prefs2 = await SharedPreferences.getInstance();
      prefs2.setString("loggedInUserPhoneNumber", phoneNumber);

    final prefs3 = await SharedPreferences.getInstance();
    prefs3.setString("loggedInUserImage", downloadUrl);

    final prefs4 = await SharedPreferences.getInstance();
    prefs4.setString("loggedInUserName", displayName);

    final prefs6 = await SharedPreferences.getInstance();
    prefs6.setString("loggedInUserBio", "Hello there, I'm available for chat");


      // 2) if the user doesn't exist, then we want to take them to the create account page
//      final username = await Navigator.push(
//          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.uid).setData({
        "id": user.uid,
        "displayName": displayName,
        "bio": "Hello there, I'm available for chat",
        "phoneNumber": phoneNumber,
        "timestamp": timestamp,
        "imageDownloadUrl" : downloadUrl
      });    
    
      
      doc = await usersRef.document(user.uid).get();
    
    
    qs =  await usersRef.getDocuments();
    var listOfDocuments = qs.documents;
    for(var dc in listOfDocuments){
     if(dc["displayName"] == displayName || dc["phoneNumber"]==phoneNumber)
     {
       userExistsInFirebase = true;
       break;
     }     
    }
    final prefs5 = await SharedPreferences.getInstance();
    if(userExistsInFirebase == true){
      prefs5.setString("recentlyLoggedInUser","exists");
    }
    presentUser = User.fromDocument(doc);
  }


  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('recentlyLoggedInUser')) {
      return false;
    }
    uidSharedPref = prefs.getString("uid");
    loggedInUserContactNumber = prefs.getString("loggedInUserPhoneNumber");
    print(loggedInUserContactNumber);
  

    notifyListeners();
    return true;
  }

}