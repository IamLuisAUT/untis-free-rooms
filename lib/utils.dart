import 'webuntis.dart';
import 'dart:core';

Future<List> getFreeRooms(untis, checkRooms) async {
  var time = currentTime();
  print(time);
  String freeRooms = "\n";
  String blockedRooms = "\n";
    await untis.getRooms().then((rooms) async {
      for(int r = 0; r < rooms.length; r++) {
        var room = rooms[r];
        if (room['name'].startsWith(checkRooms) &&
            room['longName'] == 'Stammklasse') {
          var timetable = await untis.getTimetableFor(room['id'], WebUntis.types['room']);

          if (timetable.length != 0) {
            bool isFree = true;
            List startingHours = [];

            for(int t = 0; t < timetable.length; t++) {
              var hour = timetable[t];
              if (hour["startTime"] < time &&
                  time < hour["endTime"] &&
                  hour["code"].toString() != "cancelled") {
                isFree = false;
              }
              if (time < hour["startTime"] &&
                  hour["code"].toString() != "cancelled" &&
                  hour["ro"][0]["id"] == room["id"]) {
                startingHours.add(hour["startTime"]);
              }
            }
            if(isFree) {
              if(startingHours.isNotEmpty) {
                var endTimeOfEmptyRoom = startingHours.reduce((previous, current)
                {
                    return ((current - time).abs() < (previous - time).abs() ? current : previous);
                });
                freeRooms += "${room['name']} until ${endTimeOfEmptyRoom.toString().replaceAll(endTimeOfEmptyRoom.toString().substring(1,2), "${endTimeOfEmptyRoom.toString().substring(1,2)}:")}\n";
              } else {
                freeRooms += "${room['name']}\n";
              }
            } else {
              blockedRooms += "${room['name']}\n";;
            }
          } else {
            freeRooms += "${room['name']}\n";
          }
        }
      }
    });

  return [freeRooms, blockedRooms];
}

int currentTime() {
  return int.parse(
      "${DateTime.now().hour}${DateTime.now().minute.toString().padLeft(2, '0')}");
}