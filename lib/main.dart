import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_ffmpeg.dart';

import 'SpeechRecognitionService.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceHome(),
    );
  }
}

class VoiceHome extends StatefulWidget {
  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  bool _isAvailable = false;
  bool _isListening = false;
  FlutterSoundRecorder soundRecorder;
  FlutterSoundPlayer soundPlayer;
  String resultText = "";
  String filePath; 

  @override
  void initState() {
    super.initState();
    initSoundRecorder();
  }

  @override
  void dispose(){
    super.dispose();
    soundRecorder.release();
    soundPlayer.release();
  }

  void initSoundRecorder() {
    new FlutterSoundRecorder().initialize().then((value)
    {
      soundRecorder = value;
      _isAvailable = true;
    });

    new FlutterSoundPlayer().initialize().then((value) => soundPlayer = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 50, 10, 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Shopspee',
                  style: TextStyle(
                    fontSize: 80,
                    fontFamily: 'ClickerScript-Regular'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.mic),
                  onPressed: () {
                    if (_isAvailable && !_isListening)
                    {
                      _isAvailable = false;
                      _isListening = true;
                      Future<String> result = soundRecorder.startRecorder(codec: t_CODEC.CODEC_AAC,);

                      result.then((path) {
                        filePath = path;
                        print('startRecorder: $path');

                        soundRecorder.onRecorderStateChanged.listen((e) {
                          DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
                          print(date);  
                        });
                      });
                    }
                  },
                  backgroundColor: Color.fromARGB(100, 39, 117, 84),
                ),
                FloatingActionButton(
                  child: Icon(Icons.stop),
                  backgroundColor: Color.fromARGB(100, 170, 89, 57),
                  splashColor: Color.fromARGB(100, 85, 24, 0),
                  onPressed: () {
                    soundRecorder.stopRecorder();
                    _isAvailable = true;
                    _isListening = false;
                  },
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 12.0,
              ),
              margin: EdgeInsets.only(top: 20 ,bottom: 20),
              child: Text(
                resultText,
                style: TextStyle(fontSize: 24.0),
              ),
            ), Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              
              children: <Widget>[
                FloatingActionButton(
                  
                  child: Icon(Icons.play_arrow),
                  backgroundColor: Color.fromARGB(100, 152, 51, 82),
                  onPressed: () {
                    print('Reading from $filePath');
                    soundPlayer.startPlayer(filePath);
                  },
                ),
                FloatingActionButton(
                  child: Icon(Icons.graphic_eq),
                  backgroundColor: Color.fromARGB(100, 152, 51, 82),
                  onPressed: () async {
                    String outputPath = filePath.substring(0, filePath.lastIndexOf('/')) + '/output.wav';
                    new FlutterFFmpeg().execute("-i $filePath $outputPath").whenComplete(() => resultText = retrieveRecognisedText(filePath));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}