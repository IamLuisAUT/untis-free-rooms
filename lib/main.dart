import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart';

const List<String> buildings = <String>['A', 'B', 'C', 'D'];

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

  String schoolname = '';
  String username = '';
  String password = '';
  String baseUrl = '';

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
    print(await getFreeRooms('C2.10'));
    /* setState(() {
      freeRooms = rooms[0];
      blockedRooms = rooms[1];
    }); */
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

    schoolname = preferences.getString('schoolname');
    username = preferences.getString('username');
    password = preferences.getString('password');
    baseUrl = preferences.getString('baseurl');

    _schoolTextController.text = schoolname;
    _usernameTextController.text = username;
    _passwordTextController.text = password;
    _baseUrlTextController.text = baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: Text(
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
              IconButton(
                icon: const Icon(Icons.settings),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _getFreeRooms,
        tooltip: 'Search',
        child: const Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildLoginDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Login Data'),
      content: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: ListView(
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
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _saveLogin();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}