import 'dart:async';

import 'dart:io';

mixin PublicationValidation {
  static bool isNotEmpty(String text) => text.isNotEmpty;

  final validateName = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
    if(value.length > 0){
      sink.add(value);
    } else{
      sink.addError("error name must be filled");
    }
  });

  final validateDescription = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
  if(value != null) {
      if(value.isNotEmpty){
      sink.add(value);
    } else{
      sink.addError("error description must be filled");
    }
  }
  });

  final validatePrice = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
    if(value != null) {
      if(value.isNotEmpty){
      sink.add(value);
    } else{
      sink.addError("error Price must be filled");
    }
    }
  });

  final validatePricePerPortion = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
    if(value != null) {
          if(value.isNotEmpty){
      sink.add(value);
    } else{
      sink.addError("error Price must be filled");
    }
    }
  });


  final pictureValidation = StreamTransformer<List<File>, List<File>>.fromHandlers(handleData: (value, sink) {

  });

}