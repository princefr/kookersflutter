import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:kookers/Services/DatabaseProvider.dart' as db;

class BeforeAdress extends StatefulWidget {
  final bool isReturn;
  BeforeAdress({Key key, @required this.isReturn}) : super(key: key);

  @override
  _BeforeAdressState createState() => _BeforeAdressState();
}

class _BeforeAdressState extends State<BeforeAdress>
    with AutomaticKeepAliveClientMixin<BeforeAdress> {
  @override
  bool get wantKeepAlive => true;

  GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  TextEditingController textController = TextEditingController();

  void autoCompleteSearch(String value) async {
    return Future.delayed(Duration(milliseconds: 700), () async {
    var result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null && mounted) {
        setState(() {
          predictions = result.predictions;
        });
      }
    });
  }

  @override
  void initState() {
    googlePlace = GooglePlace("AIzaSyDMv0rYwxFoTb2dZA73i_Bz1xIEy4jeUNw");
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);


    return Scaffold(
        appBar: TopBarBackCross(height: 54, title:"Choisir une adresse"),
        body: SafeArea(
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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

                Expanded(
                child: ListView.builder(
                    dragStartBehavior: DragStartBehavior.down,
                    itemCount: predictions.length,
                    itemBuilder: (ctx, index) {
                      return ListTile(
                        autofocus: false,
                        onTap: () async {
                          googlePlace.details.get(predictions[index].placeId).then((value) {
                            final c = db.Adress(isChosed: true, location: db.Location(latitude: value.result.geometry.location.lat, longitude: value.result.geometry.location.lng),  title: predictions[index].description);
                            databaseService.adress.add(c);
                            databaseService.user.add(null);
                            if(this.widget.isReturn) {
                                  databaseService
                                            .loadPublication(
                                                c.location,
                                                45);
                                  Navigator.pop(context);
                            }else{
                              Get.to(TabHome());
                            }
                            
                          });
                        },
                        leading: Icon(CupertinoIcons.location),
                        title: Text(predictions[index].description),
                      );
                    })),
              ],
            ),
          ),
        ),
      );
  }
}
