import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:untis_free_rooms/utils.dart';

class WebUntis {
  String school = "";
  String username = "";
  String password = "";
  String baseUrl = "";
  static const String id = "Quando";
  String sessionId = "";

  WebUntis(this.school, this.username, this.password, this.baseUrl);

  Future<http.Response> login() async {
    try {
      final response = await http.post(
          Uri.parse("https://$baseUrl/WebUntis/jsonrpc.do?school=$school"),
          body: jsonEncode({
            "method": "authenticate",
            "id": id,
            "params": {
              "user": username,
              "password": password,
              "client": "CLIENT"
            },
            "jsonrpc": "2.0"
          }));
      if(response.statusCode != 200) throw http.ClientException(response.statusCode.toString());
      if(jsonDecode(response.body)['result'] == null || jsonDecode(response.body)['result']['sessionId'] == null) throw WebuntisException(5);
      sessionId = jsonDecode(response.body)["result"]["sessionId"];
      return response;
    } on SocketException {
      throw WebuntisException(1);
    } on FormatException {
      throw WebuntisException(2);
    } on WebuntisException {
      rethrow;
    }

  }

  dynamic _request(method, params) async {
    try {
      final response = await http.post(
          Uri.parse("https://$baseUrl/WebUntis/jsonrpc.do?school=$school"),
          body: jsonEncode({
            "method": method,
            "id": "Awesome",
            "params": params,
            "jsonrpc": "2.0"
          }),
          headers: <String, String>{"Cookie": "JSESSIONID=$sessionId"});
      if(jsonDecode(response.body)["error"] != null
          && jsonDecode(response.body)["error"]["code"] == -8520 /* not authenticated */) throw WebuntisException(4);
      if(jsonDecode(response.body)==null || jsonDecode(response.body)['result'] == null) throw WebuntisException(3);
      return jsonDecode(response.body)['result'];
    } on SocketException {
      throw WebuntisException(1);
    } on FormatException {
      throw WebuntisException(2);
    } on WebuntisException {
      rethrow;
    }
  }

  dynamic getRooms() async {
    try {
      return await _request('getRooms', {});
    } on WebuntisException {
      rethrow;
    }
  }

  dynamic getCurrentSchoolyear() async {
    try {
      return await _request('getCurrentSchoolyear', {});
    } on WebuntisException {
      rethrow;
    }
  }

  dynamic getTimetableFor(elementId, type, DateTime date) async {
    try {
      return await _request('getTimetable', <String, dynamic>{
        "id": "$elementId",
        "type": "$type", //4 = rooms
        "startDate": dateToUntisDate(DateTime(date.year, date.month, date.day)),
        "endDate": dateToUntisDate(DateTime(date.year, date.month, date.day))
      });
    } on WebuntisException {
      rethrow;
    }

  }

  Future<bool> validateSession() async {
    try {
      if (sessionId == "") return false;
      var response = await _request("getLatestImportTime", {});
      return response is int;
    } on WebuntisException catch(e) {
      if(e.code == 4) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      if (sessionId == "") throw WebuntisException(4);
      if(!await validateSession()) throw WebuntisException(4);
      await _request('logout', {});
      return true;
    } on WebuntisException {
      rethrow;
    }
  }

  static const types = {
    "class": 1,
    "teacher": 2,
    "subject": 3,
    "room": 4,
    "student": 5
  };


}

class WebuntisException {
  int code;
  WebuntisException(this.code);
  static const errorCodes = {
    1: "No internet connection",
    2: "Error on decoding json",
    3: "Body/result of response empty",
    4: "Invalid session",
    5: "Wrong credentials",
  };
}
