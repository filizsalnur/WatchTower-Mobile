// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:watch_tower_flutter/services/nfc_Services.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';

import '../pages/home.dart';
import '../pages/nfcHome.dart';
import 'login_Services.dart';

bool areListsEqual(List<dynamic> list1, List<dynamic> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  for (int i = 0; i < list1.length; i++) {
    Map<String, dynamic> item1 = list1[i];
    Map<String, dynamic> item2 = list2[i];

    if (item1['loc']['lat'] != item2['loc']['lat'] ||
        item1['loc']['long'] != item2['loc']['long'] ||
        item1['name'] != item2['name'] ||
        item1['isRead'] != item2['isRead'] ||
        item1['index'] != item2['index'] ||
        item1['card_id'] != item2['card_id']) {
      return false;
    }
  }

  return true;
}

class SessionService {
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<ApiResponse> checkSessionStatus() async {
    if (await HttpServices().verifyToken()) {
      String userId = await LoginUtils().getUserId();

      final url = LoginUtils().baseUrl + 'session/check';

      print('======================Check Session======================');
      try {
        final response = await http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, String>{'id': userId}));

        if (response.statusCode >= 399) {
          print('ERROR: ${response.body}');
          return ApiResponse(response.statusCode, response.body);
        } else {
          print('OK: ${response.body}');
          return ApiResponse(response.statusCode, response.body);
        }
      } catch (e) {
        print("Error in db_services: $e");
        return ApiResponse(500, "Error: $e");
      }
    } else {
      print('JWT is not valid');
      return ApiResponse(-1, "Error: JWT is not valid");
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<int> endActiveSessionStatus() async {
    if (await HttpServices().verifyToken()) {
      String userId = await LoginUtils().getUserId();

      final url = LoginUtils().baseUrl + 'session/end';

      print('======================Check Session======================');
      try {
        final response = await http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, String>{'id': userId}));

        if (response.statusCode >= 399) {
          print('ERROR: ${response.body}');
          return response.statusCode;
        } else {
          print('OK: ${response.body}');
          return response.statusCode;
        }
      } catch (e) {
        print("Error in db_services: $e");
        return 500;
      }
    } else {
      print('JWT is not valid');
      return -1;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<ApiResponse> createNewSession() async {
    if (await HttpServices().verifyToken()) {
      String userId = await LoginUtils().getUserId();

      final url = LoginUtils().baseUrl + 'session/create';

      print('======================Check Session======================');
      try {
        var orderArray = await NfcService().getOrderArray();
        List<dynamic> jsonResponse = jsonDecode(orderArray.response);
        final response = await http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, dynamic>{
              'userId': userId,
              "isActive": true,
              'tagOrderIsread': jsonResponse
            }));

        if (response.statusCode >= 399) {
          print('ERROR: ${response.body}');
          return ApiResponse(response.statusCode, response.body);
        } else {
          print('OK: ${response.body}');
          return ApiResponse(response.statusCode, response.body);
        }
      } catch (e) {
        print("Error in db_services: $e");
        return ApiResponse(500, "Error: $e");
      }
    } else {
      print('JWT is not valid');
      return ApiResponse(-1, "Error: JWT is not valid");
    }
  }

///////////////////////////////////////////////////////////////////////////////////////
  void startNewSessionAndEndTheLatest(BuildContext context) async {
    print("////////////////////////////////////////////////////////////////");
    int endSessionResult = await SessionService().endActiveSessionStatus();
    print("Alert utils end session result: $endSessionResult");
    if (endSessionResult < 400) {
      print('Session ended successfully');

      var startSessionResult = await SessionService().createNewSession();
      if (startSessionResult.statusCode < 400) {
        print('New session started');
        await AlertUtils().successfulAlert('New Session Initialized!', context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NfcHomePage(isOldSessionOn: false)),
        );
      } else {
        print('Error starting a new session');
        await AlertUtils()
            .errorAlert('System was not able to launch a new session', context);
        Navigator.pop(context);
      }
    } else {
      print('Error ending the active session');
      await AlertUtils()
          .errorAlert('Unable to end the current session', context);
      Navigator.pop(context);
    }
  }

  Future<void> startNewSession(BuildContext context) async {
    var startSessionResult = await SessionService().createNewSession();
    if (startSessionResult.statusCode < 400) {
      print('New session started');
      await AlertUtils().successfulAlert('New Session Initialized!', context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => NfcHomePage(isOldSessionOn: false)),
      );
    } else {
      print('Error starting a new session');
      await AlertUtils()
          .errorAlert('System was not able to launch a new session', context);
      Navigator.pop(context);
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> endSessionButton(BuildContext context) async {
    int result = await SessionService().endActiveSessionStatus();
    print("nfc Home 2");
    if (result < 400) {
      print('read order resetted');
      AlertUtils().getCustomToast("Session successfuly saved!", Colors.green);
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      print('session stopped');
    } else {
      print('error while resetting read order');
      AlertUtils().errorAlert("Unable to end current session", context);
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<int> updateSessionOrder(String sessionId) async {
    if (await HttpServices().verifyToken()) {
      final url =
          LoginUtils().baseUrl + 'session/updateExistingSessionCardOrder';

      print('======================UPDATE SESSION======================');
      try {
        var orderArray = await NfcService().getOrderArray();
        List<dynamic> jsonResponse = jsonDecode(orderArray.response);
        final response = await http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, dynamic>{
              'session_id': sessionId,
              'newTagOrderIsread': jsonResponse
            }));

        if (response.statusCode >= 399) {
          print('ERROR: ${response.body}');
          return response.statusCode;
        } else {
          print('OK: ${response.body}');
          return response.statusCode;
        }
      } catch (e) {
        print("Error in db_services: $e");
        return 500;
      }
    } else {
      print('JWT is not valid');
      return -1;
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////
  Future<void> checkTourOrder(String sessionId, BuildContext context) async {
    print("=================== CHECK TOUR ORDER ========================");
    print("Session ID: $sessionId");
    ApiResponse jsonResponse = await SessionService().checkSessionStatus();

    if (jsonResponse.statusCode < 400) {
      Map<String, dynamic> orderArray = json.decode(jsonResponse.response);
      List<dynamic> sessionAllowedOrder = orderArray['data'];
      print("_-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-_");
      print("Allowed Order Maps: $sessionAllowedOrder");

      var realTimeOrderArray = await NfcService().getOrderArray();
      List<dynamic> orderArrayJson = jsonDecode(realTimeOrderArray.response);
      print("_-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-__-_-_-_");
      print("Real Time Order Maps: $orderArrayJson");

      if (areListsEqual(sessionAllowedOrder, orderArrayJson)) {
        await AlertUtils().successfulAlert("Tour Completed", context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NfcHomePage(
                    isOldSessionOn: true,
                  )),
        );
      } else {
        print('Tag order is not up to date');
        await Duration(seconds: 2);
        bool isConfirmed = await AlertUtils()
            .confirmSessionAlert("New Tag Order Detected    Update?", context);
        if (isConfirmed) {
          int updateSessionOrderResponce = await updateSessionOrder(sessionId);
          if (updateSessionOrderResponce < 400) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NfcHomePage(
                        isOldSessionOn: true,
                      )),
            );
          } else {
            await AlertUtils().errorAlert("Unable to update session", context);
          }
        } else {
          await AlertUtils().successfulAlert("Tour Completed", context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => NfcHomePage(
                      isOldSessionOn: true,
                    )),
          );
        }
      }
    }
  }
}
