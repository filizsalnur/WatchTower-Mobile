// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:watch_tower_flutter/pages/login.dart';
import 'package:watch_tower_flutter/utils/alarm_utils.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import './nfcHome.dart';
import '../components/bottom_navigation.dart';
import '../services/nfc_Services.dart';
import './admin_nfc_order.dart';
import '../components/custom_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Quick Access",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 2.0,
                      enlargeCenterPage: false,
                    ),
                    items: [
                      CustomCard(
                          text: "First Card",
                          title: "Card 1",
                          imgRoute: "assets/images/nfc_reader.png",
                          customWidth: 'full',
                          navigatorName: ""),
                      CustomCard(
                          text: "Second Card",
                          title: "Card 2",
                          imgRoute: "assets/images/nfc_reader.png",
                          customWidth: 'full',
                          navigatorName: ""),
                      CustomCard(
                          text: "Third Card",
                          title: "Card 3",
                          imgRoute: "assets/images/nfc_reader.png",
                          customWidth: 'full',
                          navigatorName: ""),
                    ],
                  ),
                  SizedBox(height: 20),
                  Card(
                      color: Colors.purple.shade800,
                      clipBehavior: Clip.hardEdge,
                      shadowColor: Colors.blueGrey,
                      child: InkWell(
                        splashColor: Colors.grey.withAlpha(90),
                        onTap: () {
                          if (NfcHomePageState.session == false) {
                            AlertUtils()
                                .confirmationAlert('New Session', context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LayoutPage(index: 4)),
                            );
                          }
                        },
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width - 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text("Start Tour!",
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text("Scan NFC Tags Now",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        AlertUtils().confirmationAlert(
                                            'New Session', context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0,
                                            right: 0,
                                            top: 10,
                                            bottom: 10),
                                        child: Text('New Session',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(28.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image(
                                image:
                                    AssetImage('assets/images/nfc_reader.png'),
                                height: 180,
                              ),
                            ],
                          ),
                        ),
                      )),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      CustomCard(
                          text: "First Card",
                          title: "Card 1",
                          imgRoute: "assets/images/nfc_reader.png",
                          customWidth: 'half',
                          navigatorName: ""),
                      CustomCard(
                          text: "Second Card",
                          title: "Card 2",
                          imgRoute: "assets/images/nfc_reader.png",
                          customWidth: 'half',
                          navigatorName: ""),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                ],
              ),
            ),
          ),
        );
      
  }
}
