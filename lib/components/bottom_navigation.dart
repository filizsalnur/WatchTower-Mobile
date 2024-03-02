import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_tower_flutter/pages/map-page.dart';
import 'package:watch_tower_flutter/services/device_services.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';
import 'package:web_socket_channel/io.dart';
import '../pages/home.dart';
import '../pages/profile.dart';
import '../pages/alert_screen.dart';
import '../pages/alert_details.dart';
import '../utils/login_utils.dart';
import '../pages/admin_home.dart';

class BottomAppBarWidget extends StatefulWidget {
  final String pageName;
  
  const BottomAppBarWidget({
    Key? key,
    required this.pageName,
  }) : super(key: key);

  @override
  BottomAppBarWidgetState createState() => BottomAppBarWidgetState();
}

class BottomAppBarWidgetState extends State<BottomAppBarWidget> {
    bool isTorchPressed = false;

   String authLevel = '';
  String message = '';
  static String UrlForWebSocket = 'ws://192.168.1.154:3000';
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  final channel = IOWebSocketChannel.connect(UrlForWebSocket);
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> sendMessage(Data message) async {
    try {
      channel.sink.add(message.getJson(message).toString());
    } catch (error) {
      print("error first time sending message:$error");
      channel.sink.add(message.getJson(message).toString());
    }
  }

  @override
  void initState() {
 
    
    _getAuthLevel();
    super.initState();
    // Listen to incoming WebSocket messages

    channel.stream.listen((data) async {
      if (data is String) {
        if (!data.contains(await LoginUtils().getUserId())) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AlertScreen(data: data)));

          setState(() {
            message = data;
          });
        }
      } else {
        String decoded = String.fromCharCodes(data);
        if (!decoded.contains(await LoginUtils().getUserId())) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AlertScreen(data: decoded)));

          setState(() {
            message = decoded;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Future<void> _getAuthLevel() async {
    String getauthLevel = await LoginUtils().getAuthLevel();
    setState(() {
      authLevel = getauthLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 30.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ElevatedButton(
                 onPressed: () async {
                setState(() {
                  isTorchPressed = !isTorchPressed;
                });
                DeviceService().toggleTorch(isTorchPressed);
              },
              child: Icon(
                Icons.flashlight_on_outlined,
                size: 30,
                color: (isTorchPressed)
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: (isTorchPressed)
                    ? MaterialStateProperty.all(Colors.red)
                    : MaterialStateProperty.all(
                        Theme.of(context).colorScheme.background,
                      ),
              ),
            ),
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ElevatedButton(
              onPressed: () {
                if (widget.pageName != "AlertDetail") {
                  if(isTorchPressed){
                    setState(() {
                      isTorchPressed = !isTorchPressed;
                    });
                    DeviceService().toggleTorch(isTorchPressed);
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AlertDetails()),
                    (route) =>
                        false, 
                  );
                }
              },
              child: Icon(
                Icons.add_alert_outlined,
                size: 30,
                color: (widget.pageName == "AlertDetail")
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: (widget.pageName == "AlertDetail")
                    ? MaterialStateProperty.all(Colors.blue)
                    : MaterialStateProperty.all(
                        Theme.of(context).colorScheme.background,
                      ),
              ),
            ),
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ElevatedButton(
              onPressed: () {
                if (widget.pageName != "HomePage" &&
                    widget.pageName != "AdminHomePage") {
                      if(isTorchPressed){
                    setState(() {
                      isTorchPressed = !isTorchPressed;
                    });
                    DeviceService().toggleTorch(isTorchPressed);
                  }
                  if (authLevel == "super_admin" || authLevel == "admin") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AdminHomePage()),
                      (route) => false,
                    );
                  } else if (authLevel == "user") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                  }
                }
              },
              child: Icon(
                Icons.home_outlined,
                size: 30,
                color: (widget.pageName == "HomePage" ||
                        widget.pageName == "AdminHomePage")
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: (widget.pageName == "HomePage" ||
                        widget.pageName == "AdminHomePage")
                    ? MaterialStateProperty.all(Colors.blue)
                    : MaterialStateProperty.all(
                        Theme.of(context).colorScheme.background,
                      ),
              ),
            ),
            /////////////////////////////////////////////////////////////////////////////////////////////////////
             ElevatedButton(
              onPressed: () {
                if (widget.pageName != "MapPage") {
                   if(isTorchPressed){
                    setState(() {
                      isTorchPressed = !isTorchPressed;
                    });
                    DeviceService().toggleTorch(isTorchPressed);
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                    (route) =>
                        false, 
                  );
                }
              },
              child: Icon(
                Icons.location_on_outlined,
                size: 30,
                color: (widget.pageName == "MapPage")
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: (widget.pageName == "MapPage")
                    ? MaterialStateProperty.all(Colors.blue)
                    : MaterialStateProperty.all(
                        Theme.of(context).colorScheme.background,
                      ),
              ),
            ),
            ///////////////////////////////////////////////////////////////////////////////////////////////////
             ElevatedButton(
              onPressed: () {
                if (widget.pageName != "ProfilePage") {
                   if(isTorchPressed){
                    setState(() {
                      isTorchPressed = !isTorchPressed;
                    });
                    DeviceService().toggleTorch(isTorchPressed);
                  }
                 Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                    (route) =>
                        false, 
                  );
                }
              },
              child: Icon(
                Icons.person_outlined,
                size: 30,
                color: (widget.pageName == "ProfilePage")
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: (widget.pageName == "ProfilePage")
                    ? MaterialStateProperty.all(Colors.blue)
                    : MaterialStateProperty.all(
                        Theme.of(context).colorScheme.background,
                      ),
              ),
            ),
            
          
          ],
        ),
      ),
    );
  }
}
