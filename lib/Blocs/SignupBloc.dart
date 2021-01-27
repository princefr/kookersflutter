import 'package:flutter/material.dart';
import 'package:kookers/Mixins/SignupValidation.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:rxdart/rxdart.dart';



class DateOfBirth {
  String iso;
  int day;
  int month;
  int year;

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
  DateOfBirth birthDate;
  

  SignupInformations({@required this.adress, @required this.email, @required this.firstName, @required this.lastName, @required this.policiesAcccepted, this.birthDate});


}



class SignupBloc with SignupValidation {

  SignupBloc();


  void dispose(){
    this.lastName.close();
    this.firstName.close();
    this.email.close();
    this.adress.close();
    this.dateOfBirth.close();
    this.acceptedPolicies.close();
  }

  BehaviorSubject<String> lastName = new BehaviorSubject<String>();
  Stream<String> get lastName$ => lastName.stream.transform(validateLastName);
  Sink<String> get inlastName => lastName.sink;


  BehaviorSubject<String> firstName = new BehaviorSubject<String>();
  Stream<String> get firstName$ => firstName.stream.transform(validateFirstName);
  Sink<String> get infirstName => firstName.sink;


  BehaviorSubject<String> email = new BehaviorSubject<String>();
  Stream<String> get email$ => email.stream.transform(validateEmail);
  Sink<String> get inemail => email.sink;


  BehaviorSubject<Adress> adress = new BehaviorSubject<Adress>();
  Stream<Adress> get adress$ => adress.stream.transform(validateAdress);
  Sink<Adress> get inadress => adress.sink;


  BehaviorSubject<DateTime> dateOfBirth = new BehaviorSubject<DateTime>();
  Stream<DateTime> get dateOfBirth$ => dateOfBirth.stream.transform(validatebirthDate);
  Sink<DateTime> get indateOfBirth => dateOfBirth.sink;


  BehaviorSubject<bool> acceptedPolicies = new BehaviorSubject<bool>.seeded(false);
  Stream<bool> get acceptedPolicies$ => acceptedPolicies.stream.transform(validatePoliciesAccepted);
  Sink<bool> get inacceptedPolicies => acceptedPolicies.sink;

  Stream<bool> get isAllFilled$ => CombineLatestStream([lastName$, firstName$, email$, acceptedPolicies$, adress$ ,  dateOfBirth$], (values) => true);


  SignupInformations validate() {
    DateOfBirth birthDate = DateOfBirth(day: this.dateOfBirth.value.day, month: this.dateOfBirth.value.month, year: this.dateOfBirth.value.year, iso: this.dateOfBirth.value.toIso8601String());
    return SignupInformations(adress: this.adress.value, email: this.email.value, firstName: this.firstName.value, lastName: this.lastName.value, policiesAcccepted: this.acceptedPolicies.value, birthDate: birthDate);
  }

  

}