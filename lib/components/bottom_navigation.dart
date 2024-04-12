import 'package:flutter/material.dart';
import 'package:watch_tower_flutter/pages/map-page.dart';
import 'package:watch_tower_flutter/services/device_services.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';
import '../pages/home.dart';
import '../pages/profile.dart';
import '../pages/alert_details.dart';
import '../pages/admin_home.dart';

class BottomAppBarWidget extends StatefulWidget {
  final String pageName;
  const BottomAppBarWidget({
    super.key,
    required this.pageName,
  });

  @override
  BottomAppBarWidgetState createState() => BottomAppBarWidgetState();
}

class BottomAppBarWidgetState extends State<BottomAppBarWidget> {
  bool isTorchPressed = false;
  String authLevel = '';
  String message = '';

  @override
  void initState() {
    _getAuthLevel();
    super.initState();
    // Listen to incoming WebSocket messages
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
            IconButton(
              icon: const Icon(Icons.flashlight_on_outlined),
              iconSize: 40,
              onPressed: () async {
                setState(() {
                  isTorchPressed = !isTorchPressed;
                });
                DeviceService().toggleTorch(isTorchPressed);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_alert_outlined),
              iconSize: 40,
              onPressed: () {
                if (widget.pageName != "AlertDetail") {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AlertDetails()),
                    (route) => false,
                  );
                }
              },
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2.0),
                color: Colors.blue,
              ),
              child: IconButton(
                icon: const Icon(Icons.home_outlined),
                color: Theme.of(context).colorScheme.background,
                iconSize: 40,
                onPressed: () {
                  if (widget.pageName != "HomePage" &&
                      widget.pageName != "AdminHomePage") {
                    if (authLevel == "super_admin" || authLevel == "admin") {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminHomePage()),
                        (route) => false,
                      );
                    } else if (authLevel == "user") {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.location_on_outlined),
              iconSize: 40,
              onPressed: () async {
                if (widget.pageName != "MapPage") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPage()),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outlined),
              iconSize: 40,
              onPressed: () {
                if (widget.pageName != "ProfilePage") {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                    (route) =>
                        false, // This condition always returns false, so it clears everything
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
