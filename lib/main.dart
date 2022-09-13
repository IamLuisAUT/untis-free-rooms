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
}