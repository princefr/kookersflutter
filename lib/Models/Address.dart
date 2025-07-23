import 'Location.dart';

class Adress {
  String? title;
  Location? location;
  bool? isChosed;
  static List<Adress>? allAdress;
  
  Adress({this.title, this.location, this.isChosed});

  static Adress fromJsonOne(Map<String, dynamic> map) => Adress(
    title: map['title'],
    location: Location(
      latitude: map["location"]["latitude"], 
      longitude: map["location"]["longitude"]
    ),
  );
  
  static List<Adress> fromJson(List<Object> map) {
    List<Adress> adresses = [];
  
    map.forEach((element) {
      final adress = element as Map<String, dynamic>;
      adresses.add(Adress(
        title: adress["title"],
        location: Location(
          latitude: adress["location"]["latitude"], 
          longitude: adress["location"]["longitude"]
        ),
        isChosed: adress["is_chosed"]
      ));
    });
    Adress.allAdress = adresses;
    return adresses;
  }

  Map<String, dynamic> toJSON() {
    final adress = Map<String, dynamic>();
    adress["title"] = this.title;
    adress["is_chosed"] = this.isChosed;
    adress["location"] = {
      "latitude": this.location?.latitude, 
      "longitude": this.location?.longitude
    };
    return adress;
  }

  void toogle() {
    this.isChosed = !(this.isChosed ?? false);
  }

  static List<Map<String, Object?>> toJson(List<Adress> allAdress) {
    return allAdress.map((e) => {
      "title": e.title, 
      "is_chosed": e.isChosed, 
      "location": {
        "longitude": e.location?.longitude, 
        "latitude": e.location?.latitude
      }
    }).toList();
  }
}