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
    if(jsonDecode(response.body)['result'] != null && jsonDecode(response.body)['result']['code'] == null && jsonDecode(response.body)['result']['sessionId'] != null) sessionId = jsonDecode(response.body)['result']['sessionId'];
    return response;
  }

  dynamic _request(method, params) async {
    final response = await http.post(
        Uri.parse("https://$baseUrl/WebUntis/jsonrpc.do?school=$school"),
        body: jsonEncode({
          "method": method,
          "id": id,
          "params": params,
          "jsonrpc": "2.0"
        }),
        headers: <String, String>{"Cookie": "JSESSIONID=$sessionId"});
    return jsonDecode(response.body)['result'];
  }

  dynamic getRooms() async {
    return await _request('getRooms', {});
  }

  dynamic getTimetableFor(elementId, type, DateTime date) async {
    return await _request('getTimetable', <String, dynamic>{
      "id": "$elementId",
      "type": "$type", //4 = rooms
      "startDate": dateToUntisDate(DateTime(date.year, date.month, date.day)),
      "endDate": dateToUntisDate(DateTime(date.year, date.month, date.day))
    });
  }

  Future<bool> validateSession() async {
    if (sessionId == "") return false;
    var response = await _request("getLatestImportTime", {});
    return response is int;
  }

  void getRoomsInBuilding(String building) async {
    var roomsInBuilding = [];
    var rooms = await getRooms();
    rooms
        .map((room) =>
            {if (room["building"] == building) roomsInBuilding.add(room)})
        .toList();
  }

  Future<bool> logout() async {
    if (sessionId == "") return false;
    if(!await validateSession()) return false;
    await _request('logout', {});
    return true;
  }

  static const types = {
    "class": 1,
    "teacher": 2,
    "subject": 3,
    "room": 4,
    "student": 5
  };
}
