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
              home: Scaffold(
                backgroundColor: ColorCode.appBarColor,
                body: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/images/logo_splash_circle.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Modern-css by Kitiyaporn T.",
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],
            home: const MyHomePage(),
            theme: ThemeData(
              useMaterial3: false,
              primarySwatch: ColorCode.appBarColor,
              scaffoldBackgroundColor: Colors.white,
              textTheme: GoogleFonts.sarabunTextTheme(),
              appBarTheme: AppBarTheme(
                backgroundColor: ColorCode.appBarColor,
                elevation: 0,
                centerTitle: false,
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: GoogleFonts.sarabun(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorCode.appBarColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              dividerColor: ColorCode.divider,
            ),
          );
        });
  }
}

class Init {
  Init._();

  static final instance = Init._();

  Future initialize() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
