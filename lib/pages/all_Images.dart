import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watch_tower_flutter/utils/alarm_utils.dart';
import '../utils/login_utils.dart';

class ImageListScreen extends StatefulWidget {
  @override
  State<ImageListScreen> createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  List<List<int>> imageDataList = []; // List to store image data

  String baseUrl = LoginUtils().baseUrl + 'picture/allPictures';

  List<int> getImageData(Map<String, dynamic> imageData) {
    if (imageData['type'] != 'Buffer') {
      throw ArgumentError('Invalid image data format');
    }

    final List<dynamic> bufferData = imageData['data'];
    return bufferData.map<int>((dynamic value) => value as int).toList();
  }

  String newBaseUrl = LoginUtils().baseUrl;

  int imageNumbers = 0;

  Future<void> getImageNumbers() async {
    final response =
        await http.get(Uri.parse(newBaseUrl + 'picture/numberOfPictures'));
    if (response.statusCode <= 399) {
      int counter = int.parse(response.body);
      setState(() {
        imageNumbers = counter;
      });
    }
  }

  Future<void> fetchImage(int i) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'index': i}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> imageDataListJson = jsonDecode(response.body);
        if (imageDataListJson.isNotEmpty &&
            imageDataListJson[0] is Map<String, dynamic>) {
          final Map<String, dynamic> imageDataJson = imageDataListJson[0];
          final List<int> imageDataBytes = getImageData(imageDataJson);
          setState(() {
            imageDataList.add(imageDataBytes);
          });
        } else {
          print('Invalid image data format');
        }
      } else {
        print('Failed to fetch image: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getImageNumbers().then((_) {
      for (int index = 0; index < imageNumbers; index++) {
        fetchImage(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
      ),
      body: ListView.builder(
        itemCount: imageDataList.length,
        // itemCount: imageNumbers,
        itemBuilder: (BuildContext context, int index) {
          // if (imageDataList.length <= index) {
          //   fetchImage(index);
          // }
          return imageDataList.length > index
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.memory(
                    Uint8List.fromList(imageDataList[index]),
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}
