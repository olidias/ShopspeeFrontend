import 'dart:io';
import 'package:dio/dio.dart';

String retrieveRecognisedText(String filePath) async {
  var bytes = await new File(filePath).readAsBytes();

  String url = "http://40.114.215.137:8080/api/SpeechRecognition";
  Dio dio = new Dio();
  var response = await dio.post(url,
      data: bytes,
      options: Options(
        headers: {
          Headers.contentLengthHeader: bytes.length, // set content-length
        },
      ));
  var text = response.data.toString();
  print("Got response from backend: $text");
  return text;
}
