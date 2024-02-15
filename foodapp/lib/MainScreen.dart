import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/AlarmScreen.dart';
import 'package:foodapp/CameraScreen.dart';
import 'package:foodapp/gpt.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:foodapp/notification.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

//MainScreen 코드
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
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

  runApp(const MainScreen());
  FlutterNativeSplash.remove();
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _MainScreen(),
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
  late Map<int, bool> switchStates = {};

  //정렬순으로 하는 hive 변수 선언
  late Box<String> tNameBox;
  late Box<String> tDateBox;
  late Box<int> tCountBox;
  late Box<int> SortingBox;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    pnameBox = Hive.box<String>('pnameBox');
    productDateBox = Hive.box<String>('productDateBox');
    productCountBox = Hive.box<int>('productCountBox');
    _formKey = GlobalKey<FormState>();

    tNameBox = Hive.box<String>('tNameBox');
    tDateBox = Hive.box<String>('tDateBox');
    tCountBox = Hive.box<int>('tCountBox');
    SortingBox = Hive.box<int>('SortingBox');

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
      const Duration(seconds: 300),
      (Timer t) => notificationcount(),
    );
  }

  void fetchData() {
    var pnameBox = Hive.box<String>('pnameBox');
    var productDateBox = Hive.box<String>('productDateBox');
    var productCountBox = Hive.box<int>('productCountBox');

    print('pnameBox: ${pnameBox.values}');
    print('productDateBox: ${productDateBox.values}');
    print('productCountBox: ${productCountBox.values}');
    print('tNameBox: ${tNameBox.values}');
    print('tDateBox: ${tDateBox.values}');
    print('tCountBox: ${tCountBox.values}');
    print('SortingBox: ${SortingBox.values}');
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
                      color: Color(0xFF35AED4),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // 높이 조절
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: List.generate(pnameBox.length, (index) {
                          String productName = pnameBox.getAt(index) ?? '';
                          bool isSelected = switchStates.containsKey(index)
                              ? switchStates[index]!
                              : false;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Switch(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    switchStates[index] = value;
                                  });
                                },
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.grey,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20), // 여백 추가
                  ],
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
                          String generatedText =
                              await GPT3.generateText(prompt);
                          setState(() {
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
                              title: const Text("알림"),
                              content: const Text("1개 이상의 재료를 선택해주세요."),
                              actions: <Widget>[
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
                      }
                      // contentText에 내용이 있을 때만 두 번째 AlertDialog를 표시하도록 수정
                      if (contentText.isNotEmpty) {
                        // 첫 번째 AlertDialog의 content를 두 번째 AlertDialog의 content로 대체
                        Navigator.of(context).pop(); // 첫 번째 AlertDialog 닫기
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
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
                                            String generatedText =
                                                await GPT3.generateText(prompt);
                                            Navigator.of(context)
                                                .pop(); // 현재 다이얼로그 닫기
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
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
                    child: const Text(
                      '선택 완료',
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
                      (0xFF35AED4),
                    ),
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
                  ),
                  const Text('수량'),
                  TextFormField(
                    controller: productCountController,
                    keyboardType: TextInputType.number,
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
                            color: Color.fromARGB(255, 61, 237, 247),
                          ), // 테두리 색 및 너비 지정
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color.fromARGB(255, 61, 237, 247),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 61, 237, 247),
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
    });
    // 삭제된 상품 다음 상품들의 인덱스를 조정하기 위해 removedIndices 리스트 업데이트
    removedIndices.add(index);
  }

  final int _counter = 0;
  var SortingText = "등록순";

//FoodList
  Widget FoodList(BuildContext context, index, Function(int) removeCallback) {
    int counter = 0;

    void incrementCounter(int index) {
      setState(() {
        int currentValue = productCountBox.getAt(index) ?? 0;
        productCountBox.putAt(index, currentValue + 1);
        tCountBox.putAt(index, currentValue + 1);
      });
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
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
            width: MediaQuery.of(context).size.width * 0.65,
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.height * 0.03),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${pnameBox.getAt(index)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${productDateBox.getAt(index)}',
                        style: const TextStyle(
                          fontSize: 15,
                        )),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // 유통기한 순으로 정렬되어있다면, 등록순으로 바꾸고 decrementCounter하고 다시 유통기한순으로 바꾼다.
                        if (SortingBox.getAt(SortingBox.length - 1) == 0) {
                          for (int i = 0; i < SortingBox.length - 2; i++) {
                            SortingBox.deleteAt(i);
                          }
                          SortingBox.add(1);
                          if (productCountBox.getAt(index)! > 1) {
                            decrementCounter(index);
                          } else if (productCountBox.getAt(index)! == 1) {
                            setState(() {
                              pnameBox.deleteAt(index);
                              productDateBox.deleteAt(index);
                              productCountBox.deleteAt(index);
                              tNameBox.deleteAt(index);
                              tDateBox.deleteAt(index);
                              tCountBox.deleteAt(index);
                            });
                          }
                          for (int i = 0; i < SortingBox.length - 2; i++) {
                            SortingBox.deleteAt(i);
                          }
                          SortingBox.add(0);
                        } else {
                          if (productCountBox.getAt(index)! > 1) {
                            decrementCounter(index);
                          } else if (productCountBox.getAt(index)! == 1) {
                            setState(() {
                              pnameBox.deleteAt(index);
                              productDateBox.deleteAt(index);
                              productCountBox.deleteAt(index);
                              tNameBox.deleteAt(index);
                              tDateBox.deleteAt(index);
                              tCountBox.deleteAt(index);
                            });
                          }
                        }

                        fetchData();
                      },
                      icon: const Icon(
                        Icons.remove,
                        size: 20,
                      ),
                    ),
                    Text(
                      '${productCountBox.getAt(index)}',
                      style: const TextStyle(fontSize: 20),
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
                      icon: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height * 0.035,
          child: OutlinedButton(
            onPressed: () async {
              if (await RemoveDialog(context, index)) {
                setState(() {
                  pnameBox.deleteAt(index);
                  productDateBox.deleteAt(index);
                  productCountBox.deleteAt(index);
                  tNameBox.deleteAt(index);
                  tDateBox.deleteAt(index);
                  tCountBox.deleteAt(index);
                });
              }
            },
            child: const Text(
              '제거',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  //late String name; ${name}

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  fetchData();
                  //Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.info_outline,
                ),
              ),
              const Row(
                children: [
                  Text(
                    '나의 냉장고',
                    style: TextStyle(
                      color: Color(
                        (0xFF35AED4),
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
                color: Colors.black,
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
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
                        width: MediaQuery.of(context).size.width * 0.2,
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
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
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
                    Navigator.pop(context);
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraPage(),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
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
                          width: MediaQuery.of(context).size.height * 0.05),
                      const Text(
                        '음식 추가',
                        style: TextStyle(
                          fontSize: 25,
                          color: Color.fromRGBO(158, 158, 158, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
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

          //뭐 먹을까? 코드
          GestureDetector(
            onTap: () {
              Recipe(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.food_bank),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                    const Text(
                      'AI 레시피',
                      style: TextStyle(
                        fontSize: 30,
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

  void SelectSorting(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                    (0xFF35AED4),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '취소',
                ),
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
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
                ),
              ),
              ElevatedButton(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// void showToast() {
//   Fluttertoast.showToast(
//     msg: '0개 이상만 가능합니다',
//     gravity: ToastGravity.BOTTOM,
//     toastLength: Toast.LENGTH_SHORT,
//   );
// }

Future<bool> RemoveDialog(BuildContext context, int index) async {
  bool checkremove = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 61, 237, 247),
                    ), // 테두리 색 및 너비 지정
                  ),
                  onPressed: () {
                    checkremove = false;
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Color.fromARGB(255, 61, 237, 247),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 61, 237, 247),
                    ),
                  ),
                  onPressed: () {
                    checkremove = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
  return checkremove;
}
