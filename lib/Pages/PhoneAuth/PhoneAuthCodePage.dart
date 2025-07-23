import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Blocs/PhoneCodeBloc.dart';
import 'package:kookers/Pages/Notifications/NotificationPage.dart';
import 'package:kookers/Pages/Signup/SignupPage.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/DatabaseProvider.dart' as db;
import 'package:kookers/Services/ErrorBarService.dart';
import 'package:kookers/Services/PermissionHandler.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class PhoneAuthCodePage extends StatefulWidget {
  final String verificationId;

  PhoneAuthCodePage({Key? key, required this.verificationId}) : super(key: key);

  @override
  _PhoneAuthCodePageState createState() => _PhoneAuthCodePageState();
}

class _PhoneAuthCodePageState extends State<PhoneAuthCodePage> {
  
  final myController = TextEditingController();
  final permissionHandler = PermissionHandler();


  @override
  void dispose() { 
    this.bloc.dispose();
    super.dispose();
  }

    StreamButtonController _streamButtonController = StreamButtonController();
    PhoneCodeBloc bloc = PhoneCodeBloc();

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
    final authentificationService = Provider.of<AuthentificationService>(context, listen: false);
    

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

                  child: StreamBuilder<Object>(
                    stream: bloc.code$,
                    builder: (context, snapshot) {
                      return TextField(
                        key:  Key("PhoneCodeTestField"),
                          onChanged: bloc.code.sink.add,
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
                          ));
                    }
                  ),
                ),
              ),

              Expanded(
                child: SizedBox(),
              ),


              StreamBuilder<String>(
                      stream: bloc.code.stream,
                      builder: (ctx, snapshot) {
                        return StreamButton(buttonColor: snapshot.data != null ? Colors.black : Colors.grey,
                          key: Key("phoneCodeButton"),
                          buttonText: "Vérifier mon code",
                          errorText: "Une erreur s'est produite, Veuillez reesayer",
                          loadingText: "Vérification en cours",
                          successText: "Vérification terminée",
                          controller: _streamButtonController, onClick: () async {
                            if(snapshot.data != null) {
                              _streamButtonController.isLoading();
                              databaseService.adress.add(db.Adress());
                              authentificationService.signInWithVerificationID(widget.verificationId, bloc.code.value).then((connected) {
                                databaseService.loadUserData(connected.user!.uid).then((user) async {
                                  if(user == null) {
                                              _streamButtonController.isSuccess();
                                                Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        SignupPage(
                                                            user: connected
                                                                .user!)));
                                    } else{
                                      databaseService.user.add(user);
                                      _streamButtonController.isSuccess();
                                      if (user.notificationPermission == true) {
                                              Get.to(TabHome(user:  connected.user!,));        
                                            }else{
                                              Get.to(NotificationPage(user: connected.user!));
                                            }

                                    }
                                }).catchError((onError) async {
                                  print(onError);
                                  NotificationPanelService.showError(context, "Veuillez verifier votre connexion à internet et reessayer.");
                                  await _streamButtonController.isError();
                                });
                              }).catchError((onError) async {
                               await _streamButtonController.isError();
                              });
                          }
                          });
                      }
                    ),

            ]),
          ),
        ),
      );
  }
}
