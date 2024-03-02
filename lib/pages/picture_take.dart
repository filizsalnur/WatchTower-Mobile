import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import '../utils/login_utils.dart';
import "./all_Images.dart";
import 'package:http_parser/http_parser.dart'; // Add this import for MediaType

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? image;
  String baseUrl = LoginUtils().baseUrl + 'picture/upload';

  Future<void> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(baseUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Image uploaded successfully
        print('Image uploaded successfully');
        await AlertUtils().successfulAlert('Image Uploaded', context);
        Navigator.pop(context);
      } else {
        print('Failed to upload image: ${response.reasonPhrase}');
        await AlertUtils().errorAlert('Image Upload Failed', context);
        Navigator.pop(context);
      }
    } catch (error) {
      print('Error uploading image: $error');
      await AlertUtils().errorAlert('Image Upload Failed', context);
      Navigator.pop(context);
    }
  }

  // Future<void> uploadImage(File imageFile) async {
  //   try {
  //     final url = Uri.parse(baseUrl);
  //     final request = http.MultipartRequest('POST', url);

  //     // Add the image file to the request
  //     request.files.add(await http.MultipartFile.fromPath(
  //       'image',
  //       imageFile.path,
  //       filename: 'image.jpg', // Adjust the filename as needed
  //       contentType: MediaType(
  //           'image', 'jpeg'), // Adjust content type based on your image type
  //     ));

  //     // Send the request
  //     final response = await request.send();

  //     if (response.statusCode == 200) {
  //       // Image uploaded successfully
  //       print('Image uploaded successfully');
  //       // Extract the imageURL from the response
  //       final responseData = await response.stream.bytesToString();
  //       final imageUrl = jsonDecode(responseData)['imageUrl'];
  //       print("imageUrl is: $imageUrl");
  //       // Use imageUrl as needed (e.g., save it to display the image in your app)
  //       await AlertUtils().successfulAlert('Image Uploaded', context);
  //       Navigator.pop(context);
  //     } else {
  //       // Failed to upload image
  //       print('Failed to upload image: ${response.reasonPhrase}');
  //       // Handle failed upload response
  //     }
  //   } catch (error) {
  //     print('Error uploading image: $error');
  //     // Handle errors
  //   }
  // }

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
