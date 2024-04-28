import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(const MyApp());
}

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatecounter') {
    int counter = 0;
    await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0)
        .then((int? value) {
      counter = value ?? 0;
      counter++;
    });
    await HomeWidget.saveWidgetData<int>('_counter', counter);
    await HomeWidget.updateWidget(
        name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    HomeWidget.widgetClicked.listen((Uri? uri) => loadData());
    loadData();
  }

  void loadData() async {
    await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0)
        .then((int? value) {
      _counter = value ?? 0;
      setState(() {});
    });
  }

  Future<void> updateAppWidget() async {
    String imagePath = getImageForCounter();
    await HomeWidget.saveWidgetData<int>('_counter', _counter);
    await HomeWidget.saveWidgetData<String>('_imagePath', imagePath);
    await HomeWidget.updateWidget(
        name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      updateAppWidget(); // 위젯 업데이트 호출
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      updateAppWidget(); // 위젯 업데이트 호출
    });
  }

  String getImageForCounter() {
    if (_counter >= 0 && _counter <= 10) {
      return 'assets/images/cool_fridge.png'; // Image for range 0-10
    } else if (_counter > 10 && _counter <= 20) {
      return 'assets/images/sad.png'; // Image for range 11-20
    } else {
      return 'assets/images/cool_fridge.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: _decrementCounter,
              child: Image.asset(
                getImageForCounter(),
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.height * 0.1, // 이미지의 높이
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
