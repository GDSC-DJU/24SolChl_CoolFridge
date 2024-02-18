// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// //받아온 값을 토대로 품목과 수량이 있는 정보만 배열에 저장후, 배열을 반환
// class ImageProcessor {
//   final List<dynamic> fields;

//   ImageProcessor(this.fields);

//   Future<List<String>> processImage() async {
//     List<String> satisfiedTexts = [];
//     RegExp regExp = RegExp(r'^\d+(\.\d+)?$');

//     for (var i = 0; i < fields.length; i++) {
//       List<String> temp = []; // 임시 배열
//       double y1 = fields[i]['boundingPoly']['vertices'][0]['y'];
//       int j = i; // j 변수를 반복문 바깥에서 선언

//       for (j = i; j < fields.length; j++) {
//         double y2 = fields[j]['boundingPoly']['vertices'][0]['y'];
//         if ((y1 - y2).abs() < 10.0) {
//           // 같은 y축에 있는 모든 텍스트를 임시 배열에 추가
//           String textToAdd = fields[j]['inferText'].replaceAll(',', '');
//           temp.add(textToAdd);
//           print('코드 추가! : $textToAdd'); // 코드 추가와 함께 해당 변수 출력
//         } else {
//           break; // y축이 다른 텍스트를 만나면 반복문을 종료
//         }
//       }
//       i = j - 1;

//       if (temp.length >= 2) {
//         bool conditionSatisfied = false;
//         for (var k = 0; k < temp.length; k++) {
//           for (var l = k + 1; l < temp.length; l++) {
//             if (regExp.hasMatch(temp[k]) && regExp.hasMatch(temp[l])) {
//               double num1 = double.parse(temp[k]);
//               double num2 = double.parse(temp[l]);
//               if ((num1 >= 50 && num2 <= 50) || (num1 <= 50 && num2 >= 50)) {
//                 conditionSatisfied = true;
//                 break;
//               }
//             }
//           }
//           if (conditionSatisfied) break;
//         }
//         if (conditionSatisfied) {
//           satisfiedTexts.addAll(temp);
//         }
//       }
//     }

//     return satisfiedTexts;
//   }
// }

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('HTTP Request Example')),
//         body: FutureBuilder(
//           future: sendRequest(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else {
//                 return SingleChildScrollView(
//                   child: Text('Loaded: ${snapshot.data.join('\n')}'),
//                 );
//               }
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Future<List<String>> sendRequest() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile == null) return ['No image selected.'];

//     final bytes = await pickedFile.readAsBytes();
//     final base64Image = base64Encode(bytes);

//     var headers = {
//       'Content-Type': 'application/json',
//       'X-OCR-SECRET': 'V1pabWZSaVFoVk1aVFJGQWdiZ0hhQmdiUVplWldWWEU='
//     };
//     var request = http.Request(
//         'POST',
//         Uri.parse(
//             'https://7m5y15g6uj.apigw.ntruss.com/custom/v1/28468/02ec6a282ef554ec52b7e9b0b008f83d5aba56c0505fdcdf8869bde31671e7e5/general'));
//     request.body = json.encode({
//       "images": [
//         {"format": "png", "name": "medium", "data": base64Image, "url": null}
//       ],
//       "lang": "ko",
//       "requestId": "string",
//       "resultType": "string",
//       "timestamp": 1708016450,
//       "version": "V1"
//     });
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       String responseBody = await response.stream.bytesToString();
//       Map<String, dynamic> responseData = jsonDecode(responseBody);
//       List<dynamic> fields = responseData['images'][0]['fields'];

//       // ImageProcessor 인스턴스 생성 후 processImage 메서드 호출
//       ImageProcessor processor = ImageProcessor(fields);
//       List<String> satisfiedTexts = await processor.processImage();

//       return satisfiedTexts;
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
// }
