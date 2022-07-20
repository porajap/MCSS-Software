import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'pages/AnalyzePage/SummaryPage.dart';
import 'pages/InputPage/InputPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'utils/ColorConfig.dart';

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
    return FutureBuilder(
        future: Init.instance.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              home: SafeArea(
                child: Scaffold(
                  body: Container(
                    color: Colors.white,
                    child: Center(
                      child: Image.asset(
                        'lib/assets/images/Modren.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "modern-css",
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],
            home: MyHomePage(),
            theme: ThemeData(
                primarySwatch: ColorCode.appBarColor,
                textTheme: GoogleFonts.sarabunTextTheme()),
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
