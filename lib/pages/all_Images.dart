import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watch_tower_flutter/pages/picture_take.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';

class ImageDisplayScreen extends StatefulWidget {
  final List<String> imageUrls;

  const ImageDisplayScreen({Key? key, required this.imageUrls})
      : super(key: key);

  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  int _currentIndex = 0;
  bool _isFullScreen = false;
  late String _selectedImageUrl;

  void _showFullScreenImage(String imageUrl) {
    setState(() {
      _isFullScreen = true;
      _selectedImageUrl = imageUrl;
    });
  }

  void _closeFullScreenImage() {
    setState(() {
      _isFullScreen = false;
      _selectedImageUrl = '';
    });
  }

  String url = LoginUtils().baseUrl + 'picture/deleteImage';
  void deleteImage(String id) async {
    try {
      id = id.split('/').last;
      print("id  =>>>>>>>>>>>>$id");

      String deleteUrl = url + '/$id';
      print(deleteUrl);

      final response = await http.post(
        Uri.parse(deleteUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await AlertUtils().successfulAlert('Photo deleted ', context);
        // Refresh the page to remove the deleted image from the list
        setState(() {
          widget.imageUrls.removeWhere((url) => url.contains(id));
        });
        Duration(seconds: 1);
        _closeFullScreenImage();
      } else {
        print('Failed to delete image: ${response.statusCode}');
        await AlertUtils().errorAlert('Unable to delete photo', context);
        _closeFullScreenImage();
      }
    } catch (e) {
      print('Error deleting image: $e');
      await AlertUtils().errorAlert('Unable to delete photo', context);
      _closeFullScreenImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Display'),
      ),
      body: _isFullScreen
          ? Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _closeFullScreenImage,
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: Image.network(_selectedImageUrl),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    deleteImage(_selectedImageUrl);
                  },
                  child: Text('Delete Image'),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < widget.imageUrls.length; i += 2)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showFullScreenImage(widget.imageUrls[i]);
                              },
                              child: Image.network(
                                widget.imageUrls[i],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (i + 1 < widget.imageUrls.length)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _showFullScreenImage(widget.imageUrls[i + 1]);
                                },
                                child: Image.network(
                                  widget.imageUrls[i + 1],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
