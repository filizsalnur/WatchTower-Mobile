// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import '../pages/admin_user_list.dart';
import '../services/payload_services.dart';

class UserListBlockWidget extends StatefulWidget {
  final String email;
  final String auth_level;
  final int index;
  const UserListBlockWidget(
      {Key? key,
      required this.email,
      required this.auth_level,
      required this.index})
      : super(key: key);

  @override
  UserListBlockWidgetState createState() => UserListBlockWidgetState();
}

class UserListBlockWidgetState extends State<UserListBlockWidget> {
  String? finalAuthLevel;

  List<DropdownMenuItem<String>> authLevelList = [
    DropdownMenuItem(
      child: Text('User'),
      value: 'user',
    ),
    DropdownMenuItem(
      child: Text('Admin'),
      value: 'admin',
    ),
    DropdownMenuItem(
      child: Text('Super Admin'),
      value: 'super_admin',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: Color.fromARGB(57, 108, 126, 241),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.email.length > 23
                ? widget.email.substring(0, 20) + "..."
                : widget.email,
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          DropdownButton<String>(
            items: authLevelList,
            hint: Text(
                widget.auth_level.replaceFirst(
                    widget.auth_level[0], widget.auth_level[0].toUpperCase()),
                style: TextStyle(color: Colors.white)),
            onChanged: (String? value) {
              setState(() {
                finalAuthLevel = value!;
                if(widget.auth_level != finalAuthLevel){
                  PayloadServices().addToUpdatedAuthLevelList(
                    widget.email, finalAuthLevel!);
                }
                
              });
            },
            value: finalAuthLevel,
            style: TextStyle(color: Colors.white),
            dropdownColor: Colors.black,
          ),
        ],
      ),
    );
  }
}