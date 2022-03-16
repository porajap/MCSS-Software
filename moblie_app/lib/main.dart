import 'package:flutter/material.dart';
import 'FoodMenu.dart';

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
  List<FoodMenu> menu = [
    FoodMenu("ice cream", "50", "assets/images/ice cream.jpg"),
    FoodMenu("water", "10", "assets/images/water.jpg")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Modern-CSS v.1"),
        ),
        body: ListView.builder(
            itemCount: menu.length,
            itemBuilder: (BuildContext context, int index) {
              FoodMenu foods = menu[index];
              return ListTile(
                leading: Image.asset(foods.img),
                title: Text(
                  foods.name,
                  style: TextStyle(fontSize: 25),
                ),
                subtitle: Text("price: " + foods.price),
                onTap: () {
                  print("Menu is " + foods.name);
                },
              );
            }),);
  }
}
