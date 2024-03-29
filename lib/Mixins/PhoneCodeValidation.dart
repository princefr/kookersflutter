import 'dart:async';



mixin PhoneCodeValidation {
  static bool isNotEmpty(String text) => text.isNotEmpty;


  final validateCode = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
     if(value.isNotEmpty){
          sink.add(value);
        } else{
          sink.addError("Veuillez renseigner le code recu");
        }
      
    });
}