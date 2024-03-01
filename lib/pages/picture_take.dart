import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import '../utils/login_utils.dart';
import "./all_Images.dart";

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? image;
  String baseUrl = LoginUtils().baseUrl + 'picture/upload';
  Future<void> uploadImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url =
        Uri.parse(baseUrl); // Replace with your server's upload endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Image uploaded successfully');
      await AlertUtils().successfulAlert('Image Uploaded', context);

      Navigator.pop(context);
      // Handle successful upload response
    } else {
      print('Failed to upload image: ${response.reasonPhrase}');
      // Handle failed upload response
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Image'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageListScreen()));
                  },
                  child: Text('All images')),
              ElevatedButton.icon(
                onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  final img =
                      await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    image = img;
                  });
                },
                label: const Text('Choose Image'),
                icon: const Icon(Icons.image),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  final img =
                      await _picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    image = img;
                  });
                },
                label: const Text('Take Photo'),
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
          if (image != null)
            Expanded(
              child: Column(
                children: [
                  Expanded(child: Image.file(File(image!.path))),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        image = null;
                      });
                    },
                    label: const Text('Remove Image'),
                    icon: const Icon(Icons.close),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (image != null) {
                        uploadImage(File(image!.path));
                      }
                    },
                    label: const Text('Upload Image'),
                    icon: const Icon(Icons.cloud_upload),
                  ),
                ],
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
