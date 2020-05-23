import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

Future<String> retrieveRecognisedText(String filePath) async {
  var bytes = await new File(filePath).readAsBytes();
  var encodedBytes = base64.encode(bytes);
  Map map ={
    'Data': encodedBytes
  };
  String url = "http://23.100.3.194/api/SpeechRecognition";
  Dio dio = new Dio();
  print("Sending string to backend: $encodedBytes");
  var response = await dio.post(url,
      options: Options(
        headers: {
          Headers.contentLengthHeader: encodedBytes.length, // set content-length
        },
        contentType: "application/json"
      ),
      data: map);

  // var response = await dio.get(url);
  var text = response.data.toString();
  print("Got response from backend: $text");
  return text;
}
