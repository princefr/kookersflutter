import 'package:currency_pickers/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Pages/PhoneAuth/PhoneAuthCodePage.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:kookers/Widgets/KookersButton.dart';
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

  Future<void> withdrawMoney(GraphQLClient client, String accountId, String amount, String currency) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          query MakePayout($account_id: String!, $amount: String!, $currency: String!) {
              makePayout(account_id: $account_id, amount: $amount, currency: $currency){
                id
          }
      """), variables: <String, String>{
      "account_id": accountId,
      "amount": amount,
      "currency": currency
    });

    return await client.mutate(_options).then((value) => value.data["makePayout"]);
  }



  Future<void> loadAllWithdraws(GraphQLClient client, accountId) async{
        final QueryOptions _options = QueryOptions(documentNode: gql(r"""
          query GetPayoutList($accountId: String!) {
              getPayoutList(accountId: $accountId){
                i
          }
      """), variables: <String, String>{
      "account_id": accountId,
    });
    
    return await client.query(_options).then((value) => value.data["getPayoutList"]);
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

              StreamBuilder<bool>(
                stream: phoneAuthBloc.isAllFilled$,
                builder: (context, snapshot) {
                  return TextButton(
                      onPressed: () async {
                          String phone = await phoneAuthBloc.validate();
                          notificationService.askPermission().then((permission) => {
                                if (permission.authorizationStatus ==
                                        AuthorizationStatus.authorized ||
                                    permission.authorizationStatus ==
                                        AuthorizationStatus.provisional)
                                  {
                                    authentificationService.verifyPhone(
                                            phone: phone,
                                            codeisSent: (verificationId) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PhoneAuthCodePage(
                                                              verificationId:
                                                                  verificationId)));
                                            },
                                            error: (e) {
                                              // errorService.showError(context);
                                              print("error" +
                                                  " " +
                                                  e.message +
                                                  " " +
                                                  e.code +
                                                  " " +
                                                  "this is me here");
                                            })
                                      
                                  }
                                else
                                  {
                                    print(
                                        'User declined or has not accepted permission')
                                  }
                              });
                        
                      },
                      child: KookersButton(
                          text: "Envoyer le sms",
                          color: snapshot.data == null ? Colors.grey : snapshot.data == false ? Colors.grey : Colors.black,
                          textcolor: Colors.white));
                }
              ),
                      SizedBox(height: 10)
            ]),
          ),
        ),
      );

  }
}
