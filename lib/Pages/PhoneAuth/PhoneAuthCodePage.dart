import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Signup/SignupPage.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/KookersButton.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';

class PhoneAuthCodePage extends StatefulWidget {
  final String verificationId;

  PhoneAuthCodePage({Key key, this.verificationId}) : super(key: key);

  @override
  _PhoneAuthCodePageState createState() => _PhoneAuthCodePageState();
}

class _PhoneAuthCodePageState extends State<PhoneAuthCodePage> {
  final myController = TextEditingController();

  Future<QueryResult> checkUserExist(String uid, GraphQLClient client) async {
    final QueryOptions _options = QueryOptions(documentNode: gql(r"""
          query GetIfUSerExist($uid: String!) {
              usersExist(firebase_uid: $uid){
                _id
                email
                first_name
                last_name
                phonenumber
                photoUrl
                adresses {title, location {latitude, longitude}, is_chosed}
                fcmToken
                rating {rating_total, rating_count}
                settings {
                  food_preferences
                  food_price_ranges
                  distance_from_seller
                  updatedAt
                }
              }
          }
      """), variables: <String, String>{
      "uid": uid,
    });

    return await client.query(_options);
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
    final authentificationService =
                        Provider.of<AuthentificationService>(context, listen: false);
    

      return Scaffold(
        appBar: TopBarWitBackNav(
            title: "Vérification code",
            rightIcon: CupertinoIcons.exclamationmark_circle_fill,
            isRightIcon: false,
            height: 54,
            onTapRight: () {}),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
            child: Column(children: <Widget>[
              Text(
                  "Veuillez renseigner ci dessous le code reçu sur votre numéro de téléphone renseigné à la page précédente.",
                  style: GoogleFonts.montserrat(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5),
              SizedBox(height: 15),
              Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey),
                  child: TextField(
                      controller: myController,
                      decoration: InputDecoration(
                        hintText: 'Renseignez votre code',
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      )),
                ),
              ),
              
              // Padding(
              //   padding: const EdgeInsets.only(top: 20),
              //   child: RichText(
              //     text: TextSpan(
              //         text: "Code non recu? renvoyez le!",
              //         style: TextStyle(color: Colors.red)),
              //   ),
              // ),

              Expanded(
                child: SizedBox(),
              ),
              TextButton(
                  onPressed: () {
                    authentificationService
                        .signInWithVerificationID(
                            widget.verificationId, myController.text)
                        .then((connected) => {
                              this
                                  .checkUserExist(connected.user.uid, databaseService.client)
                                  .then((user){

                                      if(user.data != null){
                                        if (user.data["usersExist"] == null)
                                          {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        SignupPage(
                                                            user: connected
                                                                .user)));
                                          }
                                        else
                                          {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        TabHome()));
                                          }
                                      }else{
                                        print("arf");
                                      }
                                    
                                      
                                      }).catchError((onError) {
                                        print(onError);
                                      })
                            });
                  },
                  child: KookersButton(
                      text: "Verifier le code",
                      color: Colors.black,
                      textcolor: Colors.white)),
            ]),
          ),
        ),
      );
  }
}
