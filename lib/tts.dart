import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

class TTS extends StatefulWidget {
  const TTS({Key key}) : super(key: key);

  @override
  _TTSState createState() => _TTSState();
}

class _TTSState extends State<TTS> {
  PDFDoc? _pdfDoc;
  String _text = "";
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController textEditingController = TextEditingController();

  _speak(String text) async {
    await flutterTts.setLanguage('te-IN');
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Pdf Sonic',
              style: TextStyle(
                fontFamily: "DancingScript-Bold.ttf",
                fontSize: 30,
                color: Colors.black,
              ),
            ),
          ),
        ),
        body: Center(
          child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/5.jpg'),
                fit: BoxFit.cover,
              )),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Enter Something To Speak',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.blue))),
                          controller: textEditingController,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Text(
                        'Press this button to speak',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      onPressed: () async {
                        _speak(textEditingController.text);
                      },
                    ),
                  ),
                ], // <widget>[]
              )),
        ),
      ),
    );
  }
}
