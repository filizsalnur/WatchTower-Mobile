// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import '../services/payload_services.dart';


class UserListBlockWidget extends StatefulWidget {
  final String email;
  final String auth_level;
  final String id;

  const UserListBlockWidget({
    super.key,
    required this.email,
    required this.auth_level,
    required this.id,
  });

  @override
  UserListBlockWidgetState createState() => UserListBlockWidgetState();
}

class UserListBlockWidgetState extends State<UserListBlockWidget> {
  String? finalAuthLevel;
  Color buttonColor = Colors.grey.shade900; 

  List<DropdownMenuItem<String>> authLevelList = [
    DropdownMenuItem(
      value: 'user',
      child: Text('User'),
    ),
    DropdownMenuItem(
      value: 'admin',
      child: Text('Admin'),
    ),
    DropdownMenuItem(
      value: 'super_admin',
      child: Text('Super Admin'),
    ),
  ];

  @override
  checkUserInformations(String email, String authLevel, String id) {
    if (email == '' || authLevel == '' || id == '') {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(20.0),
          backgroundColor: buttonColor, // Set the color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (checkUserInformations(widget.email, widget.auth_level, widget.id))
                ? Text(
                    widget.email.length > 23
                        ? "${widget.email.substring(0, 20)}..."
                        : widget.email,
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  )
                : Text("Undefined", style: TextStyle(color: Colors.red)),
            (checkUserInformations(widget.email, widget.auth_level, widget.id))
                ? DropdownButton<String>(
                    items: authLevelList,
                    hint: Text(
                      widget.auth_level.replaceFirst(
                        widget.auth_level[0],
                        widget.auth_level[0].toUpperCase(),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        finalAuthLevel = value!;
                        buttonColor = Theme.of(context).primaryColor; 
                        if (widget.auth_level != finalAuthLevel) {
                          PayloadServices().addToUpdatedAuthLevelList(
                            widget.id,
                            finalAuthLevel!,
                          );
                        }
                      });
                    },
                    value: finalAuthLevel,
                    style: TextStyle(color: Colors.white),
                    dropdownColor: Colors.black,
                  )
                : Text(" "),
          ],
        ),
      ),
    );
  }
}
