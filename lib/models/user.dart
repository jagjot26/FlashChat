import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/home_screen.dart';

class User {
  final String id;
  final String displayName;
  final String bio;
  final String phoneNumber;
  final String imageDownloadUrl;


  User({
    this.id,
    this.displayName,
    this.bio,
    this.phoneNumber,
    this.imageDownloadUrl,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      phoneNumber: doc['phoneNumber'],
      imageDownloadUrl : doc['imageDownloadUrl'],
    );
  }
}
