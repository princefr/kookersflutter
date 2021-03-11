



import 'package:kookers/Mixins/PhoneNumberValidation.dart';
import 'package:rxdart/rxdart.dart';

class PhoneAuthBloc with PhoneNumberValidation {

  void dispose(){
    this.phoneCode.close();
    this.phoneNumber.close();
    this.userCountry.close();
    this.userCurrency.close();
    this.both.close();
  }

  
  BehaviorSubject<String> phoneCode = new BehaviorSubject<String>.seeded("+33");
  Stream<String> get phoneCode$ => phoneCode.stream;
  Sink<String> get inphoneCode => phoneCode.sink;


  
  BehaviorSubject<String> phoneNumber = new BehaviorSubject<String>();
  Stream<String> get phoneNumber$ => phoneNumber.stream.transform(phoneIsFilled);
  Sink<String> get inphoneNumber => phoneNumber.sink;


  
  BehaviorSubject<String> userCountry = new BehaviorSubject<String>.seeded("FR");
  Stream<String> get userCountry$ => userCountry.stream.transform(phoneIsFilled);
  Sink<String> get inuserCountry => userCountry.sink;


  
  BehaviorSubject<String> userCurrency = new BehaviorSubject<String>.seeded("eur");
  Stream<String> get useruserCurrency$ => userCurrency.stream.transform(phoneIsFilled);
  Sink<String> get inuserCurrency => userCurrency.sink;


  
  BehaviorSubject<String> both = new BehaviorSubject<String>();
  var telephone = "";




  Stream<String> get phoneAndCode => CombineLatestStream<String , String>([phoneCode$, phoneNumber$], (values) => values[0] + values[1]).transform(validatePhoneNumber).asBroadcastStream();

void listen() {
  phoneAndCode.listen((event) {this.telephone = event; });
}



  Stream<bool> get isAllFilled$ => CombineLatestStream([phoneNumber$, phoneAndCode], (values) => true);


  Future<String> validate() async {
      return this.telephone;
  }





}