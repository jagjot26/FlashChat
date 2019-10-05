import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class User {
  final String id;
  final String displayName;
  final String bio;
  final String phoneNumber;


  User({
    this.id,
    this.displayName,
    this.bio,
    this.phoneNumber,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      phoneNumber: doc['phoneNumber'],
    );
  }
}
