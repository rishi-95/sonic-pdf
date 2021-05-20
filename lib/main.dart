import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:pdf_text/pdf_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum TtsState { playing, stopped, paused, continued }

class _MyAppState extends State<MyApp> {
  PDFDoc? _pdfDoc;
  String _text = "";
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) {
    flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange() {
    setState(() {
      _newVoiceText = _text;
    });
  }

  Future _pickPDFText() async {
    var filePickerResult = await FilePicker.platform.pickFiles();
    if (filePickerResult != null) {
      _pdfDoc = await PDFDoc.fromPath(filePickerResult.files.single.path!);
      setState(() {});
      _readWholeDoc();
    }
  }

  Future _readWholeDoc() async {
    if (_pdfDoc == null) {
      return;
    }

    String text = await _pdfDoc!.text;

    setState(() {
      _text = text;
    });
    _onChange();
  }

  /// Reads the whole document

  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Sonic PDF'),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  _uploadSection(),
                  _btnSection(),
                  _viewtext()
                ]))));
  }

  Widget _uploadSection() {
    return Container(
        padding: EdgeInsets.only(top: 50.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildButtonColumn(Colors.green, Colors.greenAccent,
              Icons.cloud_upload, 'Upload', _pickPDFText),
        ]));
  }

  Widget _btnSection() {
    if (isAndroid) {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(Colors.green, Colors.greenAccent,
                Icons.play_arrow, 'PLAY', _speak),
            _buildButtonColumn(
                Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
          ]));
    } else {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(Colors.green, Colors.greenAccent,
                Icons.play_arrow, 'PLAY', _speak),
            _buildButtonColumn(
                Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
            _buildButtonColumn(
                Colors.blue, Colors.blueAccent, Icons.pause, 'PAUSE', _pause),
          ]));
    }
  }

  Widget _viewtext() {
    return Padding(
      child: Text(
        _text,
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      padding: EdgeInsets.all(15),
    );
  }

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              iconSize: 50,
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }
}
