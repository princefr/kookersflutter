
import 'dart:io';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kookers/Mixins/PublicationValidation.dart';
import 'package:kookers/Pages/Home/HomePublish.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import "package:flutter/material.dart";

var uuid = Uuid();


class Publication {
  List<String> photoUrls;
  SettingType type;
  List<String> foodPreferences;
  Adress adress;
  String name;
  String description;
  String pricePerPerson;
  String sellerId;
  String geohash;
  String currency;

  Publication({@required this.photoUrls, @required this.type, @required this.foodPreferences, @required this.adress, @required this.name, @required this.description, @required this.pricePerPerson,  @required this.sellerId, @required this.geohash, @required this.currency});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["title"] = this.name;
    data["description"] = this.description;
    data["type"] = "PLATES";
    data["food_preferences"] = this.foodPreferences;
    data["price_all"] = this.pricePerPerson;
    data["adress"] = this.adress.toJSON();
    data["sellerId"] = this.sellerId;
    data["geohash"] = this.geohash;
    data["photoUrls"]=  this.photoUrls;
    data["currency"] = this.currency;
    return data;
  }

}


class PublicationProvider  with PublicationValidation {

  List<String> prefs = [
    'Végétarien',
    'Vegan',
    'Sans gluten',
    'Hallal',
    'Adapté aux allergies alimentaires',
    'Cacherout'
  ];



  void dispose() { 
    this.description.close();
    this.file0.close();
    this.file1.close();
    this.file2.close();
    this.name.close();
    this.priceall.close();
    this.pricePrefs.close();
  }


  BehaviorSubject<List<String>> pricePrefs =
    new BehaviorSubject<List<String>>();
      
  
  BehaviorSubject<File> file0 = new BehaviorSubject<File>();
  Stream<File> get file0$ => file0.stream;
  Sink<File> get infile0 => file0.sink;
  
  
  BehaviorSubject<File> file1 = new BehaviorSubject<File>();
  Stream<File> get file1$ => file1.stream;
  Sink<File> get infile1 => file1.sink;
  
  BehaviorSubject<File> file2 = new BehaviorSubject<File>();
    Stream<File> get file2$ => file2.stream;
  Sink<File> get infile2 => file2.sink;


  
  BehaviorSubject<String> name = new BehaviorSubject<String>();
  Stream<String> get name$ => name.stream.transform(validateName);
  Sink<String> get inName => name.sink;

  
  BehaviorSubject<String>  description = new BehaviorSubject<String>();
  Stream<String> get description$ => description.stream.transform(validateDescription);
  Sink<String> get inDescription => description.sink;


  
  BehaviorSubject<String> priceall = new BehaviorSubject<String>();
  Stream<String> get priceall$ => priceall.stream.transform(validatePrice);
  Sink<String> get inPriceall => priceall.sink;

  PublicationProvider(){
    this.pricePrefs.add([]);
  }

  Stream<bool> get isFormValidOne$ => Rx.combineLatest([name$, description$, priceall$, file0$, file1$, file2$], (values) => true).shareValueSeeded(null);
  

  Future<Publication> validate(User user, StorageService storage, DatabaseProviderService database, SettingType type) async {
    GeoHasher geoHasher = GeoHasher();
    final url1 = await storage.uploadPictureFile(user.uid, uuid.v1() + ".png", this.file0.value, "publicationImage", database.user.value.stripeaccountId).catchError((onError) => throw onError);
    final url2 = await storage.uploadPictureFile(user.uid, uuid.v1() + ".png", this.file1.value, "publicationImage", database.user.value.stripeaccountId).catchError((onError) => throw onError);
    final url3 = await storage.uploadPictureFile(user.uid, uuid.v1() + ".png", this.file2.value, "publicationImage", database.user.value.stripeaccountId).catchError((onError) => throw onError);
    final photosUrls = [url1, url2, url3];
    Adress adress = database.user.value.adresses.firstWhere((element) => element.isChosed == true);
    String geohash = geoHasher.encode(adress.location.longitude, adress.location.latitude);
    Publication publication = Publication(photoUrls : photosUrls, type: type, foodPreferences : pricePrefs.value, adress: adress,
     name: this.name.value, description : this.description.value, pricePerPerson : this.priceall.value,  sellerId: database.user.value.id, geohash: geohash, currency: database.user.value.currency);
    return publication;

  }

  }