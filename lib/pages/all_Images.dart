import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageDisplayScreen extends StatefulWidget {
  final List<String> imageUrls;

  const ImageDisplayScreen({Key? key, required this.imageUrls}) : super(key: key);

  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Display'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.network(widget.imageUrls[_currentIndex]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = (_currentIndex - 1) % widget.imageUrls.length;
                    if (_currentIndex < 0) {
                      _currentIndex += widget.imageUrls.length;
                    }
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % widget.imageUrls.length;
                  });
                },
                icon: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
