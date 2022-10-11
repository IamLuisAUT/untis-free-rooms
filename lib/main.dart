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
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Untis Free-Rooms',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber).copyWith(secondary: Colors.amber),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber).copyWith(secondary: Colors.amber),
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
  bool preferencesInit = false;

  String selectedBuilding = "";

  String schoolname = '';
  String username = '';
  String password = '';
  String baseUrl = '';
  String defaultBuilding = '';
  DateTime date = DateTime.now();
  late WebUntis untis;

  final _schoolTextController = TextEditingController();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _baseUrlTextController = TextEditingController();
  final _defaultBuildingTextController = TextEditingController();
  final _buildingTextController = TextEditingController();

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
    try {
      List<dynamic> rooms = await getFreeRooms(untis, selectedBuilding, date);
      setState(() {
        freeRooms = rooms[0];
        blockedRooms = rooms[1];
        _load = false;
      });
    } on WebuntisException catch (e) {
      _showErrorDialog(context, e.code);
    }

  }

  void _saveLogin() async {
    schoolname = _schoolTextController.value.text;
    username = _usernameTextController.value.text;
    password = _passwordTextController.value.text;
    baseUrl = _baseUrlTextController.value.text;
    defaultBuilding = _defaultBuildingTextController.value.text;

    var preferences = await SharedPreferences.getInstance();

    await preferences.setString('schoolname', schoolname);
    await preferences.setString('username', username);
    await preferences.setString('password', password);
    await preferences.setString('baseurl', baseUrl);
    await preferences.setString('defaultBuilding', defaultBuilding);
  }

  void _retrieveLogin() async {
    var preferences = await SharedPreferences.getInstance();

    schoolname = preferences.getString('schoolname') ?? '';
    username = preferences.getString('username') ?? '';
    password = preferences.getString('password') ?? '';
    baseUrl = preferences.getString('baseurl') ?? '';
    defaultBuilding = preferences.getString('defaultBuilding') ?? '';

    _schoolTextController.text = schoolname;
    _usernameTextController.text = username;
    _passwordTextController.text = password;
    _baseUrlTextController.text = baseUrl;
    _defaultBuildingTextController.text = defaultBuilding;

    _buildingTextController.text = _defaultBuildingTextController.value.text;
    selectedBuilding = _defaultBuildingTextController.value.text;
    newUntisSession();
  }

  void newUntisSession() {
    if(schoolname == "" || username == "" || password == "" || baseUrl == "") {
      showDialog(context: context, builder: (BuildContext context) => _buildLoginDialog(context));
    }
    untis = WebUntis(schoolname, username, password, baseUrl);
      untis.login().then((value) async {
        bool authenticated = await untis.validateSession();
        if(!authenticated) {
          showDialog(context: context, builder: (BuildContext context) => _buildLoginDialog(context));
        }
      }).catchError((e) {
        if(e is WebuntisException) {
          _showErrorDialog(context, e.code);
        }
      });
  }

  bool _load = false;

  @override
  Widget build(BuildContext context) {
    double paddingTop = 0;
    if(Theme.of(context).platform == TargetPlatform.iOS) {
      paddingTop = 25;
    }
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 20 + paddingTop, 0, 10),
                        child: const Text(
                            "Untis Free-Rooms",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            )
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Building:"),
                        Container(
                            width: MediaQuery.of(context).size.width*0.2,
                            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: TextField(
                              controller: _buildingTextController,
                              onChanged: (value) {
                                setState(() {
                                  selectedBuilding = value;
                                });
                              }
                            )
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            var pickedDate = await pickDateAndTime();
                            if(pickedDate != null) date = pickedDate;
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

  _showErrorDialog(BuildContext context, int errorCode) {
    showDialog(context: context, builder: (context) => Center (
      child: AlertDialog(
    title: const Text('Error'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("${WebuntisException.errorCodes[errorCode]}"),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              _load = false;
            });
          },
        ),
      ],
    ),
    ));
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
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const Text("Default Building: "),
                                Expanded(
                                  child: TextField(controller: _defaultBuildingTextController),
                                )
                              ]
                          )
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
            future: untis.validateSession().catchError((e) {
              if(e is WebuntisException) {
                Navigator.of(context).pop();
                _showErrorDialog(context, e.code);
              }
            }),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return TextButton(
                    onPressed: () {
                      untis.logout();
                      Navigator.pop(context);
                    },
                    child: const Text('Logout'),
                  );
                }
              } else if (snapshot.hasError) {
                if(snapshot.error is WebuntisException) {
                  Navigator.of(context).pop();
                  return const SizedBox.shrink();
                }
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