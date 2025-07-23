import 'package:kookers/Core/BaseValidationBloc.dart';
import 'package:kookers/Core/ValidationTransformers.dart';

class IbanBloc with ValidationBlocMixin {
  late final ValidationField<String> iban;

  IbanBloc() {
    iban = createValidationField(ValidationTransformers.validateIban);
  }

  // Getters for compatibility
  Stream<String> get iban$ => iban.stream;
  Sink<String> get inBan => iban.sink;

  String validate() {
    return this.iban.value;
  }

  
}