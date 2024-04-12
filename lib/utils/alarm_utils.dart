import 'package:web_socket_channel/io.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';
import 'package:http/http.dart' as http;

String BaseUrl = LoginUtils().baseUrl;

class WebSocketService {
  static IOWebSocketChannel? _channel;

  static void dispose() {
    _channel?.sink.close();
    _channel = null;
  }

  Future<int> sendBroadcastMessageFirebase() async {
    try {
      print('what is being broadcasted from FireBase: ');

      final response = await http.get(
        Uri.parse('${BaseUrl}sendHelloMessage'),
      );

      if (response.statusCode >= 399) {
        print('ERROR at FireBase: ${response.body}');
      } else {
        print('Message sent to topic from FireBase: ${response.body}');
      }
      return response.statusCode;
    } catch (e) {
      print("error while broadcasting message from FireBase: $e");
      return 500;
    }
  }
}
