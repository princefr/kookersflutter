import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kookers/Pages/Balance/BalancePage.dart';
import 'package:kookers/Pages/Iban/IbanPage.dart';
import 'package:kookers/Pages/PaymentMethods/PaymentMethodPage.dart';
import 'package:kookers/Pages/Verification/VerificationPage.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:package_info/package_info.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsItemWithLeftIcon extends StatelessWidget {
  final Function onTap;
  final String buttonText;
  final IconData icon;
  const SettingsItemWithLeftIcon(
      {Key key, @required this.onTap, @required this.buttonText, @required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    
    return Material(
        child: InkWell(
      onTap: this.onTap,
      child: Container(
        color: Colors.white,
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ListTile(
            autofocus: false,
            leading: Icon(this.icon),
            title: Text(this.buttonText,
                style: GoogleFonts.montserrat(fontSize: 16)),
            trailing: Icon(CupertinoIcons.chevron_right),
          ),
        ),
      ),
    ));
  }
}

class SettingsItem extends StatelessWidget {
  final Function onTap;
  final String buttonText;
  const SettingsItem({Key key, @required this.onTap, @required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: this.onTap,
      child: Container(
        color: Colors.white,
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ListTile(
            autofocus: false,
            title: Text(this.buttonText,
                style: GoogleFonts.montserrat(fontSize: 16)),
            trailing: Icon(CupertinoIcons.chevron_right),
          ),
        ),
      ),
    ));
  }
}

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with AutomaticKeepAliveClientMixin<Settings> {
  
  @override
  bool get wantKeepAlive => true;

String capitalizeFirstOnly(String string){
  return string.characters.first.toUpperCase() + string.substring(1);
}



  final picker = ImagePicker();

  Future<File> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    return File(pickedFile.path);
  }

  Future<void> updateUserImage(GraphQLClient client, String uid, String imageUrl, DatabaseProviderService database) {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
              mutation UpdateUserImage($userID: String!, $imageUrl: String!) {
                  updateUserImage(userID: $userID, imageUrl: $imageUrl){
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
          """), variables: <String, String>{
          "userID": uid,
          "imageUrl": imageUrl
        });

        return client.mutate(_options).then((kooker) {
                  final kookersUser = UserDef.fromJson(kooker.data["updateUserImage"]);
                  database.user.add(kookersUser);
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final firebaseUser = context.watch<User>();
    final storageService = Provider.of<StorageService>(context, listen: false);
    final authentificationService = Provider.of<AuthentificationService>(context, listen: false);
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);

    return Container(
      child: ListView(
        children: [
        PageTitle(title: "Paramètres"),
        SizedBox(height: 20),

        Container(
          height: 130,
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Stack(children: [
            Center(
              child: StreamBuilder(
                stream: databaseService.user$,
                builder: (context, AsyncSnapshot<UserDef> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                  radius: 65,
                backgroundImage: CachedNetworkImageProvider(snapshot.data.photoUrl,),
              );
                }
              ),
            ),

            Positioned(
              bottom: 0,
              left: 205,
              child: InkWell(
                onTap: () {
                  this.getImage().then((file) async {
                    File _file = await FlutterNativeImage.compressImage(file.path, quality: 35);
                    storageService.uploadPictureFile(databaseService.user.value.id, "photoUrl", _file, "profilImage").then((url) => {
                      this.updateUserImage(databaseService.client, firebaseUser.uid, url, databaseService)
                    });
                  }).catchError((onError){
                    print(onError);
                  });
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 7),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 43, 84),
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20.0,
                    )),
              ),
            )
          ]),
        ),
        
        SizedBox(height: 20),
        Center(
            child: Text(databaseService.user.value.lastName.toUpperCase() + " " + capitalizeFirstOnly(databaseService.user.value.firstName),
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87))),
        SizedBox(height: 15),
        Divider(),
        SettingsItemWithLeftIcon(
          icon: Icons.credit_card_sharp,
            buttonText: "Méthodes de paiements",
            onTap: () => Navigator.push(context,
                CupertinoPageRoute(builder: (context) => PaymentMethodPage()))),

            Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
          child: Text(
              "Regroupe toutes les cartes de crédit ajoutées et utilisées pour payer dans l’application kookers.",
              style: GoogleFonts.montserrat(
                  decoration: TextDecoration.none,
                  color: Colors.black,
                  fontSize: 10)),
        )),

        SettingsItemWithLeftIcon(
          icon: Icons.account_balance_wallet_sharp,
            buttonText: "Portefeuille",
            onTap: () => Navigator.push(context,
                CupertinoPageRoute(builder: (context) => BalancePage()))),

        Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
          child: Text(
              "Regroupe le montant de votre portefeuille et les transactions qui y sont associées. Quand vous vendez sur kookers l’argent arrive d’abord dans votre portefeuille avant de pouvoir être retirer sur un compte en banque.",
              style: GoogleFonts.montserrat(
                  decoration: TextDecoration.none,
                  color: Colors.black,
                  fontSize: 10)),
        )),


        SettingsItemWithLeftIcon(
          icon: Icons.account_balance,
            buttonText: "Comptes bancaires",
            onTap: () => Navigator.push(context,
                CupertinoPageRoute(builder: (context) => IbanPage()))),

                  Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
        child: Text(
            "Regroupe tous les comptes bancaires utilisés pour retirer l’argent de votre portefeuille. Vos ibans sont uniquement utilisés à cet effet, retirer l’argent de votre portefeuille.",
            style: GoogleFonts.montserrat(
                decoration: TextDecoration.none,
                color: Colors.black,
                fontSize: 10)),
      )),

        SettingsItem(
            onTap: () {
              Navigator.push(context,
                CupertinoPageRoute(builder: (context) => VerificationPage()));
              
            }, buttonText: "Vérification d'identité"),

        SettingsItem(
            onTap: () {
              launch("https://getkookers.com/terms");
              
            }, buttonText: "Conditions générale d'utilisation"),
        SettingsItem(onTap: () {
            launch("http://getkookers.com/privacy");
        }, buttonText: "Politique de confidentialité"),
        SettingsItem(onTap: () {
          launch("http://getkookers.com/privacy");
        }, buttonText: "Gestion des cookies"),

        SettingsItem(onTap: () {
          launch("https://getkookers.com/guidelines");
        }, buttonText: "Règles de la communauté"),

        SettingsItem(onTap: () async {
            print("i'm signign out");
           await authentificationService.signOut();
        }, buttonText: "Se deconnecter"),


        SizedBox(height: 30,),

        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (ctx, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
            if(snapshot.data == null) return SizedBox();
            return Center(child: Text("Version:" + " " + snapshot.data.version, style: GoogleFonts.montserrat()));
          }
        ),

        SizedBox(height: 20,),
      ]),
    );


  }


  
}
