
import 'package:kookers/Core/BaseValidationBloc.dart';
import 'package:kookers/Core/ValidationTransformers.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:rxdart/rxdart.dart';



class DateOfBirth {
  String? iso;
  int? day;
  int? month;
  int? year;

  DateOfBirth({this.day, this.month, this.year, this.iso});

  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = Map<String, dynamic>();
    data["day"] = this.day;
    data["month"] = this.month;
    data["year"] = this.year;
    data["iso"] = this.iso;
    return data;
  }
}

class SignupInformations {
  String firstName;
  String lastName;
  String email;
  Adress adress;
  bool policiesAcccepted;
  DateOfBirth? birthDate;
  

  SignupInformations({required this.adress, required this.email, required this.firstName, required this.lastName, required this.policiesAcccepted, this.birthDate});


}



class SignupBloc with ValidationBlocMixin {
  late final ValidationField<String> lastName;
  late final ValidationField<String> firstName;
  late final ValidationField<String> email;
  late final ValidationField<Adress> adress;
  late final ValidationField<DateTime> dateOfBirth;
  late final ValidationField<bool> acceptedPolicies;

  SignupBloc() {
    lastName = createValidationField(ValidationTransformers.validateLastName);
    firstName = createValidationField(ValidationTransformers.validateFirstName);
    email = createValidationField(ValidationTransformers.validateEmail);
    adress = createValidationField(ValidationTransformers.validateAdress);
    dateOfBirth = createValidationField(ValidationTransformers.validatebirthDate);
    acceptedPolicies = createValidationField(ValidationTransformers.validatePoliciesAccepted, false);
  }

  // Getters for compatibility
  Stream<String> get lastName$ => lastName.stream;
  Sink<String> get inlastName => lastName.sink;

  Stream<String> get firstName$ => firstName.stream;
  Sink<String> get infirstName => firstName.sink;

  Stream<String> get email$ => email.stream;
  Sink<String> get inemail => email.sink;

  Stream<Adress> get adress$ => adress.stream;
  Sink<Adress> get inadress => adress.sink;

  Stream<DateTime> get dateOfBirth$ => dateOfBirth.stream;
  Sink<DateTime> get indateOfBirth => dateOfBirth.sink;

  Stream<bool> get acceptedPolicies$ => acceptedPolicies.stream;
  Sink<bool> get inacceptedPolicies => acceptedPolicies.sink;

  Stream<bool> get isAllFilled$ => CombineLatestStream([lastName$, firstName$, email$, acceptedPolicies$, adress$ ,  dateOfBirth$], (values) => true).asBroadcastStream();


  SignupInformations validate() {
    DateOfBirth birthDate = DateOfBirth(
      day: this.dateOfBirth.value.day, 
      month: this.dateOfBirth.value.month, 
      year: this.dateOfBirth.value.year, 
      iso: this.dateOfBirth.value.toIso8601String()
    );
    return SignupInformations(
      adress: this.adress.value, 
      email: this.email.value, 
      firstName: this.firstName.value, 
      lastName: this.lastName.value, 
      policiesAcccepted: this.acceptedPolicies.value, 
      birthDate: birthDate
    );
  }

  

}