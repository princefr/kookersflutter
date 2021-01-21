import 'dart:async';

import 'package:kookers/Pages/PaymentMethods/CreditCardItem.dart';




mixin OrderValidation {
  static bool isNotZero(int quantity) => quantity > 0;
  static bool isFuture(DateTime date) => DateTime.now().add(Duration(hours: 3)).isBefore(date);

  final validateQuantity = StreamTransformer<int, int>.fromHandlers(handleData: (value, sink) {
      if(isNotZero(value)){
        sink.add(value);
      }else{
        sink.addError("error description must be filled");
      }
      
  });


  final validateDate = StreamTransformer<DateTime, DateTime>.fromHandlers(handleData: (value, sink) {
      if(isFuture(value)){
        sink.add(value);
      }else{
        sink.addError("error description must be filled");
      }
      
  });


  final validationPaymentMethod = StreamTransformer<List<CardModel>, List<CardModel>>.fromHandlers(handleData: (value, sink) {
      if(value.isNotEmpty){
        sink.add(value);
      }else{
        sink.addError("error description must be filled");
      }
  });
}