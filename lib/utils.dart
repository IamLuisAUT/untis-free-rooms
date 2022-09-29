import 'webuntis.dart';
import 'dart:core';

Future<List> getFreeRooms(untis, checkRooms, DateTime date) async {
  int time = timeToUntisTime(date);
  String freeRooms = "\n";
  String blockedRooms = "\n";
    await untis.getRooms().then((rooms) async {
      for(int r = 0; r < rooms.length; r++) {
        var room = rooms[r];
        if (room['name'].startsWith(checkRooms) &&
            room['longName'] == 'Stammklasse') {
          var timetable = await untis.getTimetableFor(room['id'], WebUntis.types['room'], date);

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
                endTimeOfEmptyRoom = endTimeOfEmptyRoom.toString().length == 3 ? "0$endTimeOfEmptyRoom" : endTimeOfEmptyRoom;
                freeRooms += "${room['name']} until ${formatUntisTime(endTimeOfEmptyRoom)}\n";
              } else {
                freeRooms += "${room['name']}\n";
              }
            } else {
              blockedRooms += "${room['name']}\n";
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

String dateToUntisDate(DateTime date) {
  return (
      date.year.toString() + date.month.toString().padLeft(2, '0') + date.day.toString().padLeft(2, '0')
  );
}

String formatUntisTime(int untisTime) {
  return "${untisTime.toString().padLeft(4,"0").substring(0, 2)}:${untisTime.toString().padLeft(4,"0").substring(2, 4)}";
}

int timeToUntisTime(DateTime time) {
  return int.parse(
    time.hour.toString() + time.minute.toString().padLeft(2, '0')
  );
}