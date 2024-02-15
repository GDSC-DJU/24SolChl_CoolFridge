import 'package:flutter/material.dart';
import 'package:foodapp/FoodAddScreen.dart';
import 'package:foodapp/MainScreen.dart';

//카메라 페이지
void main() {}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Mode page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(57, 57, 57, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color foodc = Colors.white;
  Color billc = Colors.grey;
  FontWeight foodw = FontWeight.bold;
  FontWeight billw = FontWeight.normal;

  void fswitch() {
    setState(() {
      foodc = Colors.white;
      billc = Colors.grey;
      foodw = FontWeight.bold;
      billw = FontWeight.normal;
    });
  }

  void bswitch() {
    setState(() {
      foodc = Colors.grey;
      billc = Colors.white;
      foodw = FontWeight.normal;
      billw = FontWeight.bold;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.replace(
                  context,
                  oldRoute: ModalRoute.of(context)!,
                  newRoute: MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  ),
                );
              },
              color: Colors.white,
              icon: const Icon(Icons.arrow_back)),
          backgroundColor: const Color.fromARGB(255, 83, 83, 83),
        ),
        body: Container(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                // Expanded는 남는 공간 끝까지 확장하라는 명령어
                child: Container(
                  width: 600,
                  height: 150,
                  color: const Color.fromARGB(255, 83, 83, 83),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: TextButton(
                              onPressed: () => {fswitch()},
                              child: Text("음식사진",
                                  style: TextStyle(
                                      color: foodc, fontWeight: foodw)),
                            ),
                          ),
                          const SizedBox(width: 50),
                          Center(
                            child: TextButton(
                              onPressed: () => {bswitch()},
                              child: Text("영수증",
                                  style: TextStyle(
                                      color: billc, fontWeight: billw)),
                            ),
                          ),
                          const SizedBox(width: 50),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.replace(
                                  context,
                                  oldRoute: ModalRoute.of(context)!,
                                  newRoute: MaterialPageRoute(
                                    builder: (context) => const Postpage(),
                                  ),
                                );
                              },
                              child: const Text("직접입력",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              print("take a picture");
                              Navigator.replace(
                                context,
                                oldRoute: ModalRoute.of(context)!,
                                newRoute: MaterialPageRoute(
                                  builder: (context) => const Postpage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(30),
                            ),
                            child: const Text("")),
                      ),
                    ],
                  ),
                ),
              ),
            ])));
  }
}
