import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    return UserModel.fromSnap(snap);
  }

  //signup with email & password
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        //register user now
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        //uplaod profile image to storage
        String photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics',
          file,
          false,
        );
        // print(userCredential.user!.uid);

        UserModel user = UserModel(
          username: username.toLowerCase(),
          uid: userCredential.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: photoUrl,
        );

        //add user deatils to database
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());
        res = 'success';
      } else {
        res = "Enter all fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is not a valid email';
      } else if (err.code == 'weak-password') {
        res = 'Your password is weak!';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //loggin the user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occured';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'success';
      } else {
        res = 'Please enter all fields';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is not a valid email';
      } else if (err.code == 'wrong-password') {
        res = 'Your password is incorrect!';
      } else if (err.code == 'user-not-found') {
        res = 'User not found. Please signup';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
