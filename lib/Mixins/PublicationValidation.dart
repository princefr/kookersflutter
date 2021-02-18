import 'dart:async';

import 'dart:io';

mixin PublicationValidation {
  static bool isNotEmpty(String text) => text.isNotEmpty;


  final verifyFile = StreamTransformer<File, File>.fromHandlers(handleData: (value, sink) {
    if(value != null){
      sink.add(value);
    } else{
      sink.addError("Veuillez renseigner un nom de plat");
    }
  });

  final validateName = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
    if(value.length > 0){
      sink.add(value);
    } else{
      sink.addError("Veuillez renseigner un nom de plat");
    }
  });

  final validateDescription = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
  if(value != null) {
      if(value.isNotEmpty){
      sink.add(value);
    } else{
      sink.addError("Veuillez renseigner une description");
    }
  }
  });

  final validatePrice = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
    if(value != null) {
      if(value.isNotEmpty){
      sink.add(value);
    } else{
      sink.addError("Veuillez renseigner le prix du plat");
    }
    }
  });

  final validatePricePerPortion = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
    if(value != null) {
          if(value.isNotEmpty){
      sink.add(value);
    } else{
      sink.addError("Veuillez renseigner prix par portion");
    }
    }
  });


  final pictureValidation = StreamTransformer<List<File>, List<File>>.fromHandlers(handleData: (value, sink) {

  });

}