import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Search with username'),
          onChanged: (value) {
            setState(() {
              searchText = value
                  .trim()
                  .toLowerCase(); // live search + lowercase
            });
          },
        ),
      ),
      body: searchText.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username', //  store usernames in lowercase too
                    isGreaterThanOrEqualTo: searchText,
                  )
                  .where('username', isLessThan: searchText + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs.where(
                  (doc) => doc['uid'] != currentUserId, // remove current user
                );

                if (docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView(
                  children: docs.map((doc) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(uid: doc['uid']),
                        ),
                      ),

                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(doc['photoUrl']),
                        ),
                        title: Text(doc['username']),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy("datePublished", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;
                return SingleChildScrollView(
                  child: StaggeredGrid.count(
                    crossAxisCount: 3, 
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: List.generate(docs.length, (index) {
                      final post = docs[index].data() as Map<String, dynamic>;

                     
                      final bool isBigTile =
                          Random().nextInt(7) == 0; 

                      return StaggeredGridTile.count(
                        crossAxisCellCount: isBigTile ? 2 : 1,
                        mainAxisCellCount: isBigTile ? 2 : 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post['postUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
    );
  }
}
