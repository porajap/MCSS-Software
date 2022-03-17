import 'package:flutter/material.dart';
import 'MoneyBox.dart';

void main() {
  // print("Hello world");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "modern-css",
      home: MyHomePage(),
      theme: ThemeData(primarySwatch: Colors.purple),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int number = 0;

  @override
  void initState() {
    super.initState();
    print("use init State");
  }

  @override
  Widget build(BuildContext context) {
    print("use build State");
    return Scaffold(
      appBar: AppBar(
        title: Text("Modern-CSS v.1"),
      ),
      body: Column(
        children: [Text("Message $number")],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            number++;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
