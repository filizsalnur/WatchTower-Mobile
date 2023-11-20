import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:watch_tower_flutter/components/bottom_navigation.dart';
import 'package:watch_tower_flutter/pages/home.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import 'package:web_socket_channel/io.dart';
import '../components/bottom_navigation.dart';
import '../utils/login_utils.dart';
import '../components/bottom_navigation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/alarm_utils.dart';

class Data {
  String content;
  String type;
  String topic;
  String id;
  Data(this.content, this.type, this.topic, this.id);
  List<String> getJson(Data message) {
    content = message.content;
    type = message.type;
    topic = message.topic;
    id = message.id;
    List<String> list = [content, type, topic, id];
    return list;
  }
}

class AlertDetails extends StatefulWidget {
  const AlertDetails({Key? key}) : super(key: key);
  static const routeName = '/alert_details';

  @override
  State<AlertDetails> createState() => _AlertDetailsState();
}

class _AlertDetailsState extends State<AlertDetails> {
  final TextEditingController textFieldController1 = TextEditingController();
  final TextEditingController textFieldController2 = TextEditingController();
  final TextEditingController textFieldController3 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textFieldController1,
              decoration: InputDecoration(
                  labelText: 'content',
                  labelStyle: TextStyle(color: Colors.white)),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: textFieldController2,
              decoration: InputDecoration(
                  labelText: 'type',
                  labelStyle: TextStyle(color: Colors.white)),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: textFieldController3,
              decoration: InputDecoration(
                  labelText: 'topic',
                  labelStyle: TextStyle(color: Colors.white)),
              style: TextStyle(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () async {
                Data data = Data(
                    textFieldController1.text,
                    textFieldController2.text,
                    textFieldController3.text,
                    await LoginUtils().getUserId());
                await BottomAppBarWidgetState().sendMessage(data);
                int res = await WebSocketService().sendBroadcastMessageFirebase(
                    textFieldController1.text,
                    textFieldController2.text,
                    'Broadcast_Alert');
                if (res >= 399) {
                  await AlertUtils().errorAlert('Failed to send', context);
                } else {
                  await AlertUtils().successfulAlert('Success', context);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false,
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      );
  }
}
