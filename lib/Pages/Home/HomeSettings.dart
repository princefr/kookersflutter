import 'package:chips_choice/chips_choice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/KookersButton.dart';
import 'package:provider/provider.dart';



// ignore: must_be_immutable
class HomeSettings extends StatefulWidget {
  HomeSettings({Key key}) : super(key: key);

  @override
  _HomeSettingsState createState() => _HomeSettingsState();
}

class _HomeSettingsState extends State<HomeSettings> {
  List<String> tag = [];
  List<String> tagfood = [];

  List<String> options = ['\$', '\$\$', '\$\$\$', '\$\$\$\$'];

  List<String> foodpreferences = [
    'Végétarien',
    'Vegan',
    'Sans gluten',
    'Hallal',
    'Adapté aux allergies alimentaires'
  ];

  double _currentSliderValue = 20;

    Future<void> updateSettings(GraphQLClient client, String uid, UserSettings settings, DatabaseProviderService database) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
              mutation UpdateSettings($userID: String!, $settings: UserSettingsInput!) {
                  updateSettings(userID: $userID, settings: $settings){
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
          "settings": settings.toJson()
        });

        return client.mutate(_options).then((kooker) {
                  final kookersUser = UserDef.fromJson(kooker.data["updateSettings"]);
                  database.user.add(kookersUser);
      });
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    return GraphQLConsumer(builder: (GraphQLClient client) {
      final firebaseUser = context.read<User>();
      return StreamBuilder(
        stream: databaseService.user.stream,
        builder: (context, AsyncSnapshot<UserDef> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
          return Material(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: 7,
                      width: 80),
                ),
                SizedBox(height: 50),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("FOURCHETTE DE PRIX",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 15))),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ChipsChoice<String>.multiple(
                    value: snapshot.data.settings.foodPriceRange.where((element) => element.isSelected == true).map((e) => e.title).toList(),
                    onChanged: (val) {
                      setState(() {
                        return snapshot.data.settings.foodPriceRange.forEach((element) => val.contains(element.title) ? element.isSelected = true: element.isSelected = false);
                      });
                    },
                    choiceItems: C2Choice.listFrom<String, FoodPriceRange>(
                      source: snapshot.data.settings.foodPriceRange.toList(),
                      value: (i, v) => v.title,
                      label: (i, v) => v.title,
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 10))),
                SizedBox(height: 30),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("PRÉFÉRENCES ALIMENTAIRES",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 15))),
                SizedBox(height: 10),

                ChipsChoice<String>.multiple(
                  spinnerColor: Colors.red,
                  value: snapshot.data.settings.foodPreference.where((element) => element.isSelected == true).map((e) => e.title).toList(),
                  onChanged: (val) {
                      setState(() {
                        return snapshot.data.settings.foodPreference.forEach((element) => val.contains(element.title) ? element.isSelected = true: element.isSelected = false);
                      });
                  },
                  choiceItems: C2Choice.listFrom<String, FoodPreference>(
                    source: snapshot.data.settings.foodPreference.toList(),
                    value: (i, v) => v.title,
                    label: (i, v) => v.title,
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 10))),
                SizedBox(height: 30),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("DISTANCE",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 15))),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                          child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.red[700],
                            inactiveTrackColor: Colors.red[100],
                            trackShape: RectangularSliderTrackShape(),
                            trackHeight: 4.0,
                            thumbColor: Colors.redAccent,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                            overlayColor: Colors.red.withAlpha(32),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                          ),
                          child: Slider(
                            value: snapshot.data.settings.distanceFromSeller.round().toDouble(),
                            min: 0,
                            max: 45,
                            label: _currentSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                snapshot.data.settings.distanceFromSeller = value.round().toInt();
                              });
                            },
                          )),
                    ),

                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(snapshot.data.settings.distanceFromSeller.round().toInt().toString(), style: GoogleFonts.montserrat(fontSize:20),),
                        )
                  ],
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 10))),
                SizedBox(height: 60),
                InkWell(
                  onTap: () async {
                    this.updateSettings(client, firebaseUser.uid, snapshot.data.settings, databaseService).then((value) {
                      databaseService.loadPublication();
                      Navigator.pop(context);
                    });
                  },
                  child: KookersButton(
                      text: "Sauvegarder",
                      color: Color(0xFFF95F5F),
                      textcolor: Colors.white),
                )
              ]),
            ),
          );
        }
      );
    });
  }
}
