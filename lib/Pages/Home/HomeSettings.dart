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

class _HomeSettingsState extends State<HomeSettings> with AutomaticKeepAliveClientMixin<HomeSettings>  {
    @override
  bool get wantKeepAlive => true;

  List<String> tag = [];
  List<String> tagfood = [];

  List<String> options = ['\$', '\$\$', '\$\$\$', '\$\$\$\$'];

  List<String> foodpreferences = [
    'Végétarien',
    'Vegan',
    'Sans gluten',
    'Hallal',
    'Adapté aux allergies alimentaires',
    'Cacherout'
  ];


    List<String> pricRanges = [
    '\$',
    '\$\$',
    '\$\$\$',
    '\$\$\$\$',
  ];
  

  double _currentSliderValue = 20;

    Future<void> updateSettings(GraphQLClient client, String uid, UserSettings settings, DatabaseProviderService database) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
              mutation UpdateSettings($userID: String!, $settings: UserSettingsInput!) {
                  updateSettings(userID: $userID, settings: $settings){
              _id
              email
              first_name
              last_name
              phonenumber
              customerId
              country
              currency
              default_source
              default_iban
              stripe_account
              settings {
                  food_preferences
                  food_price_ranges
                  distance_from_seller
                  updatedAt
              }

              stripeAccount {
                charges_enabled
                payouts_enabled
                requirements {
                      currently_due
                      eventually_due
                      past_due
                      pending_verification
                      disabled_reason
                      current_deadline
                }
              }

              balance {
                current_balance
                pending_balance
                currency
              }

              transactions {
                    id
                    object
                    amount
                    available_on
                    created
                    currency
                    description
                    fee
                    net
                    reporting_category
                    type
                    status
              }

              all_cards {
                id
                brand
                country
                customer
                cvc_check
                exp_month
                exp_year
                fingerprint
                funding
                last4
              }

              ibans {
                    id
                    object
                    account_holder_name
                    account_holder_type
                    bank_name
                    country
                    currency
                    last4
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
    super.build(context);
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
      final firebaseUser = context.watch<User>();

      return StreamBuilder(
        stream: databaseService.user$,
        initialData: databaseService.user.value,
        builder: (context, AsyncSnapshot<UserDef> snapshot) {
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
                    spinnerColor: Color(0xFFF95F5F),
                    choiceStyle: C2ChoiceStyle(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    choiceActiveStyle: C2ChoiceStyle(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFFF95F5F)
                    ),
                    value: snapshot.data.settings.foodPriceRange,
                    onChanged: (val) => setState(() => snapshot.data.settings.foodPriceRange = val),
                    choiceItems: C2Choice.listFrom<String, String>(
                      source: this.pricRanges,
                      value: (i, v) => v,
                      label: (i, v) => v,
                    ),
                  ),
                ),
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
                  spinnerColor: Color(0xFFF95F5F),
                  choiceStyle: C2ChoiceStyle(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  choiceActiveStyle: C2ChoiceStyle(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFF95F5F)
                  ),
                  value: snapshot.data.settings.foodPreference,
                  onChanged: (val) => setState(() => snapshot.data.settings.foodPreference = val),
                  choiceItems: C2Choice.listFrom<String, String>(
                    source: this.foodpreferences,
                    value: (i, v) => v,
                    label: (i, v) => v,
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Vos préférences alimentaires nous sert à vous proposer uniquement des plats à votre goût.",
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
                            activeTrackColor: Color(0xFFF95F5F),
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
                        "Distance de recherche vous separant des potentiels chefs amteurs. Plus la distance est rappoché de votre domicile moins il vous faudra attendre pour deguster vos plats ou desserts.",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 10))),
                SizedBox(height: 60),
                InkWell(
                  onTap: () async {
                    this.updateSettings(databaseService.client, firebaseUser.uid, snapshot.data.settings, databaseService).then((value) async {
                      await databaseService.loadPublication();
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

  }
}
