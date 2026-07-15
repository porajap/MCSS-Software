import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'pages/input_page/input_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/color_config.dart';

final logger = Logger(
  printer: PrettyPrinter(),
);

final loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      Logger.level = Level.off;
    } else {
      Logger.level = Level.debug;
    }
    return FutureBuilder(
        future: Init.instance.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              home: SafeArea(
                child: Scaffold(
                  body: Container(
                    color: ColorCode.appBarColor,
                  ),
                ),
              ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "modern-css by Kitiyaporn T.",
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],
            home: const MyHomePage(),
            theme: ThemeData(primarySwatch: ColorCode.appBarColor, textTheme: GoogleFonts.sarabunTextTheme()),
          );
        });
  }
}

class Init {
  Init._();

  static final instance = Init._();

  Future initialize() async {
    await Future.delayed(const Duration(seconds: 3));
  }
}
