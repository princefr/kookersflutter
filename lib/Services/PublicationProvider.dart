
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
  List<FoodPreference> foodPreferences;
  Adress adress;
  String name;
  String description;
  String pricePerPerson;
  String pricePerportion;
  String sellerId;
  String geohash;

  Publication({@required this.photoUrls, @required this.type, @required this.foodPreferences, @required this.adress, @required this.name, @required this.description, @required this.pricePerPerson, @required this.pricePerportion, @required this.sellerId, @required this.geohash});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["title"] = this.name;
    data["description"] = this.description;
    data["type"] = "PLATES";
    data["food_preferences"] = this.foodPreferences.map((e) => {"id": e.id, "title": e.title, "is_selected": e.isSelected}).toList();
    data["price_all"] = this.pricePerPerson;
    data["price_per_pie"] = this.pricePerportion;
    data["adress"] = this.adress.toJSON();
    data["sellerId"] = this.sellerId;
    data["geohash"] = this.geohash;
    data["photoUrls"]=  this.photoUrls;
    return data;
  }

}


class PublicationProvider with PublicationValidation {
  List<FoodPreference> prefs = [
    FoodPreference(id: 0, isSelected: false, title: "Végétarien"),
    FoodPreference(id: 1, isSelected: false, title: "Vegan"),
    FoodPreference(id: 2, isSelected: false, title: "Sans gluten"),
    FoodPreference(id: 3, isSelected: false, title: "Hallal"),
    FoodPreference(
        id: 4, isSelected: false, title: "Adapté aux allergies alimentaires")
  ];

  // ignore: close_sinks
  BehaviorSubject<List<FoodPreference>> pricePrefs =
    new BehaviorSubject<List<FoodPreference>>();
      
  // ignore: close_sinks
  BehaviorSubject<File> file0 = new BehaviorSubject<File>();
  
  // ignore: close_sinks
  BehaviorSubject<File> file1 = new BehaviorSubject<File>();
  // ignore: close_sinks
  BehaviorSubject<File> file2 = new BehaviorSubject<File>();


  // ignore: close_sinks
  final name = new BehaviorSubject<String>();
  Stream<String> get name$ => name.stream.transform(validateName).asBroadcastStream();
  Sink<String> get inName => name.sink;

  // ignore: close_sinks
  final  description = new BehaviorSubject<String>();
  Stream<String> get description$ => description.stream.transform(validateDescription).asBroadcastStream();
  Sink<String> get inDescription => description.sink;


  // ignore: close_sinks
  final priceall = new BehaviorSubject<String>();
  Stream<String> get priceall$ => priceall.stream.transform(validatePrice).asBroadcastStream();
  Sink<String> get inPriceall => priceall.sink;

  // ignore: close_sinks
  final priceaPerPortion = new BehaviorSubject<String>();
  Stream<String> get priceaPerPortion$ => priceaPerPortion.stream.transform(validatePricePerPortion).asBroadcastStream();
  Sink<String> get inPriceaPerPortion => priceaPerPortion.sink;

  PublicationProvider(){
    this.pricePrefs.add(this.prefs);
  }


  Stream<bool> get isAllPictureFilled$ => CombineLatestStream([file0.stream, file1.stream, file2.stream], (values) => true).asBroadcastStream();
  Stream<bool> get isFormValidOne$ => CombineLatestStream([name$, description$, priceall$, isAllPictureFilled$], (values) => true).asBroadcastStream();
  //Stream<bool> get isFormValidTwo$ => CombineLatestStream([name$, description$, priceall$, priceaPerPortion$, isAllPictureFilled$], (values) => true).asBroadcastStream();
  

  Future<Publication> validate(User user, StorageService storage, DatabaseProviderService database, SettingType type) async {
    GeoHasher geoHasher = GeoHasher();
    final url1 = await storage.uploadPictureFile(user.uid, uuid.v1() + ".png", this.file0.value).catchError((onError) => print);
    final url2 = await storage.uploadPictureFile(user.uid, uuid.v1() + ".png", this.file1.value).catchError((onError) => print);
    final url3 = await storage.uploadPictureFile(user.uid, uuid.v1() + ".png", this.file2.value).catchError((onError) => print);
    final photosUrls = [url1, url2, url3];
    Adress adress = database.user.value.adresses.firstWhere((element) => element.isChosed == true);
    String geohash = geoHasher.encode(adress.location.longitude, adress.location.latitude);
    Publication publication = Publication(photoUrls : photosUrls, type: type, foodPreferences : pricePrefs.value, adress: adress, name: this.name.value, description : this.description.value, pricePerPerson : this.priceall.value, pricePerportion : "15", sellerId: database.user.value.id, geohash: geohash);
    return publication;

  }

  }