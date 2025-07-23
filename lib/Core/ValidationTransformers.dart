import 'dart:async';
import 'package:kookers/Services/DatabaseProvider.dart';

class ValidationTransformers {
  static bool isNotEmpty(String text) => text.isNotEmpty;
  
  static bool isEmailValid(String email) => 
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);

  static bool isValidPhoneNumber(String string) {
    if (string.isEmpty) {
      return false;
    }
    String pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(string);
  }

  static StreamTransformer<String, String> createStringValidator({
    required String errorMessage,
    bool Function(String)? customValidator,
  }) {
    return StreamTransformer<String, String>.fromHandlers(
      handleData: (value, sink) {
        if (customValidator?.call(value) ?? value.isNotEmpty) {
          sink.add(value);
        } else {
          sink.addError(errorMessage);
        }
      }
    );
  }

  static StreamTransformer<bool, bool> createBoolValidator({
    required String errorMessage,
    bool expectedValue = true,
  }) {
    return StreamTransformer<bool, bool>.fromHandlers(
      handleData: (value, sink) {
        if (value == expectedValue) {
          sink.add(value);
        } else {
          sink.addError(errorMessage);
        }
      }
    );
  }

  static StreamTransformer<T, T> createGenericValidator<T>({
    required String errorMessage,
    required bool Function(T) validator,
  }) {
    return StreamTransformer<T, T>.fromHandlers(
      handleData: (value, sink) {
        if (validator(value)) {
          sink.add(value);
        } else {
          sink.addError(errorMessage);
        }
      }
    );
  }

  // Specific validators
  static final validateFirstName = createStringValidator(
    errorMessage: "Veuillez renseigner votre prénom"
  );

  static final validateLastName = createStringValidator(
    errorMessage: "Veuillez renseigner votre nom"
  );

  static final validateEmail = createStringValidator(
    errorMessage: "Veuillez renseigner votre email",
    customValidator: isEmailValid,
  );

  static final validatePhoneNumber = createStringValidator(
    errorMessage: "Veuillez renseigner votre numéro de téléphone",
    customValidator: isValidPhoneNumber,
  );

  static final phoneIsFilled = createStringValidator(
    errorMessage: "Le champs téléphone doit etre remplie"
  );

  static final validatePoliciesAccepted = createBoolValidator(
    errorMessage: "Veuillez accepter nos politiques pour continuer"
  );

  static final validateAdress = createGenericValidator<Adress>(
    errorMessage: "Veuillez renseigner votre adresse",
    validator: (address) => address.title?.isNotEmpty ?? false,
  );

  static final validatebirthDate = createGenericValidator<DateTime>(
    errorMessage: "Veuillez renseigner votre date de naissance",
    validator: (date) => true, // Always valid if not null
  );

  static final policiesAccepted = createBoolValidator(
    errorMessage: "Veuillez accepter cette politique pour continuer"
  );

  static final policiesAccepted1 = createBoolValidator(
    errorMessage: "Veuillez accepter cette politique pour continuer"
  );

  static final policiesAccepted2 = createBoolValidator(
    errorMessage: "Veuillez accepter cette politique pour continuer"
  );

  static final validateIban = createStringValidator(
    errorMessage: "Veuillez renseigner un IBAN valide",
    customValidator: (iban) => iban.length >= 15, // Basic IBAN validation
  );
}