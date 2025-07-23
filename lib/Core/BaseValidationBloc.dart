import 'dart:async';
import 'package:rxdart/rxdart.dart';

abstract class BaseValidationBloc {
  void dispose();
}

class ValidationField<T> {
  final BehaviorSubject<T> _subject;
  final StreamTransformer<T, T> _validator;
  
  ValidationField(this._validator, [T? seedValue]) 
    : _subject = seedValue != null 
        ? BehaviorSubject<T>.seeded(seedValue) 
        : BehaviorSubject<T>();

  Stream<T> get stream => _subject.stream.transform(_validator);
  Sink<T> get sink => _subject.sink;
  T get value => _subject.value;
  
  void dispose() {
    _subject.close();
  }
}

class ValidationFieldSimple<T> {
  final BehaviorSubject<T> _subject;
  
  ValidationFieldSimple([T? seedValue]) 
    : _subject = seedValue != null 
        ? BehaviorSubject<T>.seeded(seedValue) 
        : BehaviorSubject<T>();

  Stream<T> get stream => _subject.stream;
  Sink<T> get sink => _subject.sink;
  T get value => _subject.value;
  
  void dispose() {
    _subject.close();
  }
}

mixin ValidationBlocMixin implements BaseValidationBloc {
  final List<ValidationField> _validationFields = [];
  final List<ValidationFieldSimple> _simpleFields = [];

  ValidationField<T> createValidationField<T>(
    StreamTransformer<T, T> validator, [T? seedValue]
  ) {
    final field = ValidationField<T>(validator, seedValue);
    _validationFields.add(field);
    return field;
  }

  ValidationFieldSimple<T> createSimpleField<T>([T? seedValue]) {
    final field = ValidationFieldSimple<T>(seedValue);
    _simpleFields.add(field);
    return field;
  }

  @override
  void dispose() {
    for (final field in _validationFields) {
      field.dispose();
    }
    for (final field in _simpleFields) {
      field.dispose();
    }
    _validationFields.clear();
    _simpleFields.clear();
  }
}