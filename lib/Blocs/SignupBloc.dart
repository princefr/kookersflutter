import 'package:flutter/material.dart';
import 'package:kookers/Mixins/SignupValidation.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:rxdart/rxdart.dart';


class SignupInformations {
  String firstName;
  String lastName;
  String email;
  Adress adress;
  bool policiesAcccepted;

  SignupInformations({@required this.adress, @required this.email, @required this.firstName, @required this.lastName, @required this.policiesAcccepted});


}



class SignupBloc with SignupValidation {
    // ignore: close_sinks
  BehaviorSubject<String> lastName = new BehaviorSubject<String>();
  Stream<String> get lastName$ => lastName.stream.transform(validateLastName);
  Sink<String> get inlastName => lastName.sink;

    // ignore: close_sinks
  BehaviorSubject<String> firstName = new BehaviorSubject<String>();
  Stream<String> get firstName$ => firstName.stream.transform(validateFirstName);
  Sink<String> get infirstName => firstName.sink;

      // ignore: close_sinks
  BehaviorSubject<String> email = new BehaviorSubject<String>();
  Stream<String> get email$ => email.stream.transform(validateEmail);
  Sink<String> get inemail => email.sink;

        // ignore: close_sinks
  BehaviorSubject<Adress> adress = new BehaviorSubject<Adress>();
  Stream<Adress> get adress$ => adress.stream.transform(validateAdress);
  Sink<Adress> get inadress => adress.sink;

// ignore: close_sinks
  BehaviorSubject<bool> acceptedPolicies = new BehaviorSubject<bool>.seeded(false);
  Stream<bool> get acceptedPolicies$ => acceptedPolicies.stream.transform(validatePoliciesAccepted);
  Sink<bool> get inacceptedPolicies => acceptedPolicies.sink;

  Stream<bool> get isAllFilled$ => CombineLatestStream([lastName$, firstName$, email$, acceptedPolicies$, adress$], (values) => true);


  SignupInformations validate() {
    return SignupInformations(adress: this.adress.value, email: this.email.value, firstName: this.firstName.value, lastName: this.lastName.value, policiesAcccepted: this.acceptedPolicies.value);
  }

  

}