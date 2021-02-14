





import 'dart:async';

mixin GuidelinesValidation {
     final policiesAccepted = StreamTransformer<bool, bool>.fromHandlers(handleData: (value, sink) {
        print(value);
          if(value){
          sink.add(value);
        } else{
          sink.addError("Veuillez accepter nos politiques pour continuer");
        }
    });


         final policiesAccepted1 = StreamTransformer<bool, bool>.fromHandlers(handleData: (value, sink) {
          if(value){
          sink.add(value);
        } else{
          sink.addError("Veuillez accepter nos politiques pour continuer");
        }
    });


         final policiesAccepted2 = StreamTransformer<bool, bool>.fromHandlers(handleData: (value, sink) {
          if(value){
          sink.add(value);
        } else{
          sink.addError("Veuillez accepter nos politiques pour continuer");
        }
    });
}