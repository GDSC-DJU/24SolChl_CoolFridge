class TextProcessor {
  final List<String> foodItems;

  TextProcessor(this.foodItems);

  Future<Map<String, String>> processText() async {
    Map<String, String> result = {};
    for (var item in foodItems) {
      result[item] = '1'; // 각 음식명에 '1'을 매핑
    }
    print("Processed Texts Map: $result"); // 결과 맵 출력
    return result;
  }
}
