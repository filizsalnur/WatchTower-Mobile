// ignore_for_file: override_on_non_overriding_member

import 'dart:convert';

import '../services/login_Services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class LoginError {
  bool isLoginDone = false;
  String errorEmailMessage = '';
  String errorPasswordMessage = '';

  setisLoginDone(bool value) {
    isLoginDone = value;
  }

  setErrorEmailMessage(String value) {
    errorEmailMessage = value;
  }

  setErrorPasswordMessage(String value) {
    errorPasswordMessage = value;
  }
}

class Credentials {
  String email;
  String password;
  bool rememberMe;

  Credentials(this.email, this.password, this.rememberMe);
}

class LoginUtils {
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  String baseUrl = 'http://192.168.1.22:3001/';
  Future<void> setBaseUrl(String newBaseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', newBaseUrl);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<LoginError> getLoginError(ApiResponse httpResponce) async {
    final jsonData = jsonDecode(httpResponce.response);
    LoginError loginError = LoginError();

    if (httpResponce.statusCode >= 399) {
      if (jsonData.containsKey('errors')) {
        var errors = jsonData['errors'];
        loginError.setErrorEmailMessage(errors['email']);
        loginError.setErrorPasswordMessage(errors['password']);
      }
    } else {
      if (jsonData.containsKey('user')) {
        loginError.setisLoginDone(true);
        var authLevel = jsonData['auth_level'];
        var user = jsonData['user'];

        saveUserInfo(authLevel, user);
      }
    }

    return loginError;
  }

  Future<Credentials> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    String mailController = prefs.getString('email') ?? '';
    String passwordController = prefs.getString('password') ?? '';
    bool checkedValue = prefs.getBool('rememberMe') ?? false;

    return Credentials(mailController, passwordController, checkedValue);
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);

    var hash = sha256.convert(bytes);

    return hash.toString();
  }

  Future<void> saveCredentials(
      String mail, String password, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      prefs.setString('email', mail);
      prefs.setString('password', password);
      prefs.setBool('rememberMe', true);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.setBool('rememberMe', false);
      prefs.setString('id', "null");
    }
  }

  void printAllSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final allPrefs = prefs.getKeys();

    print('======= All SharedPreferences =======');
    for (var key in allPrefs) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    print('======= End of SharedPreferences =======');
  }

  Future<void> saveUserInfo(String authLevel, String user) async {
    final prefsUser = await SharedPreferences.getInstance();
    prefsUser.setString('authLevel', authLevel);
    prefsUser.setString('user', user);
  }

  Future<String> getAuthLevel() async {
    final prefsUser = await SharedPreferences.getInstance();
    String authLevel = prefsUser.getString('authLevel') ?? 'user';
    return authLevel;
  }

  Future<String> getUserId() async {
    final prefsUser = await SharedPreferences.getInstance();
    String user = prefsUser.getString('user') ?? 'user';
    return user;
  }

  //////////////////////////////////////////////////////////////////////////////////////
  Future<void> saveThemeMode(bool isLightModeSelected) async {
    SharedPreferences themeMode = await SharedPreferences.getInstance();
    themeMode.setBool('isLightModeSelected', isLightModeSelected);
  }

  Future<bool> getThemeMode() async {
    SharedPreferences themeMode = await SharedPreferences.getInstance();
    bool isLightModeSelected = themeMode.getBool('isLightModeSelected') ?? true;
    return isLightModeSelected;
  }

  Future<void> changeThemeMode() async {
    SharedPreferences themeMode = await SharedPreferences.getInstance();
    bool isLightModeSelected = themeMode.getBool('isLightModeSelected') ?? true;
    themeMode.setBool('isLightModeSelected', !isLightModeSelected);
  }
}








// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:watch_tower_flutter/utils/alarm_utils.dart';
// import '../utils/login_utils.dart';

// class ImageListScreen extends StatefulWidget {
//   @override
//   State<ImageListScreen> createState() => _ImageListScreenState();
// }

// class _ImageListScreenState extends State<ImageListScreen> {
//   List<List<int>> imageDataList = []; // List to store image data

//   String baseUrl = LoginUtils().baseUrl + 'picture/allPictures';

//   List<int> getImageData(Map<String, dynamic> imageData) {
//     if (imageData['type'] != 'Buffer') {
//       throw ArgumentError('Invalid image data format');
//     }

//     final List<dynamic> bufferData = imageData['data'];
//     return bufferData.map<int>((dynamic value) => value as int).toList();
//   }

//   String newBaseUrl = LoginUtils().baseUrl;

//   int imageNumbers = 0;

//   Future<void> getImageNumbers() async {
//     final response =
//         await http.get(Uri.parse(newBaseUrl + 'picture/numberOfPictures'));
//     if (response.statusCode <= 399) {
//       int counter = int.parse(response.body);
//       setState(() {
//         imageNumbers = counter;
//       });
//     }
//   }

//   Future<void> fetchImage(int i) async {
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'index': i}),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> imageDataListJson = jsonDecode(response.body);
//         if (imageDataListJson.isNotEmpty &&
//             imageDataListJson[0] is Map<String, dynamic>) {
//           final Map<String, dynamic> imageDataJson = imageDataListJson[0];
//           final List<int> imageDataBytes = getImageData(imageDataJson);
//           setState(() {
//             imageDataList.add(imageDataBytes);
//           });
//         } else {
//           print('Invalid image data format');
//         }
//       } else {
//         print('Failed to fetch image: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to fetch image: $e');
//     }
//   }

//   @override
//   void initState() {
    
//     super.initState();
//     getImageNumbers().then((_) {
//       for (int index = 0; index < imageNumbers; index++) {
//         fetchImage(index);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image List'),
//       ),
//       body: ListView.builder(
//         itemCount: imageDataList.length,
//         // itemCount: imageNumbers,
//         itemBuilder: (BuildContext context, int index) {
//           // if (imageDataList.length <= index) {
//           //   fetchImage(index);
//           // }
//           return imageDataList.length > index
//               ? Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Image.memory(
//                     Uint8List.fromList(imageDataList[index]),
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                 )
//               : Center(
//                   child: CircularProgressIndicator(),
//                 );
//         },
//       ),
//     );
//   }
// }
