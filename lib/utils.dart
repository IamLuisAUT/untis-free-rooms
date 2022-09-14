import 'webuntis.dart';
import 'dart:core';

Future<List> getFreeRooms(checkRooms) async {
  var time = currentTime();
  WebUntis untis = WebUntis("XXX", "XXX", "XXX",
      "XXX", "XXX");
  untis.login().then((value) {
    untis.getRooms().then((rooms) {
      rooms.forEach((room) async {
        if (room['name'].startsWith(checkRooms) &&
            room['longName'] == 'Stammklasse') {
          var timetable = await untis.getTimetableFor(room['id'], WebUntis.types['room']);

          if (timetable.length != 0) {
            bool isFree = true;
            List startingHours = [];

            timetable.forEach((hour) {
              if (hour["startTime"] < time &&
                  hour["endTime"] < time &&
                  hour["code"].toString() != "cancelled") {
                isFree = false;
              }
              if (time < hour["startTime"] &&
                  hour["code"].toString() != "cancelled" &&
                  hour["ro"][0]["id"] == room["id"]) {
                startingHours.add(hour["startTime"]);
              }
            });
            if(isFree) {
              if(startingHours.isNotEmpty) {
                freeRooms += room['name'] + ' until TBP\n';
              } else {
                freeRooms += room['name'] + '\n';
              }
            } else {
              blockedRooms += room['name'] + '\n';
            }
          } else {
            freeRooms += room['name'] + '\n';
          }
        }
      });
    });
  });

  return [freeRooms, blockedRooms];
}

int currentTime() {
  // TODO: Fix timezone
  return int.parse(
      "${DateTime.now().hour}${DateTime.now().minute.toString().padLeft(2, '0')}") + 200;
}
