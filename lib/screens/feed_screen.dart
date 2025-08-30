import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram/models/user_model.dart';

import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/global_variables.dart';
import 'package:instagram/widgets/post_card.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > webScreenSize;
    final UserModel? user = Provider.of<UserProvider>(context).getUser;
    return user == null
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: isWeb
                ? null
                : AppBar(
                    backgroundColor: mobileBackgroundColor,
                    centerTitle: false,
                    title: SvgPicture.asset(
                      'assets/ic_instagram.svg',
                      colorFilter: ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                      height: 35,
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.messenger_outline),
                      ),
                    ],
                  ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .snapshots(),
              builder:
                  (
                    context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.symmetric(
                          vertical: isWeb ? 15 : 0,
                          horizontal: isWeb
                              ? MediaQuery.of(context).size.width * 0.25
                              : 0,
                        ),
                        child: PostCard(
                          snap: snapshot.data!.docs[index].data(),
                        ),
                      ),
                    );
                  },
            ),
          );
  }
}
