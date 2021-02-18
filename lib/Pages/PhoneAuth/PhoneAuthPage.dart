import 'package:currency_pickers/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Pages/PhoneAuth/PhoneAuthCodePage.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';


// https://github.com/FirebaseExtended/flutterfire/issues/4651 phonne issue.

class PhoneAuthPage extends StatefulWidget {
  PhoneAuthPage({Key key}) : super(key: key);

  @override
  _PhoneAuthCodeState createState() => _PhoneAuthCodeState();
}

class _PhoneAuthCodeState extends State<PhoneAuthPage> {



  @override
  void initState() { 
    super.initState();
    
  }


  bool isValidPhoneNumber(String string) {
    // Null or empty string is invalid phone number
    if (string == null || string.isEmpty) {
      return false;
    }

    // You may need to change this pattern to fit your requirement.
    // I just copied the pattern from here: https://regexr.com/3c53v
    const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return false;
    }
    return true;
  }

   StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    final phoneAuthBloc = Provider.of<PhoneAuthBloc>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final authentificationService = Provider.of<AuthentificationService>(context, listen: false);
    phoneAuthBloc.listen();

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TopBarWitBackNav(
            title: "Vérification Télephone",
            rightIcon: CupertinoIcons.exclamationmark_circle_fill,
            isRightIcon: false,
            height: 54,
            onTapRight: () {}),
        body: SafeArea(
            child: Container(
            child: Column(children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                    "Veuillez renseigner votre numéro de téléphone pour vous connecter à votre compte ou vous incrire.",
                    style: GoogleFonts.montserrat(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5),
              ),
              SizedBox(height: 15),
              Divider(color: Colors.grey),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: ListTile(
                    autofocus: false,
                    leading: StreamBuilder<Object>(
                      stream: phoneAuthBloc.phoneCode$,
                      builder: (context, snapshot) {
                        return CountryCodePicker(
                          onChanged:(CountryCode code) {
                            String currency = CurrencyPickerUtils.getCountryByIsoCode(code.code.toUpperCase()).currencyCode.toString();
                            phoneAuthBloc.inuserCurrency.add(currency.toLowerCase());
                            phoneAuthBloc.inuserCountry.add(code.code);
                            phoneAuthBloc.phoneCode.add(code.dialCode);
                          },
                          initialSelection: '+33',
                          favorite: ['+33', 'GB'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          padding: const EdgeInsets.all(5.0)
                        );
                      }
                    ),
                    title: StreamBuilder<String>(
                      stream: phoneAuthBloc.phoneNumber$,
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        return TextField(
                          keyboardType: TextInputType.phone,
                          onChanged: phoneAuthBloc.phoneNumber.add,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Numéro de téléphone',
                              focusedBorder: InputBorder.none,
                              errorText: snapshot.error,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15)),
                        );
                      }
                    ),
                  ),
                ),
              ),

              Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Votre numéro de téléphone nous sert uniquement à vous connecter à nos services et aux services de paiement de nos partenaires.",
                  style: GoogleFonts.montserrat(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5),
            ),
            
              Expanded(
                child: SizedBox(),
              ),



                           StreamBuilder(
                              stream: phoneAuthBloc.isAllFilled$,
                              builder: (ctx, AsyncSnapshot<bool> snapshot) {
                                return StreamButton(buttonColor: snapshot.data != null ? Colors.black : Colors.grey,
                                 buttonText: "Envoyer le sms",
                                 errorText: "Une erreur s'est produite, veuillez reesayer!",
                                 loadingText: "Envoie en cours",
                                 successText: "Sms envoyé",
                                  controller: _streamButtonController, onClick: () async {
                                    if(snapshot.data != null) {
                                      _streamButtonController.isLoading();
                                    String phone = await phoneAuthBloc.validate();
                                    notificationService.askPermission().then((permission) async {
                                          if (permission.authorizationStatus ==
                                                  AuthorizationStatus.authorized ||
                                              permission.authorizationStatus ==
                                                  AuthorizationStatus.provisional)
                                            {
                                              authentificationService.verifyPhone(
                                                      phone: phone,
                                                      codeisSent: (verificationId) async {
                                                        await _streamButtonController.isSuccess();
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PhoneAuthCodePage(
                                                                        verificationId:
                                                                            verificationId)));
                                                      },
                                                      error: (e) async {
                                                        await _streamButtonController.isError();
                                                        // errorService.showError(context);
                                                        print("error" +
                                                            " " +
                                                            e.message +
                                                            " " +
                                                            e.code +
                                                            " " +
                                                            "this is me here");
                                                      });
                                                
                                            }
                                          else
                                            {
                                              print(
                                                  'User declined or has not accepted permission');
                                            }
                                        });
                                  }
                                  });
                              }
                            ),

                      SizedBox(height: 10)
            ]),
          ),
        ),
      );

  }
}
