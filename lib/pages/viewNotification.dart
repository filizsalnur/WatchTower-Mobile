import 'package:flutter/material.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';

class ViewAlertPage extends StatefulWidget {
  final String imageUrl;
  final String imageId;
  final String email;
  final String alertType;
  final String alertBody;
  final String alertDate;

  const ViewAlertPage({
    super.key,
    required this.imageUrl,
    required this.imageId,
    required this.email,
    required this.alertType,
    required this.alertBody,
    required this.alertDate,
  });

  @override
  ViewAlertPageState createState() => ViewAlertPageState();
}

class ViewAlertPageState extends State<ViewAlertPage> {
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

  String getDateComponents(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    //return [dateTime.day, dateTime.month, dateTime.year];
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String getTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }

  String url = '${LoginUtils().baseUrl}picture/deleteImage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Display'),
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
                        child: Image.network(
                          _selectedImageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showFullScreenImage(widget.imageUrl);
                    },
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Card(
                    color: Colors.purple,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Alert Type: ${widget.alertType}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.purple,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Alert Body: ${widget.alertBody}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.purple,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Alert Date and Time: ${getDateComponents(widget.alertDate)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${getTime(widget.alertDate)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.purple,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Reporter Email: ${widget.email}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}
