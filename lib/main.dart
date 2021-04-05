import 'package:animated_splash/animated_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_to_text/views/homePage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Image to Text',
        theme: ThemeData.dark(),
        home: AnimatedSplash(
          imagePath: 'assets/logo.png',
          home: HomePage(),
          duration: 2500,
          type: AnimatedSplashType.StaticDuration,
        ));
  }
}
