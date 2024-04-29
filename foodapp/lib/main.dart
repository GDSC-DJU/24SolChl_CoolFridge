import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:foodapp/Pages/AlarmScreen.dart';
import 'package:foodapp/Pages/FoodAddScreen.dart';
import 'package:foodapp/Pages/gpt.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:foodapp/Pages/notification.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/Pages/receipt_ocr.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'package:home_widget/home_widget.dart';

//MainScreen 코드
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

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
  if (!Hive.isBoxOpen('productCountBox2')) {
    await Hive.openBox<int>('productCountBox2');
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
  if (!Hive.isBoxOpen('EatFoodBox')) {
    //먹은 음식에 대한 내부 저장소 hive 박스 열기
    await Hive.openBox<String>('EatFoodBox');
  }
  if (!Hive.isBoxOpen('WasteFood')) {
    await Hive.openBox<String>('WasteFood');
  }
  await Future.delayed(const Duration(seconds: 1));

  runApp(const MainScreen());

  FlutterNativeSplash.remove();
}

Future<dynamic> fetchChatGptData() async {
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child('chatgpt').get();
  if (snapshot.exists) {
    return snapshot.value;
  } else {
    print('No data available.');
    return null;
  }
}

Future<dynamic> fetchNaverOcrData() async {
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child('naver-clova').get();
  if (snapshot.exists) {
    return snapshot.value;
  } else {
    print('No data available.');
    return null;
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Basicfont'),
      debugShowCheckedModeBanner: false,
      home: const _MainScreen(),
    );
  }
}

class _MainScreen extends StatefulWidget {
  const _MainScreen({super.key});

  @override
  State<_MainScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<_MainScreen> {
  late Box<String> pnameBox;
  late Box<String> productDateBox;
  late Box<int> productCountBox;
  late Box<int> productCountBox2;
  late Map<int, bool> switchStates = {};
  late Box<String> EatFood;
  late Box<String> wasteFood;
  Map<int, int> map1 = {};

  //정렬순으로 하는 hive 변수 선언
  late Box<String> tNameBox;
  late Box<String> tDateBox;
  late Box<int> tCountBox;
  late Box<int> SortingBox;

  @override
  void initState() {
    super.initState();
    initHiveBoxes();
    updateHomeWidget();
    checkAndUpdateWasteFood();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      foodAchiveMent(); // Execute this only after the build is complete
    });
    // 유통기한이 지난 음식의 수량 확인

    SortingBox.put(0, 1);

    for (int i = 0; i < pnameBox.length; i++) {
      pnameBox.putAt(i, tNameBox.getAt(i)!);
      productCountBox.putAt(i, tCountBox.getAt(i)!);
      productDateBox.putAt(i, tDateBox.getAt(i)!);
    }

    //알람기능 init
    FlutterLocalNotification.init();

    // 3초 후 권한 요청
    Future.delayed(const Duration(seconds: 3),
        FlutterLocalNotification.requestNotificationPermission());
    super.initState();

    //현재시간 지정
    DateTime NOWTIME = DateTime.now();

    // 7일 이하의 유통기한을 가진 제품은 몇개인지 설정 & 알람기능
    void notificationcount() {
      int notificationCount = 0;
      for (int i = 0; i < productDateBox.length; i++) {
        DateTime PDate = DateTime.parse(productDateBox.getAt(i)!);
        Duration Daygap = PDate.difference(NOWTIME);
        int Differ = Daygap.inDays + 1;
        if (Differ <= 7 && Differ >= 0) {
          notificationCount++;
        }
      }
      if (notificationCount != 0) {
        FlutterLocalNotification.showNotification(notificationCount);
      }
    }

    // seconds: 30은 하루 주기로 바꾸면 됨.
    Timer.periodic(
      const Duration(
        hours: 24,
      ),
      (Timer t) => notificationcount(),
    );
  }

  void initHiveBoxes() {
    pnameBox = Hive.box<String>('pnameBox');
    productDateBox = Hive.box<String>('productDateBox');
    productCountBox = Hive.box<int>('productCountBox');
    EatFood = Hive.box<String>('EatFoodBox');
    wasteFood = Hive.box<String>('WasteFood');
    tNameBox = Hive.box<String>('tNameBox');
    tDateBox = Hive.box<String>('tDateBox');
    tCountBox = Hive.box<int>('tCountBox');
    SortingBox = Hive.box<int>('SortingBox');
  }

  void saveDataForHomeWidget(String imagePath, String achievementText) async {
    await HomeWidget.saveWidgetData<String>('imagePath', imagePath);
    await HomeWidget.saveWidgetData<String>('achievementText', achievementText);
    updateHomeWidget(); // 위젯 업데이트 요청
  }

  void updateHomeWidget() {
    HomeWidget.updateWidget(
      name: 'AppWidgetProvider',
      androidName: 'AppWidgetProvider',
    );
  }

  Future<void> setAndSaveWidgetData() async {
    int newLength = wasteFood.length;
    int itemcount = EatFood.length;
    int integerValue = 0;
    String imagePath;
    String achievementText;

    // 아이템 총합이 0인지 확인하고 0이면 기본값 설정
    if (itemcount + newLength == 0) {
      // 데이터가 없을 때의 이미지
      imagePath = 'assets/images/cool_fridge.png';
      achievementText = '';
    } else {
      double result = itemcount / (itemcount + newLength) * 100;
      integerValue = result.toInt();

      if (integerValue <= 33) {
        imagePath = 'assets/images/sad.png';
        achievementText = '$integerValue% 아쉬워요!';
      } else if (integerValue > 33 && integerValue <= 66) {
        imagePath = 'assets/images/soso.png';
        achievementText = '$integerValue% 괜찮아요!';
      } else {
        imagePath = 'assets/images/cool_fridge.png';
        achievementText = '$integerValue% 훌륭해요!';
      }
    }

    // 현재 위젯 데이터 로드
    await HomeWidget.getWidgetData<String>('imagePath');
    await HomeWidget.getWidgetData<String>('achievementText');

    // 데이터 저장 및 위젯 업데이트 요청
    saveDataForHomeWidget(imagePath, achievementText);
  }

  void checkAndUpdateWasteFood() {
    DateTime today = DateTime.now().toUtc(); // UTC 시간 기준으로 가져와 시간대의 영향을 제거
    DateTime todayDateOnly =
        DateTime(today.year, today.month, today.day); // 날짜만 포함하는 새 DateTime 객체

    for (int i = 0; i < productDateBox.length; i++) {
      String expiryDateString = productDateBox.getAt(i) ?? '';
      DateTime expiryDate = DateTime.parse(expiryDateString);
      DateTime expiryDateOnly = DateTime(
          expiryDate.year, expiryDate.month, expiryDate.day); // 유통기한 날짜만 포함

      if (expiryDateOnly.isBefore(todayDateOnly)) {
        String productName = pnameBox.getAt(i) ?? '';
        if (!wasteFood.values.contains(productName)) {
          wasteFood.add(productName);
        }
      }
    }

    int newLength = wasteFood.length; // 추가 후 길이 저장
    if (newLength > 0) {
      // 새로운 유통기한 지난 항목이 있으면 출력
      print('유통기한 지난 음식: $newLength');
    }
    setAndSaveWidgetData();
  }

  void Management(BuildContext context, int index) async {
    String productName = pnameBox.getAt(index) ?? '';

    String prompt =
        "$productName의 재료 관리 방법을 2문장 이내로 알려줘 감자의 관리 방법을 예시로 들면 감자는 시원하고 건조한 장소에 보관해야 하며, 직사광선을 피하고 통풍이 잘 되도록 보관하는 것이 중요합니다. 이런식으로 답해주면 돼";
    String generatedText = "";

    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("재고 관리 방법"),
            content: FutureBuilder(
              future: GPT3.generateText(prompt),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF35AED4)),
                          strokeWidth: 4, // 원의 두께 설정
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("에러 발생: ${snapshot.error}"); // 에러 메시지 표시
                } else {
                  return Text(snapshot.data ?? ""); // 재고 관리 방법 표시
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  void Recipe(BuildContext context) async {
    String contentText = '';
    List<String> selectedProducts = [];
    Map<int, bool> switchStates = {}; // switchStates를 선언하여 예시에 추가

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.06,
                horizontal: MediaQuery.of(context).size.width * 0.12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '음식 선택',
                    style: TextStyle(
                      color: Color(0xFF42A5F5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // 높이 조절
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: List.generate(pnameBox.length, (index) {
                          String productName = pnameBox.getAt(index) ?? '';
                          bool isSelected = switchStates.containsKey(index)
                              ? switchStates[index]!
                              : false;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  (productName.length > 10)
                                      ? '${productName.substring(0, 10)}...'
                                      : productName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Switch(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    switchStates[index] = value;
                                  });
                                },
                                activeColor: Colors.blue,
                                inactiveThumbColor: Colors.grey,
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 20), // 여백 추가
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      selectedProducts.clear();
                      switchStates.forEach((index, isSelected) {
                        if (isSelected) {
                          String productName = pnameBox.getAt(index) ?? '';
                          selectedProducts.add(productName);
                        }
                      });

                      if (selectedProducts.isNotEmpty) {
                        // 선택된 상품들을 기반으로 AI 레시피 생성 요청
                        String prompt =
                            "${selectedProducts.join(', ')}으로 만들 수 있는 요리 추천해줘 레시피를 절대 알려주지 말고 음식만 3가지 추천해줘 그리고 음식과 음식 사이에는 \n처럼 한 줄 띄워서 출력해줘";
                        try {
                          String generatedText = "";
                          // 추천메뉴 생성중일 때, 로딩창
                          if (generatedText == "") {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF35AED4)),
                                ));
                              },
                            );
                          }
                          generatedText = await GPT3.generateText(prompt);
                          setState(() {
                            //로딩창 제거
                            if (generatedText != "") {
                              Navigator.of(context).pop();
                            }
                            // content 업데이트
                            contentText = generatedText;
                          });
                        } catch (e) {
                          print("Error: $e");
                        }
                      } else {
                        print("No products selected");
                        // 선택된 상품이 없는 경우 사용자에게 메시지 표시 또는 다른 작업 수행
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text(
                                "알림",
                                style: TextStyle(
                                  color: Color(0xFF42A5F5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text("1개 이상의 재료를 선택해주세요."),
                              actions: <Widget>[
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      const Color(0xFF42A5F5),
                                    ), // 테두리 색 및 너비 지정
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "확인",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      // contentText에 내용이 있을 때만 두 번째 AlertDialog를 표시하도록 수정
                      if (contentText.isNotEmpty) {
                        // 첫 번째 AlertDialog의 content를 두 번째 AlertDialog의 content로 대체
                        Navigator.of(context).pop(); // 첫 번째 AlertDialog 닫기
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                backgroundColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.06,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '음식을 골라보세요',
                                      style: TextStyle(
                                        color: Color(
                                          (0xFF42A5F5),
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children:
                                        contentText.split('\n').map((item) {
                                      return TextButton(
                                        onPressed: () async {
                                          String prompt =
                                              '$item 을 만들 수 있는 레시피 알려줘';
                                          try {
                                            String generatedText = "";
                                            // 추천메뉴 생성중일 때, 로딩창
                                            if (generatedText == "") {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Color(0xFF35AED4)),
                                                  ));
                                                },
                                              );
                                            }
                                            generatedText =
                                                await GPT3.generateText(prompt);
                                            Navigator.of(context)
                                                .pop(); // 로딩 다이얼로그 닫기
                                            Navigator.of(context)
                                                .pop(); // 현재 다이얼로그 닫기
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  // AlertDialog 내용 설정
                                                  content: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Text(
                                                            generatedText,
                                                            textAlign: TextAlign
                                                                .center, // 가운데 정렬을 원하는 경우
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          } catch (e) {
                                            print("Error: $e");
                                          }
                                        },
                                        child: Text(
                                          item.trim(), // contentText의 각 항목을 버튼의 텍스트로 사용
                                          style: const TextStyle(
                                            fontSize: 23,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ));
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42A5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '선택 완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void Modify(BuildContext context, int index) {
    TextEditingController productNameController = TextEditingController();
    TextEditingController productDateController = TextEditingController();
    TextEditingController productCountController = TextEditingController();

    productNameController.text = pnameBox.getAt(index) ?? '';
    productDateController.text = productDateBox.getAt(index) ?? '';
    productCountController.text =
        productCountBox.getAt(index)?.toString() ?? '';

    GlobalKey<FormState> formKey = GlobalKey<FormState>(); // _formKey 추가

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.06,
                horizontal: MediaQuery.of(context).size.width * 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '상품 상세정보',
                  style: TextStyle(
                    color: Color(
                      (0xFF42A5F5),
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Form(
              // Form 위젯으로 감싸기
              key: formKey, // _formKey 추가
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('상품명'),
                  TextFormField(
                    controller: productNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '상품명을 입력하세요.';
                      }
                      return null;
                    },
                  ),
                  const Text('유통기한'),
                  TextFormField(
                    controller: productDateController,
                    keyboardType: TextInputType.number, //숫자만 입력 가능
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '유통기한을 입력하세요.';
                      }

                      return null;
                    },
                  ),
                  const Text('수량'),
                  TextFormField(
                    controller: productCountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '수량을 입력하세요.';
                      }
                      int intvalue = int.parse(value);
                      if (intvalue > 99) {
                        return '수량은 최대 99개입니다.';
                      }
                      return null;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF42A5F5),
                          ), // 테두리 색 및 너비 지정
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color(0xFF42A5F5),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xFF42A5F5),
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState != null &&
                              formKey.currentState!.validate()) {
                            // 완료 버튼을 눌렀을 때 업데이트
                            String newProductName = productNameController.text;
                            String newProductDate = productDateController.text;
                            int newProductCount =
                                int.parse(productCountController.text);

                            pnameBox.putAt(index, newProductName);
                            productDateBox.putAt(index, newProductDate);
                            productCountBox.putAt(index, newProductCount);
                            tNameBox.putAt(index, newProductName);
                            tDateBox.putAt(index, newProductDate);
                            tCountBox.putAt(index, newProductCount);

                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          '완료',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<int> removedIndices = [];

  void removeFoodList(int index) {
    setState(() {
      pnameBox.deleteAt(index);
      productDateBox.deleteAt(index);
      productCountBox.deleteAt(index);
      productCountBox2.deleteAt(index);
    });
    // 삭제된 상품 다음 상품들의 인덱스를 조정하기 위해 removedIndices 리스트 업데이트
    removedIndices.add(index);
  }

  var SortingText = "등록순";

//FoodList
  Widget FoodList(BuildContext context, index, Function(int) removeCallback) {
    double pnamefontsize = 20;
    if (pnameBox.getAt(index)!.length >= 5) {
      pnamefontsize = 16;
      if (pnameBox.getAt(index)!.length >= 9) {
        pnamefontsize = 12;
        if (pnameBox.getAt(index)!.length >= 11) {
          pnamefontsize = 9;
        }
      }
    }
    void printEatFoodCount() async {}

    void incrementCounter(int index) {
      setState(() {
        int currentValue = productCountBox.getAt(index) ?? 0;
        if (currentValue == 99) {
          max99(context);
        } else {
          productCountBox.putAt(index, currentValue + 1);
          tCountBox.putAt(index, currentValue + 1);
          map1[index] = currentValue + 1;
        }
        print("$map1");
      });
    }

    Future<bool> RemoveDialog(BuildContext context, int index) async {
      bool checkremove = false;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.06,
                horizontal: MediaQuery.of(context).size.width * 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '정말로 삭제하시겠습니까?',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 231, 90, 79),
                  ),
                ),
              ],
            ),
            content: //이름, 유통기한, 수량이 뜨게 한다
                Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF42A5F5),
                    ), // 테두리 색 및 너비 지정
                  ),
                  onPressed: () {
                    checkremove = true;
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '유통기한이 지났어요',
                    style: TextStyle(
                      color: Color(0xFF42A5F5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFF42A5F5),
                    ),
                  ),
                  onPressed: () async {
                    var pname =
                        pnameBox.getAt(index); // 삭제하기 전에 데이터를 변수에 저장합니다.
                    await EatFood.add(pname!); // 데이터를 EatFood 박스에 저장합니다.
                    setAndSaveWidgetData(); // 위젯 업데이트 요청
                    int itemCount = EatFood.length; // 박스에 저장된 아이템의 수를 가져옵니다.

                    print('먹은거: $itemCount');
                    checkremove = true;

                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '다 먹었어요',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
      return checkremove;
    }

    void decrementCounter(int index) {
      setState(() {
        int currentValue = productCountBox.getAt(index) ?? 0;
        productCountBox.putAt(index, currentValue - 1);
        tCountBox.putAt(index, currentValue - 1);
      });
    }

    // 마지막 인덱스인지 확인하여
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (SortingBox.getAt(SortingBox.length - 1) == 0) {
              for (int i = 0; i < SortingBox.length - 2; i++) {
                SortingBox.deleteAt(i);
              }
              SortingBox.add(1);
              Modify(context, index);
              for (int i = 0; i < SortingBox.length - 2; i++) {
                SortingBox.deleteAt(i);
              }
              SortingBox.add(0);
            } else {
              Modify(context, index);
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.1,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width * 0.35, // 원하는 폭으로 설정하세요
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                '${(pnameBox.getAt(index) ?? '').length > 10 ? '${pnameBox.getAt(index)!.substring(0, 10)}...' : pnameBox.getAt(index)}',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              Management(context, index);
                            },
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.04),
                          ),
                          Text(
                            '${productDateBox.getAt(index)}',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        // 유통기한 순으로 정렬되어있다면, 등록순으로 바꾸고 decrementCounter하고 다시 유통기한순으로 바꾼다.
                        if (SortingBox.getAt(SortingBox.length - 1) == 0) {
                          for (int i = 0; i < SortingBox.length - 2; i++) {
                            SortingBox.deleteAt(i);
                          }
                          SortingBox.add(1);
                          if (productCountBox.getAt(index)! > 1) {
                            decrementCounter(index);
                          } else if (productCountBox.getAt(index)! == 1) {
                            if (await RemoveDialog(context, index)) {
                              setState(() {
                                pnameBox.deleteAt(index);
                                productDateBox.deleteAt(index);
                                productCountBox.deleteAt(index);
                                productCountBox2.deleteAt(index);
                                tNameBox.deleteAt(index);
                                tDateBox.deleteAt(index);
                                tCountBox.deleteAt(index);
                              });
                            }
                          }
                          for (int i = 0; i < SortingBox.length - 2; i++) {
                            SortingBox.deleteAt(i);
                          }
                          SortingBox.add(0);
                        } else {
                          if (productCountBox.getAt(index)! > 1) {
                            decrementCounter(index);
                          } else if (productCountBox.getAt(index)! == 1) {
                            if (await RemoveDialog(context, index)) {
                              setState(() {
                                pnameBox.deleteAt(index);
                                productDateBox.deleteAt(index);
                                productCountBox.deleteAt(index);
                                productCountBox2.deleteAt(index);
                                tNameBox.deleteAt(index);
                                tDateBox.deleteAt(index);
                                tCountBox.deleteAt(index);
                              });
                            }
                          }
                        }
                      },
                      icon: Icon(
                        Icons.remove,
                        size: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${productCountBox.getAt(index)}',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.07,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // 유통기한 순으로 정렬되어있다면, 등록순으로 바꾸고 incrementCounter하고 다시 유통기한순으로 바꾼다.
                        if (SortingBox.getAt(SortingBox.length - 1) == 0) {
                          for (int i = 0; i < SortingBox.length - 2; i++) {
                            SortingBox.deleteAt(i);
                          }
                          SortingBox.add(1);
                          incrementCounter(index);
                          for (int i = 0; i < SortingBox.length - 2; i++) {
                            SortingBox.deleteAt(i);
                          }
                          SortingBox.add(0);
                        } else {
                          incrementCounter(index);
                        }
                      },
                      icon: Icon(Icons.add,
                          size: MediaQuery.of(context).size.width * 0.04),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            // 대화상자를 통해 사용자에게 삭제를 확인받습니다.
                            if (await RemoveDialog(context, index)) {
                              // 데이터를 먼저 다른 박스에 저장합니다.

                              // 상태 업데이트를 동기적으로 처리합니다.
                              setState(() {
                                // 기존 박스에서 해당 데이터를 삭제합니다.
                                pnameBox.deleteAt(index);
                                productDateBox.deleteAt(index);
                                productCountBox.deleteAt(index);
                                tNameBox.deleteAt(index);
                                tDateBox.deleteAt(index);
                                tCountBox.deleteAt(index);
                              });

                              // 저장된 데이터의 개수를 콘솔에 출력합니다.
                              printEatFoodCount();
                            }
                          },
                          icon: const Icon(
                            Icons.highlight_remove_outlined,
                            color: Colors.red,
                            size: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget foodAchiveMent() {
    int newLength = wasteFood.length;
    int itemcount = EatFood.length;

    // 데이터가 있는 경우만 계산을 수행합니다.
    if (itemcount != 0 || newLength != 0) {
      double result = itemcount / (itemcount + newLength) * 100;
      int integerValue = result.toInt();

      if (integerValue <= 33) {
        return Column(
          children: [
            Image.asset(
              'assets/images/sad.png',
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              '$integerValue%',
            ),
          ],
        );
      } else if (integerValue > 33 && integerValue <= 66) {
        return Column(
          children: [
            Image.asset(
              'assets/images/soso.png',
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              '$integerValue%',
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Image.asset(
              'assets/images/cool_fridge.png',
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              '$integerValue%',
            ),
          ],
        );
      }
    } else {
      // 데이터가 없는 경우에 반환할 위젯
      return Image.asset(
        'assets/images/cool_fridge.png',
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.height * 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 전체 폰트 바꾸기
    const String Testfont = "Basicfont";

    // SelectSorting에서 선택한결과를 메인화면에 반영함
    // 등록순
    if (SortingBox.getAt(SortingBox.length - 1) == 1) {
      SortingText = "등록순";
      for (int i = 0; i < pnameBox.length; i++) {
        pnameBox.putAt(i, tNameBox.getAt(i)!);
        productCountBox.putAt(i, tCountBox.getAt(i)!);
        productDateBox.putAt(i, tDateBox.getAt(i)!);
      }
    }
    // 유통기한순, 리스트를 만들어서 Date비교를 하고 유통기한이 빠른순으로 정렬
    else {
      SortingText = "유통기한순";
      List<String> pnameList = List<String>.from(pnameBox.values);
      List<String> productDateList = List<String>.from(productDateBox.values);
      List<int> productCountList = List<int>.from(productCountBox.values);

      List<int> indices = List<int>.generate(pnameList.length, (i) => i);
      indices.sort((a, b) {
        return DateTime.parse(productDateList[a])
            .compareTo(DateTime.parse(productDateList[b]));
      });
      for (int i = 0; i < pnameList.length; i++) {
        pnameBox.putAt(i, pnameList[indices[i]]);
        productDateBox.putAt(i, productDateList[indices[i]]);
        productCountBox.putAt(i, productCountList[indices[i]]);
      }
    }

    return Scaffold(
      //배경색 추가
      backgroundColor: const Color(0xFFDCE6F8),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              foodAchiveMent(),
              const Row(
                children: [
                  Text(
                    '나의 냉장고',
                    style: TextStyle(
                      color: Color(
                        (0xFF42A5F5),
                      ),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                //알림 버튼
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlarmScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications,
                ),
                color: Colors.blue.shade400,
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.015,
              ),
              GestureDetector(
                onTap: () {
                  SelectSorting(context);
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.18,
                        child: Text(
                          SortingText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    for (int i = 0; i < pnameBox.length; i++) {
                      pnameBox.putAt(i, tNameBox.getAt(i)!);
                      productCountBox.putAt(i, tCountBox.getAt(i)!);
                      productDateBox.putAt(i, tDateBox.getAt(i)!);
                    }
                    SortingBox.add(1);
                  });

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          '추가 방식 선택',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                ),
                              ),
                              onPressed: () {
                                // 첫 번째 버튼 동작
                                showToast();
                              },
                              child: const Text(
                                '음식 촬영',
                                style: TextStyle(
                                  color: Color(0xFF42A5F5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                ),
                              ),
                              onPressed: () {
                                // 두 번째 버튼 동작
                                Navigator.pop(context); // 다이얼로그를 닫음
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Receipt(),
                                  ),
                                );
                              },
                              child: const Text(
                                '영수증 촬영',
                                style: TextStyle(
                                  color: Color(0xFF42A5F5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF42A5F5),
                                ),
                              ),
                              onPressed: () {
                                // 세 번째 버튼 동작
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Postpage(),
                                  ),
                                );
                              },
                              child: const Text(
                                '직접 입력',
                                style: TextStyle(
                                  color: Color(0xFF42A5F5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      const Icon(
                        Icons.add_circle_outline,
                        size: 30,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.16,
                      ),
                      Text(
                        '음식 추가',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: const Color.fromRGBO(158, 158, 158, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          //foodlist 넣을 곳
          Expanded(
            child: ListView.builder(
              itemCount: pnameBox.length, // _widgetList의 길이 사용
              itemBuilder: (BuildContext context, int index) {
                // 삭제된 FoodList라면 건너뜁니다.
                if (removedIndices.contains(index)) {
                  return const SizedBox.shrink();
                }
                return FoodList(context, index, removeFoodList);
              },
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),

          GestureDetector(
            onTap: () {
              Recipe(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.07,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                    ),
                    Icon(
                      Icons.restaurant_menu,
                      size: MediaQuery.of(context).size.width * 0.05,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                    ),
                    Text(
                      'AI 레시피',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showToast() {
    Fluttertoast.showToast(
      msg: '아직 개발중입니다...',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void SelectSorting(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.06,
              horizontal: MediaQuery.of(context).size.width * 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '정렬방식 선택',
                style: TextStyle(
                  color: Color(
                    (0xFF42A5F5),
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(10, 25),
                  side: const BorderSide(
                    color: Color(0xFF42A5F5),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '취소',
                  style: TextStyle(
                    color: Color(0xFF42A5F5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF42A5F5),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < SortingBox.length - 2; i++) {
                      SortingBox.deleteAt(i);
                    }
                    SortingBox.add(1);
                    Navigator.pop(context);
                  });
                },
                child: const Text(
                  '등록순',
                  style: TextStyle(
                    color: Color(0xFF42A5F5),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF42A5F5),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < SortingBox.length - 2; i++) {
                      SortingBox.deleteAt(i);
                    }
                    SortingBox.add(0);
                    Navigator.pop(context);
                  });
                },
                child: const Text(
                  '유통기한순',
                  style: TextStyle(
                    color: Color(0xFF42A5F5),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void max99(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.06,
            horizontal: MediaQuery.of(context).size.width * 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최대 99개 까지입니다.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF000000),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  const Color(0xFF42A5F5),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}
