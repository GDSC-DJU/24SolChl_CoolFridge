import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';

void main() {
  runApp(const MainScreen());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MainScreen> {
  //late String name; ${name}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                  ),
                ),
                const Text(
                  '성연 냉장고',
                  style: TextStyle(
                    color: Color(
                      (0xFF35AED4),
                    ),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  //알림 버튼
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications,
                  ),
                  color: Colors.black,
                )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                const Text(
                  '유통기한순', //dialog로 가자
                ),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.arrow_drop_down))
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                Container(
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
                      IconButton(
                          // + 아이콘 누르면 뭐할지 작성해야함
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 30,
                            color: Colors.grey,
                          )),
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
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          // + 아이콘 누르면 뭐할지 작성해야함
                          onPressed: () {},
                          icon: const Icon(
                            Icons.fastfood,
                            size: 30,
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.height * 0.05),
                      const Text(
                        '햄버거',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      const Text(
                        '2024-01-26',
                      ),
                      IconButton(
                        //누르면 햄버거에 대한 정보?
                        onPressed: () {},
                        icon: const Icon(
                          Icons.question_mark,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.height * 0.03),
                const Text(
                  '2개',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          // + 아이콘 누르면 뭐할지 작성해야함
                          onPressed: () {},
                          icon: const Icon(
                            Icons.egg_alt_outlined,
                            size: 30,
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.height * 0.05),
                      const Text(
                        '계란',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      const Text(
                        '2024-01-26',
                      ),
                      IconButton(
                        //누르면 햄버거에 대한 정보?
                        onPressed: () {},
                        icon: const Icon(
                          Icons.question_mark,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.height * 0.03),
                const Text(
                  '2개',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Container(
              width: 200,
              height: 50,
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
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.food_bank)),
                    const Text('뭐 먹을까?',
                        style: TextStyle(
                          fontSize: 30,
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
