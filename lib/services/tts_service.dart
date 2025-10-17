import 'package:flutter_tts/flutter_tts.dart';

class Tts {
  late FlutterTts flutterTts;
  String _lang = "en-IN";
  double volume = 1.0;
  double pitch = 1.2;
  double rate = 0.55;

  get language => _lang;

  Future<void> init() async {
    flutterTts = FlutterTts();
    flutterTts.setLanguage(_lang);
    flutterTts.setVolume(volume);
    flutterTts.setPitch(pitch);
    flutterTts.setSpeechRate(rate);
  }

  Future<dynamic> setLang(String lang) async {
    await flutterTts.setLanguage(lang);
    _lang = lang;
  }

  Future<dynamic> speak(String text) async {
    await flutterTts.speak(text);
  }
}
