import 'package:speech_to_text/speech_to_text.dart';

SpeechToText speech = SpeechToText();

Future<String> startListening() async {

  bool available = await speech.initialize();

  String resultText = "";

  if(available){
    await speech.listen(onResult: (result){
      print("VOICE RESULT: ${result.recognizedWords}");
      resultText = result.recognizedWords;
      
    });

    await Future.delayed(const Duration(seconds:4));
    speech.stop();
  }

  return resultText;
}