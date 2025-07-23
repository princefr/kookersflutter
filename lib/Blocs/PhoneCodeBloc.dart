
import 'package:kookers/Core/BaseValidationBloc.dart';

class PhoneCodeBloc with ValidationBlocMixin {
  late final ValidationFieldSimple<String> code;

  PhoneCodeBloc() {
    code = createSimpleField<String>();
  }

  // Getters for compatibility
  Stream<String> get code$ => code.stream;
  Sink<String> get inCode => code.sink;

  String validate() {
    return this.code.value;
  }

  
}