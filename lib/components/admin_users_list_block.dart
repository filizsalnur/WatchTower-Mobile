// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';


class AdminUserListBlockWidget extends StatefulWidget {
  final String email;
  final String auth_level;
  final String id;
  const AdminUserListBlockWidget(
      {super.key,
      required this.email,
      required this.auth_level,
      required this.id});

  @override
  AdminUserListBlockWidgetState createState() =>
      AdminUserListBlockWidgetState();
}

class AdminUserListBlockWidgetState extends State<AdminUserListBlockWidget> {
  String? finalAuthLevel;

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
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                    style: TextStyle(fontSize: 20.0, color: Theme.of(context).colorScheme.background),
                  )
                : Text("Undefined", style: TextStyle(color: Colors.red)),
            (checkUserInformations(widget.email, widget.auth_level, widget.id))
                ? Text(
                      widget.auth_level.replaceFirst(widget.auth_level[0],
                          widget.auth_level[0].toUpperCase()),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontWeight: FontWeight.bold,
                      ),
                    )
              
                : Text(" ", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
