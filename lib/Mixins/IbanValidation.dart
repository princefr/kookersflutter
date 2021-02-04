import 'dart:async';
import 'package:iban/iban.dart';



mixin IbanValidation {


  final validateIban = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
     if(isValid(value)){
          sink.add(value);
        } else{
          sink.addError("Veuillez renseigner un iban valide");
        }
      
    });


  

}