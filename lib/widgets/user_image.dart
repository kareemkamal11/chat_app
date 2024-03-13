import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UsreImagePicker extends StatefulWidget {
  const UsreImagePicker({super.key, required this.onImagePick});

  final void Function(File pickedImage) onImagePick;

  @override
  State<UsreImagePicker> createState() => _UsreImagePickerState();
}

class _UsreImagePickerState extends State<UsreImagePicker> {
  File? pickedImageFile;

  void pickImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );    if (pickedImage == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
    widget.onImagePick(File(pickedImage.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              pickedImageFile == null ? null : FileImage(pickedImageFile!),
        ),
        TextButton.icon(
          onPressed: pickImage,
          icon: const Icon(Icons.image),
          label: Text('Add Image',
              style: TextStyle(color: Theme.of(context).primaryColor)),
        ),
      ],
    );
  }
}
