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
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/PublicationProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toggle_switch/toggle_switch.dart';

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
  Widget build(BuildContext context) {
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
                      image: this.widget.file.value == null ? null : DecorationImage(image: Image.file(this.widget.file.value).image, fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(15.0))),
              Positioned(
                bottom: 0,
                left: 75,
                child: InkWell(
                  onTap: () {
                    this.getImage().then((file) {
                      setState(() {
                        this.widget.file.add(file);
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
                        this.widget.file.value == null
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
}

class HomePublish extends StatefulWidget {
  HomePublish({Key key}) : super(key: key);

  @override
  _HomePublishState createState() => _HomePublishState();
}

class _HomePublishState extends State<HomePublish> {
  bool isPricePerPie = false;

  int initialLabel = 0;
  SettingType type;

  Future changeType(index) async {
    Future.delayed(Duration(milliseconds: 200)).then((value) {
      setState(() {
        if (index == 0) {
          this.isPricePerPie = false;
          this.initialLabel = 0;
          this.type = SettingType.Plates;
        } else {
          this.isPricePerPie = true;
          this.initialLabel = 1;
          this.type = SettingType.Desserts;
        }
      });
    });
  }

  @override
  void initState() { 
    this.type = SettingType.Plates;
    super.initState();
  }

    Future<void> uploadPublication(GraphQLClient client, DatabaseProviderService database, Publication pub) {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
              mutation CreatePub($publication: PublicationInput!) {
                  createPublication(publication: $publication){
                _id
                description
                type
                food_preferences {
                    is_selected
                    title
                }
              }
              }
          """), variables: <String, dynamic>{
            "publication": pub.toJson()
        });

        return client.mutate(_options);
  }

  StreamButtonController _streamButtonController = StreamButtonController();




  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    final publicatiionProvider = Provider.of<PublicationProvider>(context, listen: true);
    
    return GraphQLConsumer(builder: (GraphQLClient client) {
      final firebaseUser = context.read<User>();
      final storageService = Provider.of<StorageService>(context, listen: false);
      
      return Scaffold(
        body: SafeArea(
          top: false, 
          bottom: true,
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                children: [Photo(file: publicatiionProvider.file0), Photo(file: publicatiionProvider.file1), Photo(file: publicatiionProvider.file2)],
                              ),
                            )),
                            
                            SizedBox(height: 30),

                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text("TYPE DE VENTE",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 15))),
                            SizedBox(height: 15),
                            ToggleSwitch(
                              inactiveBgColor: Colors.grey[300],
                              activeBgColor: Color(0xFFF95F5F),
                              initialLabelIndex: initialLabel,
                              minWidth: 400,
                              labels: ['Plats', 'Desserts'],
                              onToggle: (index) {
                                this.changeType(index);
                                print('switched to: $index');
                              },
                            ),
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
                                  stream: publicatiionProvider.pricePrefs.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting)
                                      return CircularProgressIndicator();
                                    return ChipsChoice<dynamic>.multiple(
                                      spinnerColor: Colors.red,
                                      choiceStyle: C2ChoiceStyle(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      choiceActiveStyle: C2ChoiceStyle(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromARGB(255, 255, 43, 84)
                                      ),
                                      value: snapshot.data
                                          .where((element) =>
                                              element.isSelected == true)
                                          .map((e) => e.title)
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          return snapshot.data.forEach((element) =>
                                              val.contains(element.title)
                                                  ? element.isSelected = true
                                                  : element.isSelected = false);
                                        });
                                      },
                                      choiceItems: C2Choice.listFrom<dynamic,
                                          FoodPreference>(
                                        source: snapshot.data.toList(),
                                        value: (i, v) => v.title,
                                        label: (i, v) => v.title,
                                      ),
                                    );
                                  }),
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
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
                              stream: publicatiionProvider.name$,
                              builder: (context, snapshot) {
                                return TextField(
                                  onChanged: publicatiionProvider.name.add,
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
                              stream: publicatiionProvider.description$,
                              builder: (context, snapshot) {
                                return TextField(
                                  onChanged: publicatiionProvider.description.add,
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
                                      stream: publicatiionProvider.priceall$,
                                      builder: (context, snapshot) {
                                        return TextField(
                                          keyboardType: TextInputType.number,
                                          onChanged: publicatiionProvider.priceall.add,
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

                            SizedBox(height: 10),


                               Visibility(
                                    visible: this.isPricePerPie,
                                    child: Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: StreamBuilder<Object>(
                                          stream: publicatiionProvider.priceaPerPortion$,
                                          builder: (context, snapshot) {
                                            return TextField(
                                              onChanged: publicatiionProvider.priceaPerPortion.add,
                                              decoration: InputDecoration(
                                              errorText: snapshot.error,
                                              hintText: "Prix par portion",
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
                                    )),

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
                                stream: databaseService.user,
                                builder: (context, AsyncSnapshot<UserDef> snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator();
                                  return Text(snapshot.data.adresses.where((element) => element.isChosed == true).first.title, style: GoogleFonts.montserrat(fontSize: 17));
                                }
                              ),
                              trailing: Icon(CupertinoIcons.chevron_down),
                            ),
                            SizedBox(height: 10),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 10))),
                            SizedBox(height: 40),


                            StreamBuilder(
                              stream: publicatiionProvider.isFormValidOne$,
                              builder: (ctx, AsyncSnapshot<bool> snapshot) {
                                return StreamButton(buttonColor: snapshot.data != null ? Color(0xFFF95F5F) : Colors.grey,
                                 buttonText: "Publier le plat",
                                 errorText: "Une erreur s'est produite",
                                 loadingText: "Publication en cours",
                                 successText: "Plat publié",
                                  controller: _streamButtonController, onClick: () async {
                                    _streamButtonController.isLoading();
                                    if(snapshot.data != null) {
                                    publicatiionProvider.validate(firebaseUser, storageService, databaseService, this.type).then((publication){
                                      this.uploadPublication(client, databaseService, publication).then((value){
                                        _streamButtonController.isSuccess().then((value) {
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
    });
  }
}
