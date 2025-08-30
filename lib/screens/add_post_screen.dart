import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text.trim(),
        _file!,
        uid,
        username,
        profImage,
      );
      if (res == 'success') {
        setState(() {
          _isLoading = false;
        });
        clearImage();
        showSnackBar("Posted!", context);
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(err.toString(), context);
    }
  }

  _selectImage(BuildContext context) async {
    return _showImagePickerBottomSheet(context);
  }

  Future<void> _showImagePickerBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () => _pickAndSetImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from gallery'),
                onTap: () => _pickAndSetImage(ImageSource.gallery),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndSetImage(ImageSource source) async {
    Navigator.of(context).pop();
    Uint8List? file = await pickImage(source);
    if (file != null && mounted) {
      setState(() {
        _file = file;
      });
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getUser;

    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () => _selectImage(context),
              icon: Icon(Icons.upload, size: 70),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: () {
                  clearImage();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text('Post to'),
              centerTitle: false,
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          postImage(user!.uid, user.username, user.photoUrl),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isLoading ? LinearProgressIndicator() : Container(),
                  const Divider(),
                  //profile row
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user!.photoUrl),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Caption Input
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: null, // expands dynamically
                  ),

                  const SizedBox(height: 20),

                  //image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.memory(_file!, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
