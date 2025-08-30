import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/screens/comment_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLength = 0;
  @override
  void initState() {
    super.initState();
    getComments();
  }

  Future<void> getComments() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .get();
    if (!mounted) return;
    setState(() {
      commentLength = snap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          //header section
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 12,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.snap['profImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['username'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final UserModel? user = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).getUser;

                    if (user!.uid == widget.snap['uid']) {
                      // Only show delete option if current user is the owner
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Post"),
                            content: const Text(
                              "Are you sure you want to delete this post?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await FirestoreMethods().deletePost(
                                    widget.snap['postId'],
                                  );
                                  Navigator.of(context).pop(); // close dialog
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // If not owner, maybe show a report option later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You can’t delete this post."),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          //Image section
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap['postId'],
                user!.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width - 4,

                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    smallLike: false,
                    duration: Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: primaryColor,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //LIKE COMMENT SECTION
          Row(
            children: [
              LikeAnimation(
                smallLike: true,
                isAnimating: widget.snap['likes'].contains(user!.uid),
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                      widget.snap['postId'],
                      user.uid,
                      widget.snap['likes'],
                    );
                  },
                  icon: widget.snap['likes'].length > 0
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite_outline),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommentScreen(snap: widget.snap),
                  ),
                ),
                icon: Icon(Icons.comment_outlined),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.send)),
              Expanded(
                child: Align(
                  alignment: AlignmentGeometry.bottomRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.bookmark_border),
                  ),
                ),
              ),
            ],
          ),

          //Description and no. of comments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.snap['likes'].length} likes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 5),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: " ${widget.snap['description']}"),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all $commentLength comments',
                      style: TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                  ),
                ),
                Text(
                  DateFormat(
                    "d MMM yyyy h:mma",
                  ).format(widget.snap['datePublished'].toDate()),

                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
