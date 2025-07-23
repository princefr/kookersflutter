import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Blocs/SignupBloc.dart';
import 'package:kookers/Pages/Home/FoodIemChild.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Pages/Notifications/NotificationPage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:kookers/Widgets/WebView.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  final User user;
  SignupPage({Key? key, required this.user}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool checkbox = false;
  String photoUrl = "https://zupimages.net/up/21/05/gyt7.png";
  Adress adress = Adress();
  String adressString = "";

  Future<UserDef> createUser(
      String uid,
      GraphQLClient client,
      String firstname,
      String lastName,
      String email,
      String phoneNumber,
      String notifToken,
      String photoUrl,
      Adress adress,
      String currency,
      String country,
      DateOfBirth dateofbirth) async {
    final MutationOptions _options = MutationOptions(document: gql(r"""
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
              is_seller
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
      "first_name": firstname,
      "last_name": lastName,
      "email": email,
      "phonenumber": phoneNumber,
      "fcmToken": notifToken,
      "display_name": firstname + " " + lastName,
      "createdAt": DateTime.now().toIso8601String(),
      "updatedAt": DateTime.now().toIso8601String(),
      "photoUrl": photoUrl,
      "firebaseUID": uid,
      "birth_date": dateofbirth.toJson(),
      "adresses": [
        {
          "title": adress.title,
          "is_chosed": true,
          "location": {
            "longitude": adress.location?.longitude,
            "latitude": adress.location?.latitude,
          },
        }
      ],
      "country": country,
      "currency": currency
    });

    return client.mutate(_options).then((kooker) {
      final kookersUser = UserDef.fromJson(kooker.data["createUser"]);
      return kookersUser;
    });
  }

  final picker = ImagePicker();

  Future<File?> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
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
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    final phoneAuthBloc = Provider.of<PhoneAuthBloc>(context, listen: false);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    return Scaffold(
      appBar: TopBarWitBackNav(
          title: "S'enregistrer",
          rightIcon: CupertinoIcons.exclamationmark_circle_fill,
          isRightIcon: false,
          height: 54,
          onTapRight: () {}),
      body: ListView(
        key: Key("signupList"),
        shrinkWrap: true,
        children: [
          Container(
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
                              image: CachedNetworkImageProvider(this.photoUrl))
                          .image,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 75,
                    child: InkWell(
                      onTap: () {
                        this.getImage().then((file) async {
                          File _file = await FlutterNativeImage.compressImage(
                              file.path,
                              quality: 35);
                          storageService
                              .uploadPictureFile(this.widget.user.uid,
                                  "photoUrl", _file, "profilImage")
                              .then((url) {
                            setState(() {
                              this.photoUrl = url;
                            });
                          });
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 7),
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
                      key: Key("last_name_textfield"),
                        onChanged: signupBloc.lastName.sink.add,
                        decoration: InputDecoration(
                          errorText: snapshot.error as String?,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
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
                  }),
              SizedBox(height: 10),
              StreamBuilder<String>(
                  stream: signupBloc.firstName$,
                  builder: (context, snapshot) {
                    return TextField(
                        key: Key("first_name_textfield"),
                        onChanged: signupBloc.firstName.sink.add,
                        decoration: InputDecoration(
                          errorText: snapshot.error as String?,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
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
                  }),
              SizedBox(height: 10),
              StreamBuilder<String>(
                  stream: signupBloc.email$,
                  builder: (context, snapshot) {
                    return TextField(
                      key: Key("email_textfield"),
                        onChanged: signupBloc.email.sink.add,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          errorText: snapshot.error as String?,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
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
                  }),
              SizedBox(height: 15),
              StreamBuilder<DateTime>(
                  stream: signupBloc.dateOfBirth$,
                  builder: (context, AsyncSnapshot<DateTime> snapshot) {
                    return ListTile(
                      key: Key("choose_date_button"),
                      autofocus: false,
                      onTap: () async {
                        DateTime date = await showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => ChooseDatePage(
                              datemode: CupertinoDatePickerMode.date),
                        );

                        signupBloc.dateOfBirth.add(date!);
                      },
                      leading: Icon(CupertinoIcons.calendar),
                      title: Text("Date de naissance"),
                      trailing: snapshot.data != null
                          ? Text(f.format(snapshot.data))
                          : Text("Choisir"),
                    );
                  }),
              Center(
                  child: Text(
                      "Votre date de naissance est utilisé pour pouvoir vous créer un portefeuille kookers",
                      style: GoogleFonts.montserrat(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 10))),
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
                      key: Key("search_adress_button"),
                      autofocus: false,
                      onTap: () async {
                        this.adress = await showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => HomeSearchPage(isReturn: true, user: null),
                        );

                        signupBloc.adress.sink.add(this.adress);

                        setState(() {
                          this.adressString = this.adress.title;
                        });
                      },
                      leading: Icon(CupertinoIcons.home),
                      title: snapshot.data == null
                          ? Text("Votre adresse")
                          : Text(snapshot.data.title),
                      trailing: Icon(CupertinoIcons.chevron_down),
                    );
                  }),
              Center(
                  child: Text(
                      "Nous utilisons votre adresse pour vous connecter à des chefs ou à des potentiels clients autour de vous.",
                      style: GoogleFonts.montserrat(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 10))),
              SizedBox(height: 20),
              ListTile(
                autofocus: false,
                leading: StreamBuilder<bool>(
                    stream: signupBloc.acceptedPolicies$,
                    builder: (context, snapshot) {
                      return CircularCheckBox(
                          key: Key("checkboxTerms"),
                          activeColor: Colors.green,
                          value: snapshot.data != null
                              ? snapshot.data
                              : signupBloc.acceptedPolicies.value,
                          onChanged: signupBloc.acceptedPolicies.add);
                    }),
                title: RichText(
                    text: TextSpan(
                        text:
                            'En appuyant sur Créer un compte ou sur connexion, vous acceptez nos ',
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 12),
                        children: <TextSpan>[
                      TextSpan(
                          text: "Conditions d'utilisation ",
                          style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => WebViewPage(
                                            url: "https://getkookers.com/terms",
                                            title: "Conditions d'utilisation",
                                          )));
                            }),
                      TextSpan(
                        text:
                            ", Pour en savoir plus sur l'utilisation de vos données, consultez notre ",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 12),
                      ),
                      TextSpan(
                          text: "Politique de confidentialité",
                          style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => WebViewPage(
                                            url:
                                                "https://getkookers.com/privacy",
                                            title:
                                                "Politique de confidentialité",
                                          )));

                              // open desired screen
                            }),
                    ])),
              ),
              SizedBox(height: 40),
              StreamBuilder<bool>(
                  stream: signupBloc.isAllFilled$,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    return StreamButton(
                      key: Key("signup_button"),
                        buttonColor:
                            snapshot.data != null && snapshot.data != false
                                ? Colors.black
                                : Colors.grey,
                        buttonText: "Créer un compte",
                        errorText: "Erreur de création de compte",
                        loadingText: "Création en cours",
                        successText: "Compte créé",
                        controller: _streamButtonController,
                        onClick: () async {
                          if (snapshot.data != null && snapshot.data != false) {
                            _streamButtonController.isLoading();
                            final notifID =
                                await notificationService.notificationID();
                            SignupInformations infos = signupBloc.validate();
                            this
                                .createUser(
                                    this.widget.user.uid,
                                    databaseService.client,
                                    infos.firstName,
                                    infos.lastName,
                                    infos.email,
                                    this.widget.user.phoneNumber ?? '',
                                    notifID,
                                    this.photoUrl,
                                    infos.adress,
                                    phoneAuthBloc.userCurrency.value,
                                    phoneAuthBloc.userCountry.value,
                                    infos.birthDate)
                                .then((kooker) async {
                              databaseService.user.add(kooker);
                              await _streamButtonController.isSuccess();
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => NotificationPage(user: this.widget.user)));
                            }).catchError((onError) async {
                              await _streamButtonController.isError();
                            });
                          }
                        });
                  }),
              SizedBox(height: 30)
            ]),
          )
        ],
      ),
    );
  }
}
