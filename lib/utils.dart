import 'package:webuntis/webuntis.dart';

String building = 'C';
String roomType = "Stammklasse";
int timetableType = 4;

void main(List<String> arguments) async {
  var time = currentTime();
  WebUntis untis = WebUntis("XXX", "XXX", "XXX",
      "XXX", "XXX");
  untis.login().then((value) {
    untis.getRooms().then((rooms) {
      rooms.forEach((room) {
        print(room);
        if (room['building'].startsWith(building) &&
            room['longName'] == roomType) {
          print(room);
          untis.getTimetableFor(room['id'], timetableType).then((timetable) {
            if (timetable.length != 0) {
              bool isFree = true;
              List startingHours = [];
              timetable.forEach((hour) {
                if (hour["startTime"] < currentTime() &&
                    hour["endTime"] < currentTime() &&
                    hour["code"] != "cancelled") {
                  isFree = false;
                }
                if (currentTime() < hour["startTime"] &&
                    hour["code"] != "cancelled" &&
                    hour["ro"][0]["id"] == room["id"]) {
                  startingHours.add(hour["startTime"]);
                }
              });
            }
          });
        }
      });
    });
  });
}

int currentTime() {
  return int.parse(
      "${DateTime.now().hour}${DateTime.now().minute.toString().padLeft(2, '0')}");
}
