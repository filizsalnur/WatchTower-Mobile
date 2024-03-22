import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:watch_tower_flutter/main.dart';
import 'package:watch_tower_flutter/pages/home.dart';
import 'package:watch_tower_flutter/services/login_Services.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';
import '../components/bottom_navigation.dart';
import '../services/nfc_Services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  bool isLightModeSelected = true;
  bool isLoading = true;
  late GoogleMapController mapController;
  List<Map<String, dynamic>> orderArrayData = [];

  final LatLng _center = const LatLng(39.7819185, 32.8199071);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    LoginUtils().getThemeMode().then((value) {
      setState(() {
        isLightModeSelected = value;
      });
    });

    getOrderArray();

    super.initState();
  }

  List<Map<String, dynamic>> parseData(String jsonString) {
    List<dynamic> jsonData = json.decode(jsonString);

    List<Map<String, dynamic>> dataList = [];
    for (var item in jsonData) {
      dataList.add(Map<String, dynamic>.from(item));
    }

    return dataList;
  }

  Future<void> getOrderArray() async {
    ApiResponse orderArray = await NfcService().getOrderArray();
    if (orderArray.statusCode > 400 && orderArray.statusCode < 500) {
      AlertUtils().InfoAlert("Couldn't Find Any Record!", context);
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } else if (orderArray.statusCode >= 500 || orderArray.statusCode == -1) {
      AlertUtils().errorAlert("Check Connection", context);
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } else {
      List<Map<String, dynamic>> orderArrayData2 =
          parseData(orderArray.response);
      print(
          "_=_=_=_=_=_=_=_=_=_=_ ORDER ARRAY LIST _=_=_=_=_=_=_=_=_=_=_=_=_=_=");
      print(orderArrayData);
      setState(() {
        orderArrayData = orderArrayData2;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(
              actions: [
                IconButton(
                  icon: Icon(
                    !isLightModeSelected ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () async {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleThemeMode();

                    setState(() {
                      isLightModeSelected = !isLightModeSelected;
                    });
                  },
                ),
              ],
            )),
        body: isLoading
            ? Center(
                child: SpinKitFadingCircle(
                  color: Colors.blue, // Specify a color here
                  size: 50.0,
                ),
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _getLatLng(orderArrayData[0]),
                  zoom: 15,
                ),
                onMapCreated: _onMapCreated,
                markers: _createMarkers(),
              ),
        bottomNavigationBar: BottomAppBarWidget(
          pageName: "MapPage",
        ));
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

    for (var order in orderArrayData) {
      Marker marker = Marker(
        markerId: MarkerId(order['card_id']),
        position: _getLatLng(order),
        infoWindow: InfoWindow(title: order['name']),
      );
      markers.add(marker);
    }

    return markers;
  }

  LatLng _getLatLng(Map<String, dynamic> data) {
    double lat = double.parse(data['loc']['lat']);
    double long = double.parse(data['loc']['long']);
    return LatLng(lat, long);
  }
}