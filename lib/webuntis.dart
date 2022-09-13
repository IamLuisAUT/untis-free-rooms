import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class WebUntis {
  String school = "";
  String username = "";
  String password = "";
  String baseUrl = "";
  String id = "Awesome";
  String sessionId = "";

  WebUntis(this.school, this.username, this.password, this.baseUrl, this.id);

  Future<http.Response> login() async {
    final response = await http.post(
        Uri.parse("https://${baseUrl}/WebUntis/jsonrpc.do?school=$school"),
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
    sessionId = jsonDecode(response.body)['result']['sessionId'];
    return response;
  }

  dynamic _request(method, params) async {
    final response = await http.post(
        Uri.parse("https://$baseUrl/WebUntis/jsonrpc.do?school=$school"),
        body: jsonEncode({
          "method": method,
          "id": "Awesome",
          "params": params,
          "jsonrpc": "2.0"
        }),
        headers: <String, String>{"Cookie": "JSESSIONID=$sessionId"});
    return jsonDecode(response.body)['result'];
  }

  dynamic getRooms() async {
    return await _request('getRooms', {});
  }

  dynamic getTimetableFor(elementId, type) async {
    return await _request('getTimetable', <String, dynamic>{
      "id": "$elementId",
      "type": "$type", //4 = rooms

      // "startDate": "$startDate",
      // "endDate": "$endDate"
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
}
