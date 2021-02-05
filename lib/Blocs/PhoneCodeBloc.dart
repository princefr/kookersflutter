
import 'package:kookers/Mixins/PhoneCodeValidation.dart';
import 'package:rxdart/rxdart.dart';

class PhoneCodeBloc with PhoneCodeValidation {

    // ignore: close_sinks
  BehaviorSubject<String> code = new BehaviorSubject<String>();
  Stream<String> get code$ => code.stream;
  Sink<String> get inCode => code.sink;


  Stream<String> get validatecode => CombineLatestStream<String , String>([code$], (values) => values[0] + values[1]).transform(validateCode).asBroadcastStream();



  String validate(){
    return this.code.value;
  }

  
}