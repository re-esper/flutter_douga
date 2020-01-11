import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_douga/public.dart';
import 'package:auto_orientation/auto_orientation.dart';

import 'main_page.dart';


void main() async {
  await Storage.initialize();
  runApp(DougaApp());
  if (Platform.isAndroid) {
    // set the immersive status bar
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);    
  }
}

class DougaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AutoOrientation.portraitAutoMode();
    return MaterialApp(
      title: '嘀哩非公式',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        dividerColor: Color(0xFFEEEEEE),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          body1: TextStyle(color: AppColor.darkGrey)
        )
      ),
      home: MainPage(),
    );
  }
}