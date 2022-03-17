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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modern-CSS v.1"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            MoneyBox("expense", 100000.759, Colors.redAccent, 100),
            SizedBox(height: 10),
            MoneyBox("revenue", 10000, Colors.greenAccent, 100),
            SizedBox(height: 10),
            MoneyBox("balance", 1000000.485, Colors.yellow, 120),
          ],
        ),
      ),
    );
  }
}
