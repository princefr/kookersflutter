import 'dart:async';



mixin PhoneNumberValidation {

  static bool isValidPhoneNumber(String string) {
      if (string.isEmpty || string == null) {
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
          sink.addError("the phone must be a valid phone call");
        }
      
    });

  final phoneIsFilled  = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
     if(value.isNotEmpty){
          sink.add(value);
        } else{
          sink.addError("the phone ");
        }
    });


  


}