



import 'package:kookers/Mixins/PhoneNumberValidation.dart';
import 'package:rxdart/rxdart.dart';

class PhoneAuthBloc with PhoneNumberValidation {


  // ignore: close_sinks
  BehaviorSubject<String> phoneCode = new BehaviorSubject<String>.seeded("+33");
  Stream<String> get phoneCode$ => phoneCode.stream;
  Sink<String> get inphoneCode => phoneCode.sink;


  // ignore: close_sinks
  BehaviorSubject<String> phoneNumber = new BehaviorSubject<String>();
  Stream<String> get phoneNumber$ => phoneNumber.stream.transform(phoneIsFilled);
  Sink<String> get inphoneNumber => phoneNumber.sink;


    // ignore: close_sinks
  BehaviorSubject<String> userCountry = new BehaviorSubject<String>.seeded("FR");
  Stream<String> get userCountry$ => userCountry.stream.transform(phoneIsFilled);
  Sink<String> get inuserCountry => userCountry.sink;


      // ignore: close_sinks
  BehaviorSubject<String> userCurrency = new BehaviorSubject<String>.seeded("eur");
  Stream<String> get useruserCurrency$ => userCurrency.stream.transform(phoneIsFilled);
  Sink<String> get inuserCurrency => userCurrency.sink;


    // ignore: close_sinks
  BehaviorSubject<String> both = new BehaviorSubject<String>();
  var telephone = "";




  Stream<String> get phoneAndCode => CombineLatestStream<String , String>([phoneCode$, phoneNumber$], (values) => values[0] + values[1]).transform(validatePhoneNumber);

void listen() {
  phoneAndCode.listen((event) {this.telephone = event; });
}



  Stream<bool> get isAllFilled$ => CombineLatestStream([phoneNumber$, phoneAndCode], (values) => true);


  




  Future<String> validate() async {
      return this.telephone;
  }





}