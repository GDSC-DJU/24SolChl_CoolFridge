import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:foodapp/Pages/FoodAddScreen.dart';

// Naver OCR API key
final ocrApiKey = Platform.environment['NAVER_CLOVA_API_KEY'];

//받아온 값을 토대로 품목과 수량이 있는 정보i만 배열에 저장후, 배열을 반환
class ImageProcessor {
  final List<dynamic> fields;

  ImageProcessor(this.fields);

  Future<Map<String, String>> processImage() async {
    List<List<String>> satisfiedTexts = [];
    RegExp regExp = RegExp(r'^\d+(\.\d+)?$');

    for (var i = 0; i < fields.length; i++) {
      List<String> temp = [];
      double y1 = fields[i]['boundingPoly']['vertices'][0]['y'];
      int j = i;

      for (j = i; j < fields.length; j++) {
        double y2 = fields[j]['boundingPoly']['vertices'][0]['y'];
        if ((y1 - y2).abs() < 10.0) {
          String textToAdd =
              fields[j]['inferText'].replaceAll(RegExp(r'[,*]'), '');
          temp.add(textToAdd);
        } else {
          break;
        }
        if (temp.isNotEmpty && regExp.hasMatch(temp[0])) {
          temp.removeAt(0);
        }
      }
      i = j - 1;

      if (temp.length >= 2) {
        bool conditionSatisfied = false;
        for (var k = 0; k < temp.length; k++) {
          for (var l = k + 1; l < temp.length; l++) {
            if (regExp.hasMatch(temp[k]) && regExp.hasMatch(temp[l])) {
              double num1 = double.parse(temp[k]);
              double num2 = double.parse(temp[l]);
              if ((num1 >= 50 && num2 <= 50) || (num1 <= 50 && num2 >= 50)) {
                conditionSatisfied = true;
                break;
              }
            }
          }
          if (conditionSatisfied) break;
        }
        if (conditionSatisfied) {
          satisfiedTexts.add(temp);
        }
      }
    }

    Map<String, String> resultMap = {};
    List<String> count = [];

    for (var textList in satisfiedTexts) {
      // 각 배열의 마지막 3개 요소를 삭제 전에 뒤에서 두 번째 요소를 count 리스트에 저장
      if (textList.length >= 3) {
        count.add(textList[textList.length - 2]);
        textList.removeRange(textList.length - 3, textList.length);
      }
      // 배열의 모든 요소를 하나의 문자열로 합치기
      String mergedText = textList.join(' ');
      if (!resultMap.containsKey(mergedText)) {
        // 중복된 key가 없는 경우에만 추가
        resultMap[mergedText] = count.isEmpty ? '' : count.last;
      }
    }

    print(resultMap);
    return resultMap;
  }
}

class Receipt extends StatelessWidget {
  const Receipt({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FutureBuilder(
          future: sendRequest(context),
          // FutureBuilder의 builder 메서드에서 처리할 때, Map<String, String> 형태로 변환해줍니다.
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                Map<String, String> dataMap =
                    snapshot.data as Map<String, String>;
                return SingleChildScrollView(
                  child: Text(dataMap.entries
                      .map((entry) => '${entry.key}: ${entry.value}')
                      .join('\n')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, String>> sendRequest(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      Navigator.pop(context);
      // null을 반환하여 FutureBuilder에서 null을 처리하도록 합니다.
      throw Exception('No image selected.');
    }

    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    var headers = {
      'Content-Type': 'application/json',
    };
    headers['X-OCR-SECRET'] = ocrApiKey ?? '';

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://b2v3qpqqei.apigw.ntruss.com/custom/v1/28602/2c1c5e74d79d9896cd9a3b9be06605f62ac28a686652415fc81fbc5af23c3e86/general'));
    request.body = json.encode({
      "images": [
        {"format": "png", "name": "medium", "data": base64Image, "url": null}
      ],
      "lang": "ko",
      "requestId": "string",
      "resultType": "string",
      "timestamp": 1708016450,
      "version": "V1"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseData = jsonDecode(responseBody);
      List<dynamic> fields = responseData['images'][0]['fields'];

      // ImageProcessor 인스턴스 생성 후 processImage 메서드 호출
      ImageProcessor processor = ImageProcessor(fields);
      Map<String, String> satisfiedTexts = await processor.processImage();

      // ... 이후 코드 ...
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Postpage(
            satisfiedTexts: satisfiedTexts,
          ), // 이동할 페이지 위젯
        ),
      );
      return satisfiedTexts; // Map<String, String> 반환
    } else {
      throw Exception('Failed to load data');
    }
  }
}
