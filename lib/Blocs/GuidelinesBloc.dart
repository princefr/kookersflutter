



import 'package:kookers/Core/BaseValidationBloc.dart';
import 'package:kookers/Core/ValidationTransformers.dart';
import 'package:rxdart/rxdart.dart';

class GuidelineBloc with ValidationBlocMixin {
  late final ValidationField<bool> acceptMask;
  late final ValidationField<bool> acceptGloves;
  late final ValidationField<bool> acceptBeenVerified;

  GuidelineBloc() {
    acceptMask = createValidationField(ValidationTransformers.policiesAccepted, false);
    acceptGloves = createValidationField(ValidationTransformers.policiesAccepted1, false);
    acceptBeenVerified = createValidationField(ValidationTransformers.policiesAccepted2, false);
  }

  // Getters for compatibility
  Stream<bool> get acceptMask$ => acceptMask.stream;
  Sink<bool> get inacceptMask => acceptMask.sink;

  Stream<bool> get acceptGloves$ => acceptGloves.stream;
  Sink<bool> get inacceptGloves => acceptGloves.sink;

  Stream<bool> get acceptBeenVerified$ => acceptBeenVerified.stream;
  Sink<bool> get inacceptBeenVerified => acceptBeenVerified.sink;



  Stream<bool> get isAllFilled$ => CombineLatestStream([acceptMask$, acceptGloves$, acceptBeenVerified$], (values) => values.every((element) => element == true));

}