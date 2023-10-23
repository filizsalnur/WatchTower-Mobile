// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import './nfcHome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isStartSelected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(36, 32, 50, 1000),
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(backgroundColor: Color.fromARGB(57, 108, 126, 241))
          ),
        body: SingleChildScrollView(
        
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                SizedBox(height: 250),
               Center(
                 child: ElevatedButton(
                    
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.all(65),
                      shape: CircleBorder()
                    ),
                  onPressed: () {
                     Navigator.push(context,
                          MaterialPageRoute(builder: (context) => NfcHomePage()));
                  },
                  child:  Text(
                    'Start Tour',
                    style: TextStyle(fontSize: 30.0),
                    ), 
                 ),
               )
              ],
        
          ),
        ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 50,
          color: Color.fromARGB(57, 108, 126, 241),
          child: Padding(
            padding: const EdgeInsets.only(top:10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.flashlight_on),
                  color: Colors.white,
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_alert_sharp),
                  color: Colors.white,
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.home),
                  color: Colors.white,
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.white,
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  color: Colors.white,
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
