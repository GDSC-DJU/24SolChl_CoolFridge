import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:foodapp/main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/Pages/AlarmScreen.dart';
import 'package:foodapp/Pages/FoodAddScreen.dart';
import 'package:foodapp/Pages/gpt.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:foodapp/Pages/notification.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/Pages/Receipt.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // 추가

  //gpt api key load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  // pnameBox, productDateBox, productCountBox를 열기 전에 이미 열려 있는지 확인합니다.
  if (!Hive.isBoxOpen('pnameBox')) {
    await Hive.openBox<String>('pnameBox');
  }
  if (!Hive.isBoxOpen('productDateBox')) {
    await Hive.openBox<String>('productDateBox');
  }
  if (!Hive.isBoxOpen('productCountBox')) {
    await Hive.openBox<int>('productCountBox');
  }
  if (!Hive.isBoxOpen('tNameBox')) {
    await Hive.openBox<String>('tNameBox');
  }
  if (!Hive.isBoxOpen('tDateBox')) {
    await Hive.openBox<String>('tDateBox');
  }
  if (!Hive.isBoxOpen('tCountBox')) {
    await Hive.openBox<int>('tCountBox');
  }
  if (!Hive.isBoxOpen('SortingBox')) {
    await Hive.openBox<int>('SortingBox');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 1초 후에 다음 화면으로 이동
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(220, 230, 248, 1),
      body: Center(
        child: Image.asset('assets/images/cool_fridge.png'),
      ),
    );
  }
}
