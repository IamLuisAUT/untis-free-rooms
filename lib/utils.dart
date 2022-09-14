import 'webuntis.dart';

String building = 'C3.09';
String roomType = "Stammklasse";
int timetableType = 4;

void getFreeRooms() async {
  var time = currentTime();
  WebUntis untis = WebUntis("XXX", "XXX", "XXX",
      "XXX", "XXX");
  untis.login().then((value) {
    untis.getRooms().then((rooms) {
      rooms.forEach((room) async {
        if (room['name'].startsWith(building) &&
            room['longName'] == roomType) {
          var timetable = await untis.getTimetableFor(room['id'], timetableType);

          if (timetable.length != 0) {
            bool isFree = true;
            List startingHours = [];

            timetable.forEach((hour) {
              if (hour["startTime"] < time &&
                  hour["endTime"] < time &&
                  hour["code"].toString() != "cancelled") {
                isFree = false;
                print('blocked');
              }
              if (time < hour["startTime"] &&
                  hour["code"] != "cancelled" &&
                  hour["ro"][0]["id"] == room["id"]) {
                startingHours.add(hour["startTime"]);
              }
            });
            if(isFree) {
              if(startingHours.isNotEmpty) {
                print('Is free until TBP');
              } else {
                print('Is free until end of the day');
              }
            } else {
              print('Is blocked');
            }
          } else {
            print('Is free');
          }
        }
      });
    });
  });
}

int currentTime() {
  // TODO: Fix timezone
  return int.parse(
      "${DateTime.now().hour}${DateTime.now().minute.toString().padLeft(2, '0')}") + 200;
}
