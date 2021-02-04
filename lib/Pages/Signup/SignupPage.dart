import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Blocs/SignupBloc.dart';
import 'package:kookers/Pages/Home/FoodIemChild.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupPage extends StatefulWidget {
  final User user;
  SignupPage({Key key, this.user}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool checkbox = false;
  String photoUrl = "https://zupimages.net/up/21/05/gyt7.png";
  Adress adress = Adress();
  String adressString = "";

  Future<UserDef> createUser(String uid, GraphQLClient client, String firstname, String lastName, String email, String phoneNumber, String notifToken, String photoUrl, Adress  adress, String currency, String country, DateOfBirth dateofbirth) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          mutation CreateAnUser($first_name: String!, $last_name: String!, $email: String!, $phonenumber: String!, $fcmToken: String!, $display_name: String!,
          $createdAt: String, $updatedAt: String, $photoUrl: String!, $firebaseUID: String!, $adresses: [AdressInput], $country: String!, $currency: String!, $birth_date: BirthDate!) {
            createUser(user: {first_name: $first_name, last_name: $last_name, email: $email, phonenumber: $phonenumber, fcmToken: $fcmToken, display_name: $display_name,
          createdAt: $createdAt, updatedAt: $updatedAt, photoUrl: $photoUrl, firebaseUID: $firebaseUID, adresses: $adresses, country: $country, currency: $currency, birth_date: $birth_date}){
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
        """),
        variables: <String, dynamic> {
          "first_name" : firstname,
          "last_name": lastName,
          "email": email,
          "phonenumber": phoneNumber,
          "fcmToken": notifToken,
          "display_name": firstname +  " "  + lastName,
          "createdAt": DateTime.now().toIso8601String(),
          "updatedAt": DateTime.now().toIso8601String(),
          "photoUrl": photoUrl,
          "firebaseUID": uid,
          "birth_date": dateofbirth.toJson(),
          "adresses": [{
              "title": adress.title,
              "is_chosed": true,
              "location": {
                "longitude": adress.location.longitude,
                "latitude": adress.location.latitude,
              },

            }
          ],
          "country": country,
          "currency": currency
        }
        );

    return client.mutate(_options).then((kooker) {
        final kookersUser = UserDef.fromJson(kooker.data["createUser"]);
        return kookersUser;
    });
  }

    final picker = ImagePicker();

  Future<File> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    return File(pickedFile.path);
  }

   StreamButtonController _streamButtonController = StreamButtonController();
   SignupBloc signupBloc = SignupBloc();

   @override
   void dispose() { 
     this.signupBloc.dispose();
     super.dispose();
   }

   final f = new DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    final phoneAuthBloc = Provider.of<PhoneAuthBloc>(context, listen: false);
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);

      return Scaffold(
        appBar: TopBarWitBackNav(
            title: "S'enregistrer",
            rightIcon: CupertinoIcons.exclamationmark_circle_fill,
            isRightIcon: false,
            height: 54,
            onTapRight: () {}),
        body: ListView(
            shrinkWrap: true,
            children: [Container(
            padding: const EdgeInsets.all(10),
            child: Column(children: [

              SizedBox(height: 10),
              Container(
                height: 130,
                width: 130,
                child: Stack(children: [
                  Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      radius: 60,
                      backgroundImage: Image(
                              image: CachedNetworkImageProvider(
                                  this.photoUrl))
                          .image,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 75,
                    child: InkWell(
                      onTap: () {
                        this.getImage().then((file){
                          storageService.uploadPictureFile(this.widget.user.uid, "profilePicture.png", file).then((url) {
                            setState(() {
                              this.photoUrl = url;
                            });
                          });
                        });
                      },
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 7.0, horizontal: 7),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 43, 84),
                              borderRadius: BorderRadius.circular(13.0)),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20.0,
                          )),
                    ),
                  )
                ]),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 15),

              StreamBuilder<String>(
                stream: signupBloc.lastName$,
                builder: (context, snapshot) {
                  return TextField(
                      onChanged: signupBloc.lastName.add,
                      decoration: InputDecoration(
                        errorText: snapshot.error,
                        contentPadding:
                            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          size: 20,
                        ),
                        hintText: "Nom",
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ));
                }
              ),
              SizedBox(height: 10),

              StreamBuilder<String>(
                stream: signupBloc.firstName$,
                builder: (context, snapshot) {
                  return TextField(
                    onChanged: signupBloc.firstName.add,
                      decoration: InputDecoration(
                        errorText: snapshot.error,
                        contentPadding:
                            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          size: 20,
                        ),
                        hintText: "Prénom",
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ));
                }
              ),
              SizedBox(height: 10),

              StreamBuilder<String>(
                stream: signupBloc.email$,
                builder: (context, snapshot) {
                  return TextField(
                      onChanged: signupBloc.email.add,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        errorText: snapshot.error,
                        contentPadding:
                            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        prefixIcon: Icon(
                          CupertinoIcons.mail,
                          size: 20,
                        ),
                        hintText: "Email",
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ));
                }
              ),
              SizedBox(height: 15),

              StreamBuilder<DateTime>(
                stream: signupBloc.dateOfBirth$,
                builder: (context, AsyncSnapshot<DateTime> snapshot) {
                  return ListTile(
                    onTap: () async {
                      DateTime date = await showCupertinoModalBottomSheet(
                        expand: false,
                        context: context,
                        builder: (context) => ChooseDatePage(datemode: CupertinoDatePickerMode.date),
                      );

                      signupBloc.dateOfBirth.add(date);
                    },
                    leading: Icon(CupertinoIcons.calendar),
                    title: Text("Date de naissance"),
                    trailing: snapshot.data != null ? Text(f.format(snapshot.data)) : Text("Choisir"),
                  );
                }),

                SizedBox(height: 15),

              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("VOTRE ADRESSE",
                      style: GoogleFonts.montserrat(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 15))),
              SizedBox(height: 10),

              StreamBuilder<Adress>(
                stream: signupBloc.adress$,
                builder: (context, AsyncSnapshot<Adress> snapshot) {
                  return ListTile(
                    onTap: () async  {
                       this.adress = await showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => HomeSearchPage(isReturn: true),
                        );

                        signupBloc.adress.add(this.adress);

                        setState(() {
                          this.adressString = this.adress.title;
                        });

                        
                      },
                    leading: Icon(CupertinoIcons.home),
                    title: snapshot.data == null ?  Text("Votre adresse") : Text(snapshot.data.title),
                    trailing: Icon(CupertinoIcons.chevron_down),
                  );
                }
              ),
              SizedBox(height: 10),

              Center(child: Text(
                    "Nous utilisons votre adresse pour vous connecter à des chefs ou à des potentiels clients autour de vous.",
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 10))),

              SizedBox(height: 20),

              ListTile(
                leading: StreamBuilder<bool>(
                  stream: signupBloc.acceptedPolicies$,
                  builder: (context, snapshot) {
                    return CircularCheckBox(
                        activeColor: Colors.green,
                        value: snapshot.data != null ? snapshot.data : signupBloc.acceptedPolicies.value,
                        onChanged: signupBloc.acceptedPolicies.add
                          
                          );
                  }
                ),
                    title: RichText(text: TextSpan(
                      text: 'En appuyant sur Créer un compte ou sur connexion, vous acceptez nos ',
                      style: GoogleFonts.montserrat(decoration: TextDecoration.none, color: Colors.black, fontSize: 12),
                      children: <TextSpan> [

                        TextSpan(text:"Conditions d'utilisation ",
                          style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch("urlString");
                            }
                          ),


                        TextSpan(
                          text: ", Pour en savoir plus sur l'utilisation de vos données, consultez notre ",
                          style: GoogleFonts.montserrat(decoration: TextDecoration.none, color: Colors.black, fontSize: 12),
                      ),

                      TextSpan(text:"Politique de confidentialité",
                          style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch("urlString");
                              // open desired screen
                            }
                          ),

                      ]

                    )
                  ),
              ),
              
              SizedBox(height: 40),


              StreamBuilder<bool>(
                stream: signupBloc.isAllFilled$,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  return StreamButton(buttonColor: snapshot.data != null && snapshot.data != false ? Colors.black : Colors.grey,
                                     buttonText: "Créer un compte",
                                     errorText: "Erreur de création de compte",
                                     loadingText: "Création en cours",
                                     successText: "Compte créé",
                                      controller: _streamButtonController, onClick: () async {
                                        if(snapshot.data != null && snapshot.data != false ) {
                                          _streamButtonController.isLoading();
                                          final notifID = await notificationService.notificationID();
                                          SignupInformations infos = signupBloc.validate();
                                          this.createUser(this.widget.user.uid, databaseService.client, infos.firstName, infos.lastName, infos.email, this.widget.user.phoneNumber, notifID, this.photoUrl, infos.adress, phoneAuthBloc.userCurrency.value, phoneAuthBloc.userCountry.value, infos.birthDate).then((kooker) async {
                                           databaseService.user.sink.add(kooker);
                                           await  _streamButtonController.isSuccess();
                                            Navigator.push(context,CupertinoPageRoute(
                                                                              builder: (context) =>
                                                                                  TabHome()));
                                          }).catchError((onError) async {
                                              await  _streamButtonController.isError();
                                          });

                                      }
                                      });
                }
              ),
              SizedBox(height: 30)
            ]),
          )],
        ),
      );
  }
}
