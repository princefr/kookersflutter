import 'dart:async';
import 'dart:io';

import 'package:chips_choice/chips_choice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Services/CurrencyService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/PublicationProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/InfoDialog.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

enum SettingType { Plates, Desserts }

class Photo extends StatefulWidget {
  final BehaviorSubject<File> file;
  Photo({Key key,@required this.file}) : super(key: key);

  @override
  _PhotoState createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {
  final picker = ImagePicker();


  

  Future<File> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    return File(pickedFile.path);
  }

  @override
  void dispose() { 

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return StreamBuilder<File>(
          stream: this.widget.file,
          builder: (context, snapshot) {
            return Container(
                width: 120,
                height: 110,
                child: Stack(children: [
                  Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.rectangle,
                          image: snapshot.data == null ? null : DecorationImage(image: Image.file(this.widget.file.value).image, fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(15.0))),
                          
                  Positioned(
                    bottom: 0,
                    left: 75,
                    child: InkWell(
                      onTap: () {
                        if(snapshot.data == null){
                            this.getImage().then((file) {
                              if(file != null){
                                  this.widget.file.add(file);
                              }
                             
                                                });
                        }else{
                          this.widget.file.sink.add(null);
                        }
                      },
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 7.0, horizontal: 7),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 43, 84),
                              borderRadius: BorderRadius.circular(13.0)),
                          child: Icon(
                            snapshot.data == null
                                ? Icons.add
                                : CupertinoIcons.multiply,
                            color: Colors.white,
                            size: 20.0,
                          )),
                    ),
                  )
                ]),
              );
          }
        );
       
  }
}

class HomePublish extends StatefulWidget {
  HomePublish({Key key}) : super(key: key);

  @override
  _HomePublishState createState() => _HomePublishState();
}

class _HomePublishState extends State<HomePublish> {
  PublicationProvider pubprovider = PublicationProvider();


  double percentage(percent, total) {
    return ((percent/ 100) * total);
  }

  BehaviorSubject<bool> isPricePerPie = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<int> initialLabel = BehaviorSubject<int>.seeded(0);
  BehaviorSubject<int> fees = BehaviorSubject<int>.seeded(15);

  Stream<double> get feePaid => CombineLatestStream([pubprovider.priceall, fees], (values) => percentage(values[1], int.parse(values[0]))).asBroadcastStream();
  Stream<double> get moneyReceived => CombineLatestStream([pubprovider.priceall$, feePaid], (values) => double.parse(values[0]) - values[1]).asBroadcastStream();


  SettingType type;

    

  @override
  void initState() { 
    this.type = SettingType.Plates;
    this.initialLabel.listen((value) {
      if(value == 0){
        this.type = SettingType.Plates;
      }else{
        this.type = SettingType.Desserts;
      }
    });
    super.initState();
  }


  @override
  void dispose() { 
    this.isPricePerPie.close();
    this.initialLabel.close();
    this.pubprovider.dispose();
    this.fees.close();
    super.dispose();
  }

    Future<void> uploadPublication(GraphQLClient client, DatabaseProviderService database, Publication pub) {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
              mutation CreatePub($publication: PublicationInput!) {
                  createPublication(publication: $publication){
                _id
                description
                type
                food_preferences
              }
              }
          """), variables: <String, dynamic>{
            "publication": pub.toJson()
        });

        return client.mutate(_options).then((result) => result.data["createPublication"]);
  }

  StreamButtonController _streamButtonController = StreamButtonController();


  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    final firebaseUser = context.watch<User>();
    final storageService = Provider.of<StorageService>(context, listen: false);
      
      return Scaffold(
        body: SafeArea(
          top: false, 
          bottom: true,
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        height: 7,
                        width: 80),
                  ),
                  
                  SizedBox(height: 30),

                  Flexible(
                      child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                                child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [Photo(file: pubprovider.file0), Photo(file: pubprovider.file1), Photo(file: pubprovider.file2)],
                              ),
                            )),
                            

                            SizedBox(height: 30),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text("PRÉFÉRENCES ALIMENTAIRES",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 15))),
                            SizedBox(height: 10),

                            Container(
                              height: 70,
                              child: StreamBuilder(
                                  stream: pubprovider.pricePrefs.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting)
                                      return CircularProgressIndicator();
                                    return ChipsChoice<String>.multiple(
                                      spinnerColor: Color(0xFFF95F5F),
                                      choiceStyle: C2ChoiceStyle(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      choiceActiveStyle: C2ChoiceStyle(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xFFF95F5F)
                                      ),
                                      value: snapshot.data,
                                      onChanged: (val) => setState(() => pubprovider.pricePrefs.add(val)),
                                      
                                      choiceItems: C2Choice.listFrom<String,
                                          String>(
                                        source: pubprovider.prefs,
                                        value: (i, v) => v,
                                        label: (i, v) => v,
                                      ),
                                    );
                                  }),
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "Les  préférences alimentaires de vos plats nous aide à les proposer aux bonnes personnes. n’oubliez pas de les renseigner.",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 10))),
                            SizedBox(height: 30),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text("NOM DU PLAT",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 15))),
                            SizedBox(height: 10),

                            StreamBuilder<String>(
                              stream: pubprovider.name$,
                              builder: (context, snapshot) {
                                return TextField(
                                  onChanged: pubprovider.name.add,
                                  decoration: InputDecoration(
                                    hintText: "Renseigner le nom du plat",
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    errorText: snapshot.error,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),

                            SizedBox(height: 20),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text("DESCRIPTION",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 15))),
                            SizedBox(height: 10),

                            StreamBuilder<String>(
                              stream: pubprovider.description$,
                              builder: (context, snapshot) {
                                return TextField(
                                  onChanged: pubprovider.description.add,
                                    decoration: InputDecoration(
                                  hintText: "Renseigner la description",
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  errorText: snapshot.error,
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
                            SizedBox(height: 30),

                            Column(
                                     children: [
                                Align(
                                alignment: Alignment.centerLeft,
                                child: Text("PRIX",
                                    style: GoogleFonts.montserrat(
                                   decoration: TextDecoration.none,
                                   color: Colors.black,
                                   fontSize: 15))),

                                    SizedBox(height: 10),

                                       Padding(
                                    padding:
                                       const EdgeInsets.symmetric(horizontal: 5),
                                    child: StreamBuilder<Object>(
                                      stream: pubprovider.priceall$,
                                      builder: (context, snapshot) {
                                       return TextField(
                                         keyboardType: TextInputType.number,
                                         onChanged: pubprovider.priceall.add,
                                         decoration: InputDecoration(
                                         hintText: "Prix du plat",
                                         fillColor: Colors.grey[200],
                                         filled: true,
                                         errorText: snapshot.error,
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
                                     ],
                                   ),
    

                            SizedBox(height: 20),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text("ADRESSE",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 15))),
                            SizedBox(height: 10),
                            ListTile(
                              onTap: (){showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => HomeSearchPage(isReturn: false,),
                        );},
                              leading: Icon(CupertinoIcons.home),
                              title: StreamBuilder(
                                stream: databaseService.user$,
                                builder: (context, AsyncSnapshot<UserDef> snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                                  return Text(snapshot.data.adresses.where((element) => element.isChosed == true).first.title, style: GoogleFonts.montserrat(fontSize: 17));
                                }
                              ),
                              trailing: Icon(CupertinoIcons.chevron_down),
                            ),
                            SizedBox(height: 10),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "Nous utilisons votre adresse pour vous connecter à des potentiels clients autour de vous.",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 10))),

                            SizedBox(height: 20),


                            StreamBuilder<int>(
                              stream: this.initialLabel.stream,
                              builder: (context, snapshot) {
                                return Visibility(
                                    visible: snapshot.data == 0,
                                    child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                showDialog(context: context,
                                                 builder: (context) => InfoDialog(infoText: "Ce chiffre représente le montant que la plateforme, kookers prendra dans le cadre des frais de fonctionnement. Il représente 15% du prix de l'assiette/portion vendue."));
                                              },
                                              child: Icon(CupertinoIcons.info_circle)),
                                            Text("Frais de la platforme", style: GoogleFonts.montserrat(),),
                                            StreamBuilder<double>(
                                              initialData: 0.0,
                                            stream: this.feePaid,
                                            builder: (context, snapshot) {
                                              if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                                              if(snapshot.data == null) return SizedBox();
                                              return Text(snapshot.data.toStringAsFixed(2) + " " + CurrencyService.getCurrencySymbol(databaseService.user.value.currency), style: GoogleFonts.montserrat());
                                            }
                                          )

                                        ],),
                                      ),


                                    Container(
                                    height: 50,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            showDialog(context: context,
                                              builder: (context) => InfoDialog(infoText: "Ce chiffre représente le montant que vous recevrez pour chacun(e) des portions ou plats que vous vendriez à l'aide la plateforme kookers une fois les frais de fonctionnement déduits."));
                                          },
                                          child: Icon(CupertinoIcons.info_circle)),
                                        Text("Ce que vous recevrez", style: GoogleFonts.montserrat(),),
                                        StreamBuilder<double>(
                                        stream: this.moneyReceived,
                                        initialData: 0.0,
                                        builder: (context, snapshot) {
                                          if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                                          if(snapshot.data == null) return SizedBox();
                                          return Text(snapshot.data.toStringAsFixed(2) + " " + CurrencyService.getCurrencySymbol(databaseService.user.value.currency) , style: GoogleFonts.montserrat());
                                        }
                                      )

                                    ],),
                                  ),
                                    ],
                                  ),
                                );
                              }
                            ),


                            SizedBox(height: 40),


                            StreamBuilder(
                              stream: pubprovider.isFormValidOne$,
                              builder: (ctx, AsyncSnapshot<bool> snapshot) {
                                return StreamButton(buttonColor: snapshot.data != null ? Color(0xFFF95F5F) : Colors.grey,
                                 buttonText: "Vendre mon plat",
                                 errorText: "Une erreur s'est produite",
                                 loadingText: "Publication en cours",
                                 successText: "Plat publié",
                                  controller: _streamButtonController, onClick: () async {
                                    if(snapshot.data != null) {
                                      _streamButtonController.isLoading();
                                    pubprovider.validate(firebaseUser, storageService, databaseService, this.type).then((publication){
                                      this.uploadPublication(databaseService.client, databaseService, publication).then((value){
                                        _streamButtonController.isSuccess().then((value) async {
                                          await databaseService.loadSellerPublications();
                                          Navigator.pop(context);
                                        });
                                      }).catchError((error) => _streamButtonController.isError());
                                    }).catchError((onError) => _streamButtonController.isError());
                                  }
                                  });
                              }
                            ),
                            
                            SizedBox(height: 30)
                      ],
                    ),
                  )


 
                ],
              )),
        ),
      );
  }
}
