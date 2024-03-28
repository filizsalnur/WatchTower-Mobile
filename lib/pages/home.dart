// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:watch_tower_flutter/main.dart';
import 'package:watch_tower_flutter/services/login_Services.dart';
import 'package:watch_tower_flutter/services/session_services.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';
import '../components/bottom_navigation.dart';
import './nfcHome.dart';
import '../components/custom_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/viewNotification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLightModeSelected = true;
  String userName = "";
  bool isSessionActive = false;
  List<String> englishMonthAbbreviations = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  void initState() {
    LoginUtils().getThemeMode().then((value) {
      setState(() {
        isLightModeSelected = value;
      });
    });

    _checkSessionStatus();
    _loadSavedCredentials();
    super.initState();
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    getAlertCount(context);
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
  }

  Future _checkSessionStatus() async {
    ApiResponse sessionStatusResponse =
        await SessionService().checkSessionStatus();
    if (sessionStatusResponse.statusCode < 400) {
      setState(() {
        isSessionActive = true;
      });
    } else if (sessionStatusResponse.statusCode > 400) {
      setState(() {
        isSessionActive = false;
      });
    }
  }

  String createDate(int index) {
    DateTime now = DateTime.now().add(Duration(days: index));
    String formattedDate = DateFormat('dd').format(now);
    return formattedDate;
  }

  int createMonth(int index) {
    DateTime now = DateTime.now().add(Duration(days: index));
    String formatted = DateFormat('MM').format(now);
    int formattedMonth = int.parse(formatted);
    return formattedMonth - 1;
  }

  void _loadSavedCredentials() async {
    final credentials = await LoginUtils().loadSavedCredentials();
    String email = credentials.email;

    int atIndex = email.indexOf("@");

    String updatedEmail = email.substring(0, atIndex);
    updatedEmail = updatedEmail.replaceAll(".", " ");
    updatedEmail = updatedEmail.replaceFirst(
        updatedEmail[0], updatedEmail[0].toUpperCase());
    updatedEmail = updatedEmail.replaceFirst(
        updatedEmail[updatedEmail.indexOf(' ') + 1],
        updatedEmail[updatedEmail.indexOf(' ') + 1].toUpperCase());
    setState(() {
      userName = updatedEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/profile_1.png'),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int i = 0; i < 4; i++)
                        Card(
                            color: (i == 0)
                                ? Colors.blue
                                : Theme.of(context).colorScheme.background,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  width: 2),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width / 5,
                              width: MediaQuery.of(context).size.width / 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    createDate(i),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    englishMonthAbbreviations[createMonth(i)],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                    ],
                  ),
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
                      text: "Second Card",
                      title: "Card 2",
                      imgRoute: "assets/images/nfc_reader.png",
                      customWidth: 'full',
                      navigatorName: "",
                    ),
                    CustomCard(
                      text: "Third Card",
                      title: "Card 3",
                      imgRoute: "assets/images/nfc_reader.png",
                      customWidth: 'full',
                      navigatorName: "",
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.blue, width: 2)),
                    color: Theme.of(context).colorScheme.background,
                    clipBehavior: Clip.hardEdge,
                    shadowColor: Colors.blueGrey,
                    child: InkWell(
                      splashColor: Colors.grey.withAlpha(90),
                      // onTap: () {
                      //   if (isSessionActive) {
                      //     AlertUtils()
                      //         .confirmationAlert('New Session', context);
                      //   } else {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => NfcHomePage()),
                      //     );
                      //   }
                      // },
                      child: SizedBox(
                        height: 200,
                        width: MediaQuery.of(context).size.width - 48,
                        child: InkWell(
                          onTap: () async {
                            if (isSessionActive) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NfcHomePage(
                                          isOldSessionOn: true,
                                        )),
                              );
                            } else {
                              String newSessionMessage = (isSessionActive)
                                  ? 'Your current session data will be cleared'
                                  : 'You will start a new session';
                              bool isConfirmed = await AlertUtils()
                                  .confirmSessionAlert(
                                      newSessionMessage, context);

                              if (isSessionActive) {
                                if (isConfirmed) {
                                  SessionService()
                                      .startNewSessionAndEndTheLatest(context);
                                }
                              } else {
                                if (isConfirmed) {
                                  SessionService().startNewSession(context);
                                }
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                          isSessionActive
                                              ? "Continue Last Session!"
                                              : "Start New Session!",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue)),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text("Scan NFC Tags Now",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    if (!isSessionActive)
                                      ElevatedButton(
                                        onPressed: () async {
                                          String newSessionMessage = (isSessionActive)
                                              ? 'Your current session data will be cleared'
                                              : 'You will start a new session';
                                          bool isConfirmed = await AlertUtils()
                                              .confirmSessionAlert(
                                                  newSessionMessage, context);

                                          if (isSessionActive) {
                                            if (isConfirmed) {
                                              SessionService()
                                                  .startNewSessionAndEndTheLatest(
                                                      context);
                                            }
                                          } else {
                                            if (isConfirmed) {
                                              SessionService()
                                                  .startNewSession(context);
                                            }
                                          }
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
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.blue),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(28.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (isSessionActive)
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NfcHomePage(
                                                      isOldSessionOn: true,
                                                    )),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0,
                                              right: 0,
                                              top: 10,
                                              bottom: 10),
                                          child: Text('Continue Session',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.blue),
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
                            ],
                          ),
                        ),
                      ),
                    )),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      CustomCard(
                        text: "Start New Session",
                        title: "Card 1",
                        imgRoute: "assets/images/nfc.png",
                        customWidth: 'half',
                        navigatorName: "",
                      ),
                      CustomCard(
                        text: "Second Card",
                        title: "Card 2",
                        imgRoute: "assets/images/nfc.png",
                        customWidth: 'half',
                        navigatorName: "",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBarWidget(
          pageName: "HomePage",
        ),
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

  Future<void> getAlertCount(BuildContext context) async {
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    try {
      final response = await http.get(
        Uri.parse('${LoginUtils().baseUrl}picture/alertNumber'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode < 399) {
        // Parse the response body as JSON
        final int res = json.decode(response.body) - 1;
        print('Alert count: $res');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('alertCount')) {
          int alertCount = int.parse(prefs.getString('alertCount')!);
          print(alertCount);
          int newAlerts = res - alertCount;
          print('number of new alerts : $newAlerts');
          if (newAlerts > 0) {
            ////// call the function to trigger the notification
            getAlertByIndex(alertCount + 1, context);
            int newAlertCount = alertCount + 1;
            prefs.setString('alertCount', newAlertCount.toString());
          } else if (newAlerts == 0) {
            print('No new alerts');
          } else if (newAlerts < 0) {
            prefs.setString('alertCount', res.toString());
            await getAlertCount(context);
          }
        } else {
          prefs.setString('alertCount', res.toString());
        }
      } else {
        print('ERROR: ${response.body}');
      }
    } catch (e) {
      print("Error in db_services: $e");
    }

    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
    print(
        '---====---===---====---===---====---===---====---===---====---===---====---===---====---===');
  }

  Future<void> getAlertByIndex(
    int index,
    BuildContext context,
  ) async {
    print(
        'triggered notificationtriggered notificationtriggered notificationtriggered notificationtriggered notification');
    print(index);
    try {
      final response = await http.post(
          Uri.parse('${LoginUtils().baseUrl}picture/showAlertByIndex'),
          body: {
            'index': index.toString(),
          });

      final decodedResponse = json.decode(response.body);
      final imageUrl = decodedResponse['url'];
      final imageId = decodedResponse['id'];
      final email = decodedResponse['email'];
      final alertType = decodedResponse['alertType'];
      final alertBody = decodedResponse['alertBody'];
      final alertDate = decodedResponse['createdAt'];
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text('New Alert Received'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View Alert',
            textColor: Colors.white,
            backgroundColor: Colors.purple,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewAlertPage(
                            imageUrl: imageUrl,
                            imageId: imageId,
                            email: email,
                            alertType: alertType,
                            alertBody: alertBody,
                            alertDate: alertDate,
                          )));
            },
          ),
        ),
      );

      print("========================================");
      print(response.body);
      print("========================================");
    } catch (e) {
      print("Error in db_services: $e");
    }
  }
}
