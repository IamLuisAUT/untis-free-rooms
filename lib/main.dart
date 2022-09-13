import 'package:flutter/material.dart';

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
  String selectedBuilding = buildings.first;

  final _schoolTextController = TextEditingController();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _baseUrlTextController = TextEditingController();

  void _getFreeRooms() {
    setState(() {
      print(selectedBuilding);
    });
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
                  children: const <Widget>[
                    Text(
                      "C3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\n",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.green
                      )
                    ),
                    Text(
                        "C3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\nC3.08\nC3.09\nC5.10\n",
                        style: TextStyle(
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
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();

          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}