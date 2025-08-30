import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/search_screen.dart';

const webScreenSize = 600;
final currentUser = FirebaseAuth.instance.currentUser;
final homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text('4'),
  ProfileScreen(uid: currentUser!.uid),
];
