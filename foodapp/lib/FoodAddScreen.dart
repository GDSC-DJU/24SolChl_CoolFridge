import 'package:flutter/material.dart';
import 'package:foodapp/MainScreen.dart';
//import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

// 포스트 페이지 위젯
class Postpage extends StatefulWidget {
  const Postpage({super.key});

  @override
  State<Postpage> createState() => _SecondViewState();
}

// 포스트 페이지 상태
class _SecondViewState extends State<Postpage> {
  DateTime date = DateTime.now();
  final List<Widget> _widgetList = []; // 음식정보를 입력하는 위젯을 담는 리스트
  final List<TextEditingController> _controller = [];
  final List<int> Dellist = []; // 위젯을 지울 때, 위젯의 고유키를 이 리스트에 담음
  final List<int> _Livingkey = []; // 살아있는 위젯키
//final Function(String) CountChanged;
  int Numberkey = 0; // 위젯을 만들때마다 1씩 증가하며, 위젯마다의 고유키로 들어간다
  int Delnum =
      0; // 음식정보를 입력해주는 위젯을 추가할 때마다 Numberkey를 하나씩 올린다. 위젯에 int형 widgetkey에 입력함
  Map<int, String> pname = {}; // key: 위젯키, value: 제품명
  Map<String, String> productDate = {}; // key: 제품명, value: 수량
  Map<String, int> productCount = {}; // key: 제품명, value: 수량
  bool Checktext = true; // 등록하기 버튼누를 때 비어있는지 확인하는 변수

// 다른 파일에서 _widgetList의 길이에 접근할 수 있는 메서드
  int getWidgetListLength() {
    return _widgetList.length;
  }

  @override
  void initState() {
    super.initState();
    openBoxes(); // Hive 박스를 열어주는 메서드 호출
  }

// Hive 박스 열기
  void openBoxes() async {
    if (!Hive.isBoxOpen('pnameBox')) {
      await Hive.openBox<String>('pnameBox');
    }
    if (!Hive.isBoxOpen('productDateBox')) {
      await Hive.openBox<String>('productDateBox');
    }
    if (!Hive.isBoxOpen('productCountBox')) {
      await Hive.openBox<int>('productCountBox');
    }
    if (!Hive.isBoxOpen('CountBox')) {
      await Hive.openBox<int>('CountBox');
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
  }

// pname, productDate, productCount 저장
  void saveData() async {
    var pnameBox = Hive.box<String>('pnameBox');
    var productDateBox = Hive.box<String>('productDateBox');
    var productCountBox = Hive.box<int>('productCountBox');
    var tNameBox = Hive.box<String>('tNameBox');
    var tDateBox = Hive.box<String>('tDateBox');
    var tCountBox = Hive.box<int>('tCountBox');

    int lastIndex = pnameBox.length;
    int startIndex = lastIndex + 1;

    // _Livingkey 리스트에 있는 각각의 요소에 대해 해당하는 정보만 저장
    for (int i = 0; i < _Livingkey.length; i++) {
      int widgetKey = startIndex + i;
      String? productName = pname[_Livingkey[i]];
      if (productName != null) {
        String? productDateValue = productDate[productName];
        int? productCountValue = productCount[productName];
        if (productDateValue != null && productCountValue != null) {
          pnameBox.add(productName);
          productDateBox.add(productDateValue);
          productCountBox.add(productCountValue);
          tNameBox.add(productName);
          tDateBox.add(productDateValue);
          tCountBox.add(productCountValue);
        }
      }
    }
  }

  void fetchData() {
    var pnameBox = Hive.box<String>('pnameBox');
    var productDateBox = Hive.box<String>('productDateBox');
    var productCountBox = Hive.box<int>('productCountBox');
    var tNameBox = Hive.box<String>('tNameBox');
    var tDateBox = Hive.box<String>('tDateBox');
    var tCountBox = Hive.box<int>('tCountBox');

    print('pnameBox: ${pnameBox.values}');
    print('productDateBox: ${productDateBox.values}');
    print('productCountBox: ${productCountBox.values}');
    print('tNameBox: ${tNameBox.values}');
    print('tDateBox: ${tDateBox.values}');
    print('tCountBox: ${tCountBox.values}');
  }

// 텍스트 컨트롤러 추가
  void addTextlist(TextEditingController controller) {
    _controller.add(controller);
  }

// 리스트 추가
  void addlist() {
    TextEditingController textController = TextEditingController();
    _controller.add(textController);
    _Livingkey.add(Numberkey);
    setState(() {
      _widgetList.add(postContainer(
        productname: "",
        widgetkey: Numberkey,
        controller: textController,
      ));
      Numberkey++;
    });
  }

// 위젯 리스트의 인덱스 번호를 맞추기 위해 Delnum을 바꾸는 함수
  void ChangedDelnum(int widgetkey) {
    for (int i = 0; i < Dellist.length; i++) {
      if (widgetkey > Dellist[i]) {
        widgetkey--;
      }
    }
    Dellist.last = widgetkey;
    Delnum = widgetkey;
    removelist(widgetkey);
  }

// 리스트 제거
  void removelist(int widgetkey) {
    setState(() {
      _widgetList.removeAt(Delnum);
      _controller.removeAt(Delnum);
      _Livingkey.removeAt(widgetkey);
    });
  }

// 위젯을 리빌딩하는 함수
  void rebuilding(int widgetkey, TextEditingController controller) {
    int key = 0;
    for (int i = 0; i < _Livingkey.length; i++) {
      if (widgetkey == _Livingkey[i]) {
        key = i;
        break;
      }
    }
    setState(() {
      _widgetList[key] = (postContainer(
        productname: pname[widgetkey] ?? "",
        widgetkey: widgetkey,
        pcount: productCount[pname[widgetkey]]!,
        pdate: productDate[pname[widgetkey]]!,
        controller: controller,
      ));
    });
  }

//등록하기 버튼을 눌렀을 때 리스트 수만큼 메인화면에 넘기기 위한 함수

// 제품명 초기화
  void initname(String name, int widgetkey) {
    pname[widgetkey] = name;
    if (!productCount.containsKey(name)) {
      productCount[name] = 1;
    }
    if (!productDate.containsKey(name)) {
      productDate[name] =
          "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
    print("$widgetkey번의 제품명이 $name으로 바뀌었습니다.");
  }

// 제품 날짜 설정
  void setDate(String name) {
    setState(() {
      productDate[name] =
          "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    });
    print("$name의 날짜는 ${productDate[name]}");
  }

// 제품 수량 증가
  void icount(String name) {
    setState(() {
      productCount[name] = (productCount[name] ?? 0) + 1;
      print("$name 는 ${productCount[name]} 개");
    });
  }

  void ERRDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("제품명을 다 채워주세요."),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              )
            ],
          ),
        );
      },
    );
  }

// 제품 수량 감소
  void dcount(String name) {
    setState(() {
      if (productCount[name] != null && productCount[name]! > 1) {
        productCount[name] = (productCount[name] ?? 0) - 1;
      }
      print("$name 는 ${productCount[name]} 개");
    });
  }

// 위젯 생성 및 출력
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          color: const Color.fromARGB(255, 53, 175, 212),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          "음식등록",
          style: TextStyle(color: Color.fromARGB(255, 53, 175, 212)),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: (MediaQuery.of(context).size.height) * 0.82,
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                itemCount: _widgetList.length, //몇 개 할 것인지
                itemBuilder: (context, index) {
                  //어떤 View를 그릴 것인지
                  return _widgetList[index];
                },
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: (MediaQuery.of(context).size.height) * 0.1,
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => setState(() => addlist()),
                          icon: const Icon(Icons.add_circle_outlined),
                        ),
                        // TextButton(
                        //   onPressed: () => {
                        //     for (int i = 0; i < _Livingkey.length; i++)
                        //       {
                        //         print(
                        //             "widgetkey: ${_Livingkey[i]}, 제품명 : ${pname[_Livingkey[i]]}, \t수량 : ${productCount[pname[_Livingkey[i]]]}, \t유통기한 : ${productDate[pname[_Livingkey[i]]]}")
                        //       },
                        //     print("\n")
                        //   },
                        //   child: const Text("speak"),
                        // ),
                        Center(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(120, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 53, 175, 212),
                                width: 2,
                              ),
                            ),
                            child: const Text(
                              "취소",
                              style: TextStyle(
                                color: Color.fromARGB(255, 53, 175, 212),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Checktext = true;
                            for (int i = 0; i < _Livingkey.length; i++) {
                              if (pname[_Livingkey[i]] == "") {
                                Checktext = false;
                                break;
                              }
                            }
                            print(Checktext);
                            if (Checktext == false) {
                              ERRDialog(context);
                            } else {
                              saveData();
                              fetchData();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => //상품명, 수량, 유통기한도 괄호에 적을 예정
                                          const MainScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 53, 175, 212),
                            minimumSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "등록하기",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
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

// 제품 정보를 담은 위젯 생성
  Widget postContainer({
    String productname = "",
    int widgetkey = 0,
    int pcount = 1,
    String pdate = "2024-01-01",
    required TextEditingController controller,
  }) {
    if (!productCount.containsKey(productname)) {
      productCount[productname] = 1;
    }
    pname[widgetkey] = productname;

    if (!productDate.containsKey(productname)) {
      productDate[productname] =
          "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    if (pdate != "2024-01-01") {
      productDate[pname[widgetkey]!] = pdate;
    }

    if (pcount == 0) {
      productCount[pname[widgetkey]!] = 1;
    }

    return Center(
      child: Column(
        children: [
          Container(height: 1.1, color: Colors.grey),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => {
                            Dellist.add(widgetkey),
                            ChangedDelnum(widgetkey),
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                            size: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                    Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: (MediaQuery.of(context).size.width) * 0.2,
                      child: Center(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: productname,
                              labelStyle: const TextStyle(fontSize: 15)),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          onChanged: (text) {
                            productname = text;
                            initname(text, widgetkey);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width) * 0.02,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            const Text("유통기한"),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width) * 0.3,
                              height:
                                  (MediaQuery.of(context).size.height) * 0.03,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: date,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      date = selectedDate;
                                    });
                                  }
                                  setDate(productname);
                                  date = DateTime.now();
                                  rebuilding(widgetkey, controller);
                                },
                                child: Text(
                                  "${productDate[productname]}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 15),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("추천기간"),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width) * 0.3,
                              height:
                                  (MediaQuery.of(context).size.height) * 0.03,
                              child: ElevatedButton(
                                // style: ElevatedButton.styleFrom(
                                //   maximumSize: const Size(100, 50)
                                // ),
                                onPressed: () {},
                                child: Text(
                                  "${productDate[productname]}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.check_circle_outline, size: 15),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width) * 0.005,
                    ),
                    Column(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => {
                            if (pname[widgetkey] != null)
                              {
                                icount(pname[
                                    widgetkey]!) // !는 pname[widgeykey]가 null이 아님을 보장한다.
                              },
                            rebuilding(widgetkey, controller),
                          },
                          icon: const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.red,
                            size: 15,
                          ),
                        ),
                        Center(
                          child: Text("${productCount[pname[widgetkey]] ?? 1}"),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => {
                            if (pname[widgetkey] != null)
                              {
                                dcount(pname[
                                    widgetkey]!) // !는 pname[widgeykey]가 null이 아님을 보장한다.
                              },
                            rebuilding(widgetkey, controller),
                          },
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.red,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}