import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kookers/Models/Location.dart' as models;
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:kookers/Services/DatabaseProvider.dart' as db;

class BeforeAdress extends StatefulWidget {
  final bool isReturn;
  BeforeAdress({Key? key, required this.isReturn}) : super(key: key);

  @override
  _BeforeAdressState createState() => _BeforeAdressState();
}

class _BeforeAdressState extends State<BeforeAdress>
    with AutomaticKeepAliveClientMixin<BeforeAdress> {
  @override
  bool get wantKeepAlive => true;

  

  TextEditingController textController = TextEditingController();

  

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
                child: Column(
                  children: [
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: "Enter address",
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (textController.text.isNotEmpty) {
                          try {
                            List<Location> locations = await locationFromAddress(textController.text);
                            if (locations.isNotEmpty) {
                              final c = db.Adress(
                                isChosed: true,
                                location: models.Location(
                                  latitude: locations.first.latitude,
                                  longitude: locations.first.longitude,
                                ),
                                title: textController.text,
                              );
                              databaseService.adress.add(c);
                              databaseService.user.add(db.UserDef());
                              if (this.widget.isReturn) {
                                databaseService
                                            .loadPublication(
                                                c.location!,
                                                45);
                                Navigator.pop(context);
                              } else {
                                Get.to(TabHome());
                              }
                            }
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                      child: Text("Search"),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      );
  }
}
