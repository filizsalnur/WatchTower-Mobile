import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:watch_tower_flutter/components/bottom_navigation.dart';
import 'package:watch_tower_flutter/pages/alert_details.dart';
import 'package:watch_tower_flutter/pages/home.dart';
import 'package:watch_tower_flutter/pages/profile.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import '../utils/login_utils.dart';
import "./all_Images.dart";
 
// Add this import for MediaType
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImagePickerScreen extends StatefulWidget {
  final String alertBody;
  final String alertType;
  const ImagePickerScreen({
    super.key,
    required this.alertBody,
    required this.alertType,
  });

  @override
  State<ImagePickerScreen> createState() => ImagePickerScreenState();
}

class ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? image;
  String baseUrl = '${LoginUtils().baseUrl}picture/upload';
  String url = '${LoginUtils().baseUrl}picture/allPictureUrls';
  bool _isLoading = false;

  Future<List<String>> fetchImageUrls(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<String> imageUrls = data.cast<String>();
        print(imageUrls);
        return imageUrls;
      } else {
        throw Exception('Failed to load image URLs');
      }
    } catch (error) {
      throw Exception('Failed to fetch image URLs: $error');
    }
  }

  Future<void> uploadImage(
      File imageFile, String alertBody, String alertType) async {
    try {
      // Compress the image file
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 10, // Adjust the quality as needed (0 - 100)
      );

      // Encode the compressed bytes to base64
      String base64Image = base64Encode(compressedBytes as List<int>);
      String email = await ProfilePageState().getEmail();
      print(email);
      final url = Uri.parse(baseUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'contentType': 'image/jpeg',
          'alertType': alertType,
          'alertBody': alertBody,
          'userEmail': email
        }),
      );
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Image uploaded successfully
        print('Image uploaded successfully');
        //////////////////////////////////////////////////////////////////////////////
//        AlertServices().getAlertByIndex(context);
        ///////////////////////////////////////////////////////////////////////////////////////
        await AlertUtils().successfulAlert('Image Uploaded', context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
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
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Add Image'),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? img =
                            await picker.pickImage(source: ImageSource.camera);
                        setState(() {
                          image = img;
                        });
                      },
                      label: const Text('Camera'),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        size: 30,
                        color: (Colors.deepOrange),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? img =
                            await picker.pickImage(source: ImageSource.gallery);
                        setState(() {
                          image = img;
                        });
                      },
                      label: const Text('Choose Image'),
                      icon: const Icon(
                        Icons.image,
                        size: 30,
                        color: (Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        var imageUrls = await fetchImageUrls(url);
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageDisplayScreen(
                              imageUrls: imageUrls,
                            ),
                          ),
                        );
                      },
                      label: const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(
                        Icons.photo_album_outlined,
                        size: 40,
                        color: (Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
              ),
              if (image != null)
                Expanded(
                  child: Column(
                    children: [
                      ////////////////////////////////////////
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AlertDetails(),
                              ));
                        },
                        label: const Text('Alert'),
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          size: 30,
                          color: (Colors.purple),
                        ),
                      ),
                      ////////////////////////////////////////
                      ////////
                      Expanded(child: Image.file(File(image!.path))),
                      Container(
                        child: Column(children: [
                          Text(widget.alertBody),
                          Text(widget.alertType),
                        ]),
                      ),

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
                        onPressed: () async {
                          if (image != null) {
                            uploadImage(
                                File(
                                  image!.path,
                                ),
                                widget.alertBody,
                                widget.alertType);
                          } else {
                            await AlertUtils()
                                .errorAlert('Please Add a Picture', context);
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
          bottomNavigationBar: const BottomAppBarWidget(
            pageName: 'ImagePicker',
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: SpinKitCubeGrid(
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ),
      ],
    );
  }
}
