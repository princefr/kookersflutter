import 'dart:async';



mixin PhoneNumberValidation {

  static bool isValidPhoneNumber(String string) {
      if (string.isEmpty) {
            return false;
      }

      String pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';

      RegExp regExp = new RegExp(pattern);

      if (!regExp.hasMatch(string)) {
            return false;
      }
      return true;
  }

  final validatePhoneNumber = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
     if(isValidPhoneNumber(value)){
          sink.add(value);
        } else{
          sink.addError("Veuillez renseigner votre numéro de téléphone");
        }
      
    });

  final phoneIsFilled  = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
     if(value.isNotEmpty){
          sink.add(value);
        } else{
          sink.addError("Le champs téléphone doit etre remplie");
        }
    });


  


}