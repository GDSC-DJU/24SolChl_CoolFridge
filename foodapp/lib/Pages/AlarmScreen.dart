import 'package:flutter/material.dart';
import 'package:foodapp/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
//토글 버튼, 알람 페이지

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   // pnameBox, productDateBox, productCountBox를 열기 전에 이미 열려 있는지 확인합니다.
//   if (!Hive.isBoxOpen('pnameBox')) {
//     await Hive.openBox<String>('pnameBox');
//   }
//   if (!Hive.isBoxOpen('productDateBox')) {
//     await Hive.openBox<String>('productDateBox');
//   }
//   if (!Hive.isBoxOpen('productCountBox')) {
//     await Hive.openBox<int>('productCountBox');
//   }
// }

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Basicfont'),
      debugShowCheckedModeBanner: false,
      home: const ToggleButton(),
    );
  }
}

const List<Widget> type = <Widget>[
  // ToggleButton의 Text
  Text('전체'),
  Text('유통기한 임박/만료'),
  Text('음식 추가/제거')
];

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  final List<bool> _selectedtype = <bool>[
    // ToggleButton의 초기값
    true,
    false,
    false
  ];
  late Box<String> pnameBox;
  late Box<String> productDateBox;
  late Box<int> productCountBox;

  @override
  void initState() {
    super.initState();
    pnameBox = Hive.box<String>('pnameBox');
    productDateBox = Hive.box<String>('productDateBox');
    productCountBox = Hive.box<int>('productCountBox');
  }

  Widget AlarmList(BuildContext context, index) {
    // 컨테이너를 생성 후 출력할 List

    // 현재 날짜를 가져오는 함수
    DateTime getCurrentDate() {
      return DateTime.now();
    }

    // 유통기한을 받아와서 DateTime 객체로 변환하는 함수
    DateTime getProductExpirationDate(int index) {
      String? expirationDateString = productDateBox.getAt(index);
      if (expirationDateString != null) {
        return DateTime.parse(expirationDateString);
      } else {
        // 유통기한이 없을 경우 예외 처리
        return DateTime.now();
      }
    }

    // D-Day를 계산하는 함수
    DateTime currentDate = getCurrentDate(); // 현재 날짜
    DateTime expirationDate = getProductExpirationDate(index); // 유통기한

    // 현재 날짜와 유통기한 사이의 차이 계산
    Duration difference = expirationDate.difference(currentDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.77,
          height: MediaQuery.of(context).size.height * 0.06,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue.shade400,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (_selectedtype[0] &&
                  difference.inDays >=
                      0) // ToggleButton이 전체로 선택 되어 있고, 설정한 날짜와 현재 날짜가 +와 0인 경우 출력
                Expanded(
                  child: Text(
                    " ${pnameBox.getAt(index)} 유통기한 ${productDateBox.getAt(index)}까지 \n ${difference.inDays}일 ${productCountBox.getAt(index)}개 남았어요!",
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              if (_selectedtype[0] &&
                  difference.inDays <
                      0) // ToggleButton이 전체로 선택 되어 있고, 설정한 날짜와 현재 날짜가 -인 경우 출력
                Expanded(
                  child: Text(
                    " ${pnameBox.getAt(index)} 유통기한이 만료 되었어요.",
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              if (_selectedtype[1] &&
                  difference.inDays >=
                      0) // ToggleButton이 유통기한으로 선택 되어 있고, 설정한 날짜와 현재 날짜가 +와 0인 경우 출력
                Expanded(
                  child: Text(
                    " ${pnameBox.getAt(index)} 유통기한이 ${difference.inDays}일 남았어요!",
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              if (_selectedtype[1] &&
                  difference.inDays <
                      0) // ToggleButton이 유통기한으로 선택 되어 있고, 설정한 날짜와 현재 날짜가 -인 경우 출력
                Expanded(
                  child: Text(
                    " ${pnameBox.getAt(index)} 유통기한이 만료 되었어요.",
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              if (_selectedtype[2]) // ToggleButton이 음식 추가/제거로 선택 되어 있을 때 실행
                const Expanded(
                  child: Text(
                    " 추후 구현 예정입니다.",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('냉장고 알림'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF42A5F5),
        ),
        leading: IconButton(
          // 뒤로가기 버튼
          onPressed: () {
            Navigator.replace(
              context,
              oldRoute: ModalRoute.of(context)!,
              newRoute: MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Color(0xFF2196F3),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ToggleButtons(
              // ToggleButton 색상, 상자 및 선택 시 구분
              onPressed: (int index) {
                setState(
                  () {
                    for (int i = 0; i < _selectedtype.length; i++) {
                      _selectedtype[i] = i == index;
                    }
                  },
                );
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.blue[700],
              selectedColor: Colors.white,
              fillColor: Colors.blue[200],
              color: Colors.blue[400],
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 100.0,
              ),
              isSelected: _selectedtype,
              children: type,
            ),
            Visibility(
              // 전체를 눌렀을 때
              visible: _selectedtype[0],
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pnameBox.length, // _widgetList의 길이 사용
                        itemBuilder: (BuildContext context, int index) {
                          return AlarmList(
                              context, index); // _widgetList의 각 항목 반환
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              // 유통기한을 눌렀을 때
              visible: _selectedtype[1],
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pnameBox.length, // _widgetList의 길이 사용
                        itemBuilder: (BuildContext context, int index) {
                          return AlarmList(
                              context, index); // _widgetList의 각 항목 반환
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              // 수량을 눌렀을 때
              visible: _selectedtype[2],
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: 1, // _widgetList의 길이 사용
                        itemBuilder: (BuildContext context, int index) {
                          return AlarmList(
                              context, index); // _widgetList의 각 항목 반환
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
