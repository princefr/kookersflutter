import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/ButtonVerification.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';



class VerificationPage extends StatefulWidget {
  final User user;
  VerificationPage({Key key, this.user}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {

  final picker = ImagePicker();

  Future<File> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    return File(pickedFile.path);
  }


  bool isSending = false;



  @override
  Widget build(BuildContext context) {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);

    
    return Scaffold(
      backgroundColor: Colors.white,
            appBar: TopBarWitBackNav(
            title: "Vérification de documents",
            rightIcon: CupertinoIcons.plus,
            isRightIcon: false,
            height: 54,
            onTapRight: null),

      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height:10),

              Visibility(
                visible: this.isSending,
                child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("La photo de vos documents nous aide à prouver votre identité. L'identité sur les documents doit correspondre à votre personne.",
                    style: GoogleFonts.montserrat(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 5
                   ),
              ),

              Divider(),

              

              SizedBox(height: 15),

              StreamBuilder<UserDef>(
                stream: databaseService.user$,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                  return ButtonVerification(color: Colors.grey[300], leftIcon: Icon(CupertinoIcons.globe, color: Colors.black, size: 24.0), status: snapshot.data.stripeAccount.stripeRequirements.idStatus, text: "Passeport", onTap: (){
                    getImage().then((file) {
                      setState(() => this.isSending = true);
                      storageService.uploadPictureFile(databaseService.user.value.id, "passport.png", file, "passport", databaseService.user.value.stripeaccountId).then((value) {
                        setState(() => this.isSending = false);
                      }).catchError((onError){
                        setState(() => this.isSending = false);
                        print("error");
                      });
                    });
                  });
                }
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("La photo de vos documents nous aide à prouver votre identité. Elle doit correspondre aux informations que vous avez fournies lors des étapes précédentes.",
                  style: GoogleFonts.montserrat(fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 5
                 ),
              ),


              SizedBox(height: 25),

              StreamBuilder<UserDef>(
                stream: databaseService.user$,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                  return ButtonVerification(color: Colors.grey[300],leftIcon: Icon(CupertinoIcons.doc, color: Colors.black, size: 24.0), status: snapshot.data.stripeAccount.stripeRequirements.residenceProof, text: "Attestation d'hébergement", onTap: (){
                    getImage().then((file){
                      setState(() => this.isSending = true);
                      storageService.uploadPictureFile(databaseService.user.value.id, "residenceprof.png", file, "residence_proof", databaseService.user.value.stripeaccountId).then((value) {
                        setState(() => this.isSending = false);
                      }).catchError((onError){
                        setState(() => this.isSending = false);
                      });
                    });
                  });
                }
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("La photo de vos documents nous aide à prouver votre identité. Elle doit correspondre aux informations que vous avez fournies lors des étapes précédentes.",
                  style: GoogleFonts.montserrat(fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 5
                 ),
              ),



            ],
          ),
        )
      ),
    );
  }
}