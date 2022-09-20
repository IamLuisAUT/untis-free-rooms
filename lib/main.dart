import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart';
import 'webuntis.dart';

const List<String> buildings = <String>['A', 'B', 'C', 'D'];
const List<String> floors =  <String>['E', 'H', '1', '2', '3', '4', '5'];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Untis Free-Rooms',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Untis Free-Rooms'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final preferences;
  bool preferencesInit = false;

  String selectedBuilding = buildings.first;
  String selectedFloor = floors.first;

  String schoolname = '';
  String username = '';
  String password = '';
  String baseUrl = '';
  DateTime date = DateTime.now();
  late WebUntis untis;

  final _schoolTextController = TextEditingController();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _baseUrlTextController = TextEditingController();

  String freeRooms = '-';
  String blockedRooms = '-';

  _MyHomePageState() : super() {
    _retrieveLogin();
  }

  void _getFreeRooms() async {
    setState(() {
      _load = true;
      freeRooms = "";
      blockedRooms = "";
    });
    List<dynamic> rooms = await getFreeRooms(untis, selectedBuilding + selectedFloor, date);
    setState(() {
      freeRooms = rooms[0];
      blockedRooms = rooms[1];
      _load = false;
    });
  }

  void _saveLogin() async {
    schoolname = _schoolTextController.value.text;
    username = _usernameTextController.value.text;
    password = _passwordTextController.value.text;
    baseUrl = _baseUrlTextController.value.text;

    if(!preferencesInit) {
      preferences = await SharedPreferences.getInstance();
      preferencesInit = true;
    }

    await preferences.setString('schoolname', schoolname);
    await preferences.setString('username', username);
    await preferences.setString('password', password);
    await preferences.setString('baseurl', baseUrl);
  }

  void _retrieveLogin() async {
    if(!preferencesInit) {
      preferences = await SharedPreferences.getInstance();
      preferencesInit = true;
    }

    schoolname = preferences.getString('schoolname') ?? '';
    username = preferences.getString('username') ?? '';
    password = preferences.getString('password') ?? '';
    baseUrl = preferences.getString('baseurl') ?? '';

    _schoolTextController.text = schoolname;
    _usernameTextController.text = username;
    _passwordTextController.text = password;
    _baseUrlTextController.text = baseUrl;

    newUntisSession();
  }

  void newUntisSession() {
    if(
      schoolname.isNotEmpty && username.isNotEmpty &&
      password.isNotEmpty && baseUrl.isNotEmpty
      ) {
      untis = WebUntis(schoolname, username, password, baseUrl);
      untis.login().then((value) async {
        bool authenticated = await untis.validateSession();
        if(!authenticated) {showDialog(
            context: context, builder: (BuildContext context) => _buildLoginDialog(context));
        }
      });
    }
  }

  bool _load = false;

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load ? const SizedBox(
      width: 90.0,
      height: 90.0,
      child: Padding(padding: EdgeInsets.all(8.0),child: Center(child: CircularProgressIndicator())),
    ):Container();
    return LayoutBuilder(
      builder: (context, size) {
        return Scaffold(
          appBar: null,
          body: Stack(
            children: <Widget>[
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Icon(Icons.event_available),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10,0,0,0),
                            child: Text(
                              "Untis Free-Rooms",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              )
                            )
                          )
                        ]
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Building:"),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: DropdownButton<String>(
                              value: selectedBuilding,
                              elevation: 16,
                              style: const TextStyle(color: Colors.amber),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedBuilding = value!;
                                });
                              },
                              items: buildings.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: DropdownButton<String>(
                              value: selectedFloor,
                              elevation: 16,
                              style: const TextStyle(color: Colors.amber),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedFloor = value!;
                                });
                              },
                              items: floors.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            var pickedDate = await pickDateAndTime();
                            if(pickedDate!=null) date=pickedDate;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.key),
                          onPressed: () {
                            showDialog(context: context, builder: (BuildContext context) => _buildLoginDialog(context));
                          },
                        )
                      ],
                    ),
                    Expanded(
                        child: ListView(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                      freeRooms,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.green
                                      )
                                  ),
                                  Text(
                                      blockedRooms,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.red
                                      )
                                  )
                                ],
                              )
                            ]
                        )
                    )
                  ],
                ),
              ),
              Align(
                alignment: FractionalOffset.center,
                child: loadingIndicator
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _getFreeRooms,
            tooltip: 'Search',
            child: const Icon(Icons.access_time),
          ),
        );
      });
  }

  Widget _buildLoginDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Login Data'),
      content: SizedBox (
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column (
          children: <Widget>[
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const Text("Schoolname: "),
                                Expanded(
                                  child: TextField(controller: _schoolTextController),
                                )
                              ]
                          ),
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const Text("Username: "),
                                Expanded(
                                  child: TextField(controller: _usernameTextController),
                                )
                              ]
                          ),
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const Text("Password: "),
                                Expanded(
                                  child: TextField(controller: _passwordTextController),
                                )
                              ]
                          ),
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const Text("Base Url: "),
                                Expanded(
                                  child: TextField(controller: _baseUrlTextController),
                                )
                              ]
                          ),
                        ],
                      )
                    ]
                )
            )
          ],
        ),
      ),
      actions: <Widget>[
        FutureBuilder<bool>(
            future: untis.validateSession(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      untis.logout();
                    },
                    child: const Text('Logout'),
                  );
                }
              } else if (snapshot.hasError) {
                return const SizedBox.shrink();
              } else {
                return const CircularProgressIndicator();
              }
              return const SizedBox.shrink();
            }
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _saveLogin();
            newUntisSession();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<DateTime?> pickDateAndTime() async {
    DateTime? date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
    if(date == null) return null;
    TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute));
    if(time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }


}