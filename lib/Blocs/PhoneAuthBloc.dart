


import 'package:kookers/Core/BaseValidationBloc.dart';
import 'package:kookers/Core/ValidationTransformers.dart';
import 'package:rxdart/rxdart.dart';

class PhoneAuthBloc with ValidationBlocMixin {
  late final ValidationFieldSimple<String> phoneCode;
  late final ValidationField<String> phoneNumber;
  late final ValidationField<String> userCountry;
  late final ValidationField<String> userCurrency;
  late final ValidationFieldSimple<String> both;
  var telephone = "";

  PhoneAuthBloc() {
    phoneCode = createSimpleField("+33");
    phoneNumber = createValidationField(ValidationTransformers.phoneIsFilled);
    userCountry = createValidationField(ValidationTransformers.phoneIsFilled, "FR");
    userCurrency = createValidationField(ValidationTransformers.phoneIsFilled, "eur");
    both = createSimpleField<String>();
  }

  // Getters for compatibility
  Stream<String> get phoneCode$ => phoneCode.stream;
  Sink<String> get inphoneCode => phoneCode.sink;

  Stream<String> get phoneNumber$ => phoneNumber.stream;
  Sink<String> get inphoneNumber => phoneNumber.sink;

  Stream<String> get userCountry$ => userCountry.stream;
  Sink<String> get inuserCountry => userCountry.sink;

  Stream<String> get useruserCurrency$ => userCurrency.stream;
  Sink<String> get inuserCurrency => userCurrency.sink;




  Stream<String> get phoneAndCode => CombineLatestStream<String, String>(
    [phoneCode$, phoneNumber$], 
    (values) => values[0] + values[1]
  ).transform(ValidationTransformers.validatePhoneNumber).asBroadcastStream();

  void listen() {
    phoneAndCode.listen((event) {
      this.telephone = event;
    });
  }

  Stream<bool> get isAllFilled$ => CombineLatestStream([phoneNumber$, phoneAndCode], (values) => true);

  Future<String> validate() async {
    return this.telephone;
  }





}