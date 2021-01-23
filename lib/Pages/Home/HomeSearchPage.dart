import 'package:circular_check_box/circular_check_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Services/DatabaseProvider.dart' as db;
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HomeSearchPage extends StatefulWidget {
   db.Adress adress;
   bool isReturn;
  HomeSearchPage({Key key, this.adress, @required this.isReturn}) : super(key: key);

  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  DetailsResult detailresult;
  TextEditingController textController = TextEditingController();

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions;
      });
    }
  }

  @override
  void initState() {
    
    googlePlace = GooglePlace("AIzaSyAbJoAWoANYPFagvaiNOAd8vJZGY7SV0Hs");
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }


    Future<void> updateUserAdresses(GraphQLClient client, String uid, List<db.Adress> adresses, DatabaseProviderService database) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
              mutation UpdateUserAdresses($userID: String!, $adresses: [AdressInput]!) {
                updateUserAdresses(userID: $userID, adresses: $adresses){
                _id
                firebaseUID
                email
                first_name
                last_name
                phonenumber
                settings {
                    food_preferences {id, title, is_selected}
                    food_price_ranges {id, title, is_selected}
                    distance_from_seller
                    updatedAt
                }

                createdAt
                photoUrl
                updatedAt
                adresses {title, location {latitude, longitude}, is_chosed}
                fcmToken
                rating {rating_total, rating_count}
                  }
              }
          """), variables: <String, dynamic>{
          "userID": uid,
          "adresses": db.Adress.toJson(adresses)
        });

        return client.mutate(_options).then((kooker) {
                  final kookersUser = UserDef.fromJson(kooker.data["updateUserAdresses"]);
                  database.user.add(kookersUser);
      });
  }





  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);

    return GraphQLConsumer(builder: (GraphQLClient client) {
      final firebaseUser = context.read<User>();
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 7,
                    width: 80),
              ),
              SizedBox(height: 30),
              Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: textController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                    } else {
                      if (predictions.length > 0 && mounted) {
                        setState(() {
                          predictions = [];
                        });
                      }
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Rechercher un lieu",
                    prefixIcon: Icon(CupertinoIcons.search),
                    fillColor: Colors.grey[300],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
              ),

              Divider(),

              Visibility(
                visible: (this.textController?.value?.text?.isNotEmpty),
                child: 
                  Expanded(
                  child: ListView.builder(
                    dragStartBehavior: DragStartBehavior.down,
                      itemCount: predictions.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          onTap: () async {
                            googlePlace.details.get(predictions[index].placeId).then((value) {
                              final c = db.Adress(isChosed: true, location: db.Location(latitude: value.result.geometry.location.lat, longitude: value.result.geometry.location.lng),  title: predictions[index].description);
                            setState(() {
                            this.widget.adress = c;
                            if(this.widget.isReturn == false) {
                               databaseService.user.value.adresses.forEach((e) => e.isChosed = false);
                               databaseService.user.value.adresses.add(c);
                               textController.text = "";
                               this.updateUserAdresses(client, firebaseUser.uid, databaseService.user.value.adresses, databaseService).then((value) {
                                 databaseService.loadPublication().then((value) => Navigator.pop(context));
                                 
                               });
                            }else{
                              textController.text = "";
                              Navigator.pop(context, c);
                            }
                            
                            });
                            });
                          },
                          leading: Icon(CupertinoIcons.location),
                          title: Text(predictions[index].description),
                        );
                      }))
              
              ),


              Visibility(
                visible: (this.textController?.value?.text?.isEmpty),
                child: Expanded(
                    child: StreamBuilder(
                    stream: databaseService.user.stream,
                    builder: (context, AsyncSnapshot<UserDef> snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.adresses.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: (){
                              setState(() {
                                snapshot.data.adresses.forEach((e) => e.isChosed = false);
                                snapshot.data.adresses[index].isChosed = true;
                                this.updateUserAdresses(client, firebaseUser.uid, databaseService.user.value.adresses, databaseService).then((value) {
                                  databaseService.loadPublication().then((value) => Navigator.pop(context));
                                  
                                });
                              });
                            },
                            trailing: CircularCheckBox(
                            activeColor: Colors.green,
                            tristate: true,
                            value: snapshot.data.adresses[index].isChosed,
                            onChanged: (bool x) {
                            }),
                            title: Text(snapshot.data.adresses[index].title)
                          );

                      });
                    }
                  ),
                ))


            ],
          ),
        ),
      );
    });
  }
}
