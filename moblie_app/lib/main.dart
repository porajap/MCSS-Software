import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modern-CSS v.1"),
      ),
      body: Center(
        child: ListView(children: getData(20)
            // Text("กดปุ่มเพื่อเพิ่มจำนวน"),
            // Image(
            //     image: NetworkImage(
            //         "https://i.natgeofe.com/n/46b07b5e-1264-42e1-ae4b-8a021226e2d0/domestic-cat_thumb_square.jpg")),
            ),
      ),
    );
  }

  List<Widget> getData(int count) {
    List<Widget> data = [];
    for (int i = 0; i < count; i++) {
      var num = ListTile(
          title: Text(
            "$i",
            style: TextStyle(fontSize: 25),
          ),
          subtitle: Text("${i + 1}"));
      data.add(num);
    }
    return data;
  }

  void addNumber() {
    setState(() {
      number++;
    });
  }
}
