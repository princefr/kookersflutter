
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kookers/Models/Location.dart' as models;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Services/DatabaseProvider.dart' as db;
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HomeSearchPage extends StatefulWidget {
  db.Adress? adress;
  bool isReturn;
  final User user;
  HomeSearchPage({Key? key, this.adress, required this.isReturn, required this.user})
      : super(key: key);

  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage>
    with AutomaticKeepAliveClientMixin<HomeSearchPage> {
  @override
  bool get wantKeepAlive => true;

  
  TextEditingController textController = TextEditingController();

  

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> updateUserAdresses(GraphQLClient client, String uid,
      List<db.Adress> adresses, DatabaseProviderService database) async {
    final MutationOptions _options = MutationOptions(document: gql(r"""
              mutation UpdateUserAdresses($userID: String!, $adresses: [AdressInput]!) {
                updateUserAdresses(userID: $userID, adresses: $adresses){
              _id
              email
              first_name
              last_name
              is_seller
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
                  }
              }
          """), variables: <String, dynamic>{
      "userID": uid,
      "adresses": db.Adress.toJson(adresses)
    });

    return client.mutate(_options).then((kooker) {
      final kookersUser = UserDef.fromJson(kooker.data?["updateUserAdresses"]);
      database.user.add(kookersUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);


    return Scaffold(
      appBar: TopBarBackCross(height: 54, title: "Choisir une adresse"),
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
                  key: Key("search_text"),
                  controller: textController,
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      try {
                        List<Location> locations = await locationFromAddress(value);
                        if (locations.isNotEmpty) {
                          final c = db.Adress(
                              isChosed: true,
                              location: models.Location(
                                  latitude: locations.first.latitude,
                                  longitude: locations.first.longitude),
                              title: value);
                          setState(() {
                            this.widget.adress = c;
                            if (this.widget.isReturn == false) {
                              databaseService.user.value.adresses
                                  .forEach((e) => e.isChosed = false);
                              databaseService.user.value.adresses.add(c);
                              textController.text = "";
                              this
                                  .updateUserAdresses(
                                      databaseService.client,
                                      this.widget.user.uid,
                                      databaseService.user.value.adresses,
                                      databaseService)
                                  .then((value) {
                                databaseService
                                    .loadPublication(
                                        databaseService.user.value.adresses
                                            .firstWhere(
                                                (element) => element.isChosed == true)
                                            .location,
                                        databaseService.user.value.settings
                                            .distanceFromSeller)
                                    .then((value) => Navigator.pop(context));
                              });
                            } else {
                              textController.text = "";
                              Navigator.pop(context, c);
                            }
                          });
                        }
                      } catch (e) {
                        print(e);
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
              if (this.textController.text.isEmpty) 
                Expanded(
                  child: StreamBuilder(
                      stream: databaseService.user$,
                      initialData: databaseService.user.value,
                      builder: (context, AsyncSnapshot<UserDef> snapshot) {
                        if (snapshot.data == null) return SizedBox();
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.adresses?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  autofocus: false,
                                  onTap: () {
                                    setState(() {
                                      databaseService.user.value.adresses
                                          .forEach((e) => e.isChosed = false);
                                      snapshot.data?.adresses?[index].isChosed =
                                          true;
                                      this
                                          .updateUserAdresses(
                                              databaseService.client,
                                              this.widget.user.uid,
                                              databaseService
                                                  .user.value.adresses,
                                              databaseService)
                                          .then((value) {
                                        databaseService
                                            .loadPublication(
                                                databaseService
                                                    .user.value.adresses
                                                    .firstWhere((element) =>
                                                        element.isChosed == true)
                                                    .location,
                                                databaseService
                                                    .user.value.settings
                                                    .distanceFromSeller)
                                            .then((value) =>
                                                Navigator.pop(context));
                                      });
                                    });
                                  },
                                  title: Text(
                                      snapshot.data?.adresses?[index].title ?? ''),
                                  trailing: Checkbox(
                                      activeColor: Colors.green,
                                      value: snapshot
                                          .data?.adresses?[index].isChosed ?? false,
                                      onChanged: (bool? x) {
                                        setState(() {
                                          snapshot.data?.adresses?[index].isChosed =
                                              x ?? false;
                                        });
                                      })
                              );
                            });
                      })
                ),
            ],
          ),
        ),
      );
  }
}
