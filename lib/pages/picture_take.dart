import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import '../utils/login_utils.dart';
import "./all_Images.dart";
import 'package:http_parser/http_parser.dart'; // Add this import for MediaType
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? image;
  String baseUrl = LoginUtils().baseUrl + 'picture/upload';
  String url = LoginUtils().baseUrl + 'picture/allPictureUrls';

  Future<List<String>> fetchImageUrls(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<String> imageUrls = data.cast<String>();
        return imageUrls;
      } else {
        throw Exception('Failed to load image URLs');
      }
    } catch (error) {
      throw Exception('Failed to fetch image URLs: $error');
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      // Compress the image file
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 50, // Adjust the quality as needed (0 - 100)
      );

      // Encode the compressed bytes to base64
      String base64Image = base64Encode(compressedBytes as List<int>);

      final url = Uri.parse(baseUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image, 'contentType': 'image/jpeg'}),
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
                  onPressed: () async {
                    var imageUrls = await fetchImageUrls(url);
                    print(imageUrls);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageDisplayScreen(
                                  imageUrls: imageUrls,
                                )));
                  },
                  child: Text('All images')),
              ElevatedButton.icon(
                onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? img =
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
                  final XFile? img =
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
