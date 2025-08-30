import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String uid;
  final String email;
  final String bio;
  final List followers;
  final List following;
  final String photoUrl;

  UserModel({
    required this.username,
    required this.uid,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
    'username': username.toLowerCase(),
    'uid': uid,
    'email': email,
    'bio': bio,
    'followers': followers,
    'following': following,
    'photoUrl': photoUrl,
  };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      bio: snapshot['bio'],
      followers: snapshot['followers'],
      following: snapshot['following'],
      photoUrl: snapshot['photoUrl'],
    );
  }
}
