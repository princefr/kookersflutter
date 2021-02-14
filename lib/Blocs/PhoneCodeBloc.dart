
import 'package:kookers/Mixins/PhoneCodeValidation.dart';
import 'package:rxdart/rxdart.dart';

class PhoneCodeBloc with PhoneCodeValidation {


  BehaviorSubject<String> code = new BehaviorSubject<String>();
  Stream<String> get code$ => code.stream;
  Sink<String> get inCode => code.sink;


  void dispose(){
    this.code.close();
  }



  String validate(){
    return this.code.value;
  }

  
}