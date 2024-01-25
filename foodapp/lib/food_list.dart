import 'package:flutter/material.dart';

class FoodList extends StatelessWidget {
  final String foodname;
  final String count;
  const FoodList({
    super.key,
    required this.foodname,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
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
                Icons.add_circle_outline,
                size: 30,
              )),
          SizedBox(width: MediaQuery.of(context).size.height * 0.05),
          Text(foodname,
              style: const TextStyle(
                fontSize: 25,
              )),
        ],
      ),
    );
  }
}
