
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Pages/PhoneAuth/PhoneAuthCodePage.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';

// https://github.com/FirebaseExtended/flutterfire/issues/4651 phonne issue.

class PhoneAuthPage extends StatefulWidget {
  PhoneAuthPage({Key? key}) : super(key: key);

  @override
  _PhoneAuthCodeState createState() => _PhoneAuthCodeState();
}

class _PhoneAuthCodeState extends State<PhoneAuthPage> {
  @override
  void initState() {
    this.phoneAuthBloc.listen();
    super.initState();
  }


  PhoneAuthBloc phoneAuthBloc = PhoneAuthBloc();



  @override
  void dispose() { 
    this.phoneAuthBloc.dispose();
    super.dispose();
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
    
    final authentificationService =
        Provider.of<AuthentificationService>(context, listen: false);
    

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
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  autofocus: false,
                  leading: StreamBuilder<Object>(
                      stream: this.phoneAuthBloc.phoneCode$,
                      builder: (context, snapshot) {
                        return CountryCodePicker(
                            onChanged: (CountryCode code) {
                              this.phoneAuthBloc.inuserCurrency.sink
                                  .add(code.code?.toLowerCase() ?? '');
                              this.phoneAuthBloc.inuserCountry.add(code.code ?? '');
                              this.phoneAuthBloc.phoneCode.add(code.dialCode ?? '');
                            },
                            initialSelection: '+33',
                            favorite: ['+33', 'GB'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            padding: const EdgeInsets.all(5.0));
                      }),
                  title: StreamBuilder<String>(
                      stream: this.phoneAuthBloc.phoneNumber$,
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        return TextField(
                          key: Key("phone_number"),
                          keyboardType: TextInputType.phone,
                          onChanged: this.phoneAuthBloc.phoneNumber.sink.add,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Numéro de téléphone',
                              focusedBorder: InputBorder.none,
                              errorText: snapshot.error as String?,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15)),
                        );
                      }),
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



            StreamBuilder<String>(
                stream: this.phoneAuthBloc.phoneAndCode,
                builder: (ctx, AsyncSnapshot<String> snapshot) {
                  return StreamButton(
                      key: Key("phoneValidationButton"),
                      buttonColor:
                          snapshot.data != null ? Colors.black : Colors.grey,
                      buttonText: "Envoyer le sms",
                      errorText:
                          "Une erreur s'est produite, veuillez reesayer!",
                      loadingText: "Envoie en cours",
                      successText: "Sms envoyé",
                      controller: _streamButtonController,
                      onClick: () async {
                        print("ive been tapped");
                        print(snapshot.data);
                        print(this.phoneAuthBloc.phoneAndCode.listen((event) {print(event);}));
                        print(this.phoneAuthBloc.phoneNumber.value);
                        if (snapshot.data != null) {
                          _streamButtonController.isLoading();
                          String phone = await this.phoneAuthBloc.validate();
                                                        authentificationService
                                  .verifyPhone(
                                  phone: phone,
                                  codeAutoRetrievalTimeout: (String verificationId) {},
                                  codeTimeOut: (String verificationId) {},
                                  codeisSent: (String verificationId, int? resendToken) {},
                                  error: (FirebaseAuthException e) {},
                                  timeout: const Duration(seconds: 60),
                                  codeSent: (String verificationId, int? forceResendingToken) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PhoneAuthCodePage(
                                                    verificationId:
                                                    verificationId)));
                                  },
                                  verificationCompleted: (PhoneAuthCredential credential) async {
                                    await _streamButtonController.isSuccess();
                                  },
                                  verificationFailed: (FirebaseAuthException e) async {
                                    await _streamButtonController.isError();
                                  }
                              )
                              .catchError((err) => err);
                        }
                      });
                }),
            SizedBox(height: 10)
          ]),
        ),
      ),
    );
  }
}
