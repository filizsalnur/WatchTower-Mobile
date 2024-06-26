import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:watch_tower_flutter/pages/login.dart';
import 'package:watch_tower_flutter/services/device_services.dart';
import 'package:watch_tower_flutter/services/payload_services.dart';
import 'package:watch_tower_flutter/utils/alert_utils.dart';
import 'package:watch_tower_flutter/utils/login_utils.dart';
import 'login_Services.dart';
import './user_info.dart';
import 'db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class WritingResult {
  NfcData nfcData;
  bool status;
  WritingResult(this.nfcData, this.status);
}

class NfcData {
  String card_id;
  String name;
  Location loc;

  NfcData({required this.card_id, required this.name, required this.loc});

  factory NfcData.fromJson(Map<String, dynamic> json) {
    return NfcData(
      card_id: json['ID'] as String,
      name: json['name'] as String,
      loc: Location.fromJson(json['loc']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': card_id,
      'name': name,
      'loc': loc.toJson(),
    };
  }
}

class Location {
  String lat;
  String long;

  Location({required this.lat, required this.long});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      long: json['long'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'long': long,
    };
  }
}

class NfcService {
  String BaseUrl = LoginUtils().baseUrl;

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> printAllSharedPreferences() async {
    print('================SHARED PREFERENCES================');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allData =
        prefs.getKeys().fold({}, (previousValue, key) {
      previousValue[key] = prefs.get(key);
      return previousValue;
    });

    print("SharedPreferences Data:");
    allData.forEach((key, value) {
      print("$key: $value");
    });
  }

  Future<ApiResponse> getOrderArray() async {
  
      try {
          if (await HttpServices().verifyToken()) {
        print(
            '====================================Order which the system expects==================================== ');
        final response = await http.get(
          Uri.parse(BaseUrl + 'tagOrder/get'),
        );

        final statusCode = response.statusCode;
        final responseBody = response.body;

        print('Response Status Code: $statusCode');
        print('Response Body: $responseBody');

        return ApiResponse(statusCode, responseBody);
         } else {
      print('JWT is not valid');
      return ApiResponse(-1, "Error: JWT is not valid");
    }
      } catch (e) {
        print("Error in fetching ORDER : $e");
        return ApiResponse(-1, "Error: $e");
      }
   
  }

  static ValueNotifier<dynamic> result = ValueNotifier(null);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<int> tagRead(BuildContext context, String sessionId) async {
    if (await HttpServices().verifyToken()) {
      Completer<int> completer = Completer<int>();

      try {
        NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          try {
            result.value = tag.data;

            List<int> intList = PayloadServices().convertStringToArray(
                PayloadServices().getPayload(result.toString()));
            String payload_as_String =
                PayloadServices().decodedResultPayload((intList));

            result.value = payload_as_String;

            payload_as_String = await UserInfoService()
                .updateUserInfo(payload_as_String, sessionId);
            payload_as_String = await NfcService().updateLocation(payload_as_String, sessionId);

            if (payload_as_String.length > 2) {
              int statusCode =
                  await DbServices().saveToDatabase(context, payload_as_String);
              NfcManager.instance.stopSession();
              completer.complete(statusCode);
            }
          } catch (e) {
            NfcManager.instance.stopSession();
            completer.complete(-1);
          }
        });

        return completer.future;
      } catch (e) {
        AlertUtils().errorAlert(
            'Unexpected error occurred, please check your connection', context);
        Navigator.pop(context);
        print('error in tagread: $e');
        return -1;
      }
    } else {
      await AlertUtils()
          .errorAlert('Session Timeout. Please login again', context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      print('JWT is not valid');
      return -1;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void resetNfcTag() async {
    if (await HttpServices().verifyToken()) {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          result.value = 'Tag is not ndef writable';
          NfcManager.instance.stopSession(errorMessage: result.value);
          return;
        }

        // Create an NDEF record with the text "TEST"
        String testText = 'D';
        Uint8List payload = Uint8List.fromList(testText.codeUnits);
        NdefRecord testRecord = NdefRecord.createMime('text/plain', payload);

        NdefMessage testMessage = NdefMessage([testRecord]);

        try {
          await ndef.write(testMessage);
          result.value = 'NFC tag resetted successfully';
          print(" NFC tag resetted successfully");
          NfcManager.instance.stopSession();
        } catch (e) {
          NfcManager.instance
              .stopSession(errorMessage: result.value.toString());
        }
      });
    } else {
      print('JWT is not valid');
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  int counter = 0;

  Future<WritingResult> writeService(NfcData newNfcTag) async {
    Future<WritingResult> writeNfcData(NfcData tagData) async {
      try {
        String json = jsonEncode(tagData.toJson());
        bool success = false;
        await NfcManager.instance.stopSession();

        await NfcManager.instance.startSession(
            onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);

          if (ndef == null || !ndef.isWritable) {
            await NfcManager.instance
                .stopSession(errorMessage: 'Tag is not ndef writable');
            return;
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createText(json),
          ]);

          try {
            await ndef.write(message);
            print('Success to ndef write');
            success = true;
            await NfcManager.instance.stopSession();
          } on PlatformException catch (e) {
            await NfcManager.instance.stopSession();

            print('Platform Exception: $e');
          } catch (e) {
            await NfcManager.instance.stopSession();

            print('Exception: $e');
          }
        });
        counter++;
        await Future.delayed(Duration(milliseconds: 500));

        if (success == true || counter == 20) {
          print('Success achieved!');
          await NfcManager.instance.stopSession();
          if (counter >= 20) {
            return WritingResult(tagData, false);
          }

          return WritingResult(tagData, true);
        } else {
          print('Retrying...');
          await NfcManager.instance.stopSession();
          return writeNfcData(tagData);
        }
      } catch (e) {
        print('Error: $e');
        await NfcManager.instance.stopSession();
        return writeNfcData(tagData);
      }
    }

    return writeNfcData(newNfcTag);
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<WritingResult> writeServiceForIOS(NfcData newNfcTag) async {
    if (await HttpServices().verifyToken()) {
      try {
    
        bool tagFound = false;
        String json = jsonEncode(newNfcTag.toJson());
        await NfcManager.instance.startSession(
            onDiscovered: (NfcTag tag) async {
          tagFound = true;
          var ndef = Ndef.from(tag);

          if (ndef == null || !ndef.isWritable) {
            result.value = 'Tag is not ndef writable';
            NfcManager.instance.stopSession(errorMessage: result.value);
            return;
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createText(json),
          ]);

          try {
            await ndef.write(message);
            result.value = 'Success to "Ndef Write"';
            
            print('Success to ndef write');
          } on PlatformException catch (e) {
            result.value = 'PlatformException: $e';
          } catch (e) {
            result.value = 'An error occurred: $e';
          } finally {
            NfcManager.instance.stopSession();
          }
        });

        if (!tagFound) {
          result.value = 'No NFC tag found. Please scan an NFC tag.';
        }
        print('result.value: ${result.value}');
        print('nfcData: ${newNfcTag.toJson()}');
        return WritingResult(newNfcTag,true);
      } catch (e) {
        result.value = 'An error occurred while starting the NFC session: $e';
       return WritingResult(NfcData(card_id: "", name: "", loc: Location(lat: "", long: "")),false);
      }
    } else {
      print('JWT is not valid');
      return WritingResult(NfcData(card_id: "", name: "", loc: Location(lat: "", long: "")),false);
    }
  }




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<NfcData> createNfcData(String name) async {
    var uuid = Uuid();
    String uniqueId = uuid.v4();
    List<String> location = await DeviceService().getLocation();
    print('======================LOCATION======================');
    print(location);
    if (location[0] == 'err') {
      AlertUtils()
          .getCustomToast("Please enable your location services.", Colors.red);
      throw Exception('Error getting location');
    } else {
      Location loc = Location(lat: location[0], long: location[1]);
      print('======================LOCATION======================');
      print(location[0]);
      print(location[1]);
      NfcData nfcData = NfcData(card_id: uniqueId, name: name, loc: loc);
      print('======================NFC DATA======================');
      print(nfcData.toJson());
      return nfcData;
    }
  }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   Future<String>  updateLocation(String jsonString,String sessionId) async {
    try {
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      print("##################################################");
      List<String> location = await DeviceService().getLocation();
    print('======================LOCATION======================');
    print(location);
    if (location[0] == 'err') {
      AlertUtils()
          .getCustomToast("Please enable your location services.", Colors.red);
      throw Exception('Error getting location');
    } else {
       Location loc = Location(lat: location[0], long: location[1]);
      print('======================LOCATION======================');
      print(location[0]);
      print(location[1]);
  
      jsonData['loc'] = loc.toJson();
          print('after adding location:');
      print(jsonData);

      String updatedJsonString = jsonEncode(jsonData);

      return updatedJsonString;
    }
   
  
    } catch (e) {
      print(e);
      return 'error';
    }
    
  }
}
