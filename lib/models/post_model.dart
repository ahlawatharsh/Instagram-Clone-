import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final String postUrl;
  final String profImage;
  final  likes;
  final datePublished;

  PostModel({
    required this.datePublished,
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'description': description,
      'uid': uid,
      'username': username,
      'postId': postId,
      'postUrl': postUrl,
      'profImage': profImage,
      'likes': likes,
      'datePublished': datePublished,
    };
  }

  static PostModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return PostModel(
      username: snapshot['username'],
      uid: snapshot['uid'],
      datePublished: snapshot['datePublished'],
      description: snapshot['description'],
      postId: snapshot['postId'],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      likes: snapshot['likes'],
    );
  }
}
