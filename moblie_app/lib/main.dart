import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'pages/InputPage/InputPage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

final logger = Logger(
  printer: PrettyPrinter(),
);

final loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      Logger.level = Level.nothing;
    } else {
      Logger.level = Level.debug;
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "modern-css",
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: MyHomePage(),
      theme: ThemeData(
          primarySwatch: Colors.purple,
          focusColor: Colors.purple,
          textTheme: GoogleFonts.sarabunTextTheme()),
    );
  }
}
