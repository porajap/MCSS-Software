import 'package:flutter/material.dart';
// import 'MoneyBox.dart';
import 'package:http/http.dart' as http;
import 'package:moblie_app/MoneyBox.dart';
import 'ExchangeRate.dart';

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
  void initState() {
    super.initState();
    // print("use init State");
    exchageRate();
  }

  Future<ExchangeRate> exchageRate() async {
    var url = Uri.parse("https://api.exchangerate-api.com/v4/latest/EUR");
    var response = await http.get(url);
    ExchangeRate _dataAPI = exchangeRateFromJson(response.body);
    return _dataAPI;
  }

  @override
  Widget build(BuildContext context) {
    // print("use build State");
    return Scaffold(
        appBar: AppBar(
          title: Text("Modern-CSS v.1"),
        ),
        body: FutureBuilder(
            future: exchageRate(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var result = snapshot.data;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      MoneyBox("EUR", 1, Colors.green, 50),
                      SizedBox(
                        height: 10,
                      ),
                      MoneyBox("THB", result.rates["THB"], Colors.orange, 40),
                      SizedBox(height: 10),
                      MoneyBox("USD", result.rates["USD"], Colors.orange, 40),
                    ],
                  ),
                );
              }
              return LinearProgressIndicator();
            }));
  }
}
