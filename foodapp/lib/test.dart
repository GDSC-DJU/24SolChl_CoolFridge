import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('HTTP Request Example')),
        body: FutureBuilder(
          future: sendRequest(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return SingleChildScrollView(
                  child: Text('Loaded: ${snapshot.data}'),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<String> sendRequest() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return 'No image selected.';

    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    var headers = {
      'Content-Type': 'application/json',
      'X-OCR-SECRET': 'UHR4QnFaZ3p6VVhOaWJvZXlHdnZyVUVCeEVMQ0N0bUI='
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://7m5y15g6uj.apigw.ntruss.com/custom/v1/28445/fe426698a09aae79e9e498cf05f2ada8d1d024697c057fd15beabe67990e19d1/general'));
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
      return await response.stream.bytesToString();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
