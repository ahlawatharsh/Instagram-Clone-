import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload Post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occured";
    try {
      String photoUrl = await StorageMethods().uploadImageToStorage(
        'posts',
        file,
        true,
      );

      //id for every post
      String postId = Uuid().v1();

      PostModel post = PostModel(
        datePublished: DateTime.now(),
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      await _firestore.collection('posts').doc(postId).set(post.toMap());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    try {
      if (text.isNotEmpty) {
        String commentId = Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
              'profilePic': profilePic,
              'name': name,
              'uid': uid,
              'text': text,
              'commentId': commentId,
              'datePublished': DateTime.now(),
            });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //deleting the post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      List following = (snap.data()! as dynamic)['following'];
      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //edit profile
  Future<String> updateUserProfile({
    required String uid,
    String? username,
    String? bio,
    Uint8List? file, // profile image file (optional)
  }) async {
    String res = "Some error occurred";
    try {
      Map<String, dynamic> updateData = {};

      // If username is provided
      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
      }

      // If bio is provided
      if (bio != null && bio.isNotEmpty) {
        updateData['bio'] = bio;
      }

      // If new profile picture is uploaded
      if (file != null) {
        String photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics',
          file,
          false,
        );
        updateData['photoUrl'] = photoUrl;
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);
        res = "success";
      } else {
        res = "No fields to update";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
