import 'package:kookers/Mixins/IbanValidation.dart';
import 'package:rxdart/rxdart.dart';

class IbanBloc with IbanValidation {

    // ignore: close_sinks
  BehaviorSubject<String> iban = new BehaviorSubject<String>();
  Stream<String> get iban$ => iban.stream.transform(validateIban);
  Sink<String> get inBan => iban.sink;


  IbanBloc();



  String validate(){
    return this.iban.value;
  }


  
  void dispose() { 
    this.iban.close();
  }

  
}