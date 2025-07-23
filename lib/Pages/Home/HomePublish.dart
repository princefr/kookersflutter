import 'dart:async';
import 'dart:io';

import 'package:chips_choice/chips_choice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Services/CurrencyService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/PublicationProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/InfoDialog.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

enum SettingType { Plates, Desserts }

class Photo extends StatefulWidget {
  final BehaviorSubject<File?> file;
  final Stream<File?> stream;
  Photo({Key? key, required this.file, required this.stream}) : super(key: key);

  @override
  _PhotoState createState() => _PhotoState();
}

class _PhotoState extends State<Photo> with AutomaticKeepAliveClientMixin<Photo>  {
    @override
  bool get wantKeepAlive => true;

  final picker = ImagePicker();

  Future<File?> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
        super.build(context);
        return InkWell(
          onTap: () async {
                            if(this.widget.file.value == null){
                              final status = await Permission.photos.status;
                              if(status.isDenied){
                                showDialog(context: context, builder: (BuildContext ctx){
                                     return CupertinoAlertDialog(
                                        title: Text("Accès à la biblioteque et photos"),
                                        content: Center(child: Text("Vous avez refusez la permission de prendre les photos, veuillez changer les permissions dans les paramètres de votre téléphone."),),
                                        actions: [
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Fermer', style: TextStyle(color:Colors.red),),
                                          ),

                                          CupertinoDialogAction(
                                            onPressed: () {
                                              openAppSettings();
                                            },
                                            isDefaultAction: true,
                                            child: const Text('Paramètres'),
                                          )
                                        ],
                                      );
                                   });
                              }else{
                                this.getImage().then((file) async{
                                  if(file != null){
                                      FlutterNativeImage.compressImage(file.path, quality: 35).then((compressed) {
                                        this.widget.file.add(compressed);
                                      });
                                  }
                                 
                              });
                              }
                                
                            }
          },
                  child: Container(
            child: StreamBuilder<File?>(
              initialData: this.widget.file.value,
              stream: this.widget.stream,
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
                              image: snapshot.data == null ? null : DecorationImage(image: Image.file(snapshot.data!).image, fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(15.0))),
                              
                      Positioned(
                        bottom: 0,
                        left: 75,
                        child: InkWell(
                          onTap: () async {
                            if(snapshot.data == null){
                                final status = await Permission.photos.status;
                              if(status.isDenied){
                                showDialog(context: context, builder: (BuildContext ctx){
                                     return CupertinoAlertDialog(
                                        title: Text("Accès à la biblioteque et photos"),
                                        content: Center(child: Text("Vous avez refusez la permission de prendre les photos, veuillez changer les permissions dans les paramètres de votre téléphone."),),
                                        actions: [
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Fermer', style: TextStyle(color:Colors.red),),
                                          ),

                                          CupertinoDialogAction(
                                            onPressed: () {
                                              openAppSettings();
                                            },
                                            isDefaultAction: true,
                                            child: const Text('Paramètres'),
                                          )
                                        ],
                                      );
                                   });
                              }else{
                                this.getImage().then((file) async{
                                  if(file != null){
                                      FlutterNativeImage.compressImage(file.path, quality: 35).then((compressed) {
                                        this.widget.file.add(compressed);
                                      });
                                  }
                                 
                              });
                              }
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
            ),
          ),
        );
       
  }
}

class HomePublish extends StatefulWidget  {
  final User user;
  HomePublish({Key? key, required this.user}) : super(key: key);

  

  @override
  _HomePublishState createState() => _HomePublishState();
}

class _HomePublishState extends State<HomePublish> with AutomaticKeepAliveClientMixin<HomePublish>  {

  @override
  bool get wantKeepAlive => true;

  PublicationProvider pubprovider = PublicationProvider();


  double percentage(percent, total) {
    return ((percent/ 100) * total);
  }


  BehaviorSubject<int> fees = BehaviorSubject<int>.seeded(15);

  Stream<double> get feePaid => CombineLatestStream([pubprovider.priceall, fees], (values) => percentage(values[1] as int, int.parse(values[0] as String))).asBroadcastStream();
  Stream<double> get moneyReceived => CombineLatestStream([pubprovider.priceall$, feePaid], (values) => double.parse(values[0] as String) - (values[1] as double)).asBroadcastStream();


  SettingType type = SettingType.Plates;

    

  @override
  void initState() { 
    this.type = SettingType.Plates;
    super.initState();
  }


  @override
  void dispose() {
    this.pubprovider.dispose();
    this.fees.close();
    super.dispose();
  }

  StreamButtonController _streamButtonController = StreamButtonController();


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
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
                                children: [Photo(file: pubprovider.file0, stream: pubprovider.file0$, key: Key("photo0"),), Photo(file: pubprovider.file1, stream: pubprovider.file1$, key: Key("photo1")), Photo(file: pubprovider.file2, stream: pubprovider.file2$, key: Key("photo2"))],
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
                                      key: Key("chips_choice"),
                                      spinnerColor: Color(0xFFF95F5F),
                                      wrapped: true,
                                      value: snapshot.data as List<String>,
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
                                  key: Key("plate_name"),
                                  onChanged: pubprovider.name.add,
                                  decoration: InputDecoration(
                                    hintText: "Renseigner le nom du plat",
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    errorText: snapshot.error as String?,
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
                                  key: Key("plate_description"),
                                  onChanged: pubprovider.description.add,
                                    decoration: InputDecoration(
                                  hintText: "Renseigner la description",
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  errorText: snapshot.error?.toString(),
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
                                      initialData: pubprovider.priceall.value,
                                      stream: pubprovider.priceall$,
                                      builder: (context, snapshot) {
                                       return TextField(
                                         key: Key("plate_price"),
                                         keyboardType: TextInputType.number,
                                         onChanged: pubprovider.priceall.add,
                                         decoration: InputDecoration(
                                         hintText: "Prix du plat",
                                         fillColor: Colors.grey[200],
                                         filled: true,
                                         errorText: snapshot.error?.toString(),
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
                              autofocus: false,
                              onTap: (){showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => HomeSearchPage(isReturn: false, user: this.widget.user),
                        );},
                              leading: Icon(CupertinoIcons.home),
                              title: StreamBuilder(
                                initialData: databaseService.user.value,
                                stream: databaseService.user$,
                                builder: (context, AsyncSnapshot<UserDef> snapshot) {
                                  // if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                                  return Text(snapshot.data?.adresses?.where((element) => element.isChosed == true).first.title ?? '', style: GoogleFonts.montserrat(fontSize: 17));
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


                            Column(
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
                                          return Text((snapshot.data ?? 0.0).toStringAsFixed(2) + " " + CurrencyService.getCurrencySymbol(databaseService.user.value.currency ?? 'EUR'), style: GoogleFonts.montserrat());
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
                                      return Text((snapshot.data ?? 0.0).toStringAsFixed(2) + " " + CurrencyService.getCurrencySymbol(databaseService.user.value.currency ?? 'EUR') , style: GoogleFonts.montserrat());
                                    }
                                  )

                                ],),
                                  ),
                                ],
                                  ),



                      ],
                    ),
                  ),


                            StreamBuilder<bool>(
                              initialData: null,
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
                                    final publication = await pubprovider.validate(this.widget.user, storageService, databaseService, this.type);
                                    await _streamButtonController.isSuccess();
                                    Navigator.pop(context, publication);

                                    // this.uploadPublication(databaseService.client, databaseService, publication).then((value){
                                    //     _streamButtonController.isSuccess().then((value) async {
                                    //       await databaseService.loadSellerPublications();
                                    //       Navigator.pop(context);
                                    //     });
                                    //   }).catchError((error) => _streamButtonController.isError());
                                  }
                                  });
                              }
                            ),
                            
                            SizedBox(height: 10)


 
                ],
              )),
        ),
      );
  }
}
