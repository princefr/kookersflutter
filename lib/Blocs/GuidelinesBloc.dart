





import 'package:kookers/Mixins/GuideLinesValidation.dart';
import 'package:rxdart/rxdart.dart';

class GuidelineBloc with GuidelinesValidation {


  GuidelineBloc();



  void dispose() {
    this.acceptMask.close();
    this.acceptGloves.close();
    this.acceptBeenVerified.close();
  }
  


  BehaviorSubject<bool> acceptMask = new BehaviorSubject<bool>.seeded(false);
  Stream<bool> get acceptMask$ => acceptMask.stream.transform(policiesAccepted);
  Sink<bool> get inacceptMask => acceptMask.sink;


  BehaviorSubject<bool> acceptGloves = new BehaviorSubject<bool>.seeded(false);
  Stream<bool> get acceptGloves$ => acceptGloves.stream.transform(policiesAccepted1);
  Sink<bool> get inacceptGloves => acceptGloves.sink;



  BehaviorSubject<bool> acceptBeenVerified = new BehaviorSubject<bool>.seeded(false);
  Stream<bool> get acceptBeenVerified$ => acceptBeenVerified.stream.transform(policiesAccepted2);
  Sink<bool> get inacceptBeenVerified => acceptBeenVerified.sink;



  Stream<bool> get isAllFilled$ => CombineLatestStream([acceptMask$, acceptGloves$, acceptBeenVerified$], (values) => values.every((element) => element == true));

}