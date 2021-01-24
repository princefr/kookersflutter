import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iban_form_field/iban_form_field.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';



class AddIbanPage extends StatefulWidget {
  AddIbanPage({Key key}) : super(key: key);

  @override
  _AddIbanPageState createState() => _AddIbanPageState();
}

class _AddIbanPageState extends State<AddIbanPage> {
  final StreamButtonController _streamButtonController = StreamButtonController();


  @override
  void initState() {
    super.initState();
  }

  // ignore: close_sinks
  BehaviorSubject<Iban> iban = BehaviorSubject<Iban>();

  @override
  Widget build(BuildContext context) {

      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
      
    
    return Scaffold(
          body: SafeArea(
                      child: Container(
            child: Column(children: [

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
            Text("Ajouter un iban", style: GoogleFonts.montserrat(fontSize: 20),),

              SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder<Iban>(
                stream: this.iban.stream,
                builder: (context, snapshot) {
                  return IbanFormField(
                      onSaved: this.iban.add,
                      initialValue: Iban('FR'),
                      validator: (Iban iban) {
                      if (!iban.isValid) {
                        print("not valid");
                      return 'This IBAN is not valid';
                    }
                    print("iban is valid");
                    return null;
                      },

                  );
                }
              ),
            ),

                                
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 10))),
                                ),
            

            Expanded(child: SizedBox()),

            StreamButton(buttonColor: Color(0xFFF95F5F),
                                 buttonText: "Ajouter l'iban",
                                 errorText: "Une erreur s'est produite",
                                 loadingText: "Ajout en cours",
                                 successText: "Iban ajouté",
                                  controller: _streamButtonController, onClick: () async {

                                    print(this.iban.value);

                                    // _streamButtonController.isLoading();
                                    // databaseService.createBankAccount("FR1420041010050500013M02606").then((value) {
                                    //     _streamButtonController.isSuccess();
                                    // }).catchError((onError) {
                                    //    _streamButtonController.isError();
                                    // });
                                    
                                  })


              ],)
        ),
          ),
    );
  
  }
}


class IbanPage extends StatefulWidget {
  const IbanPage({Key key}) : super(key: key);

  @override
  _IbanPageState createState() => _IbanPageState();
}

class _IbanPageState extends State<IbanPage> {

  @override
  void initState() { 
    new Future.delayed(Duration.zero, (){
      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
      databaseService.listExternalAccount().then((value){
        databaseService.userBankAccounts.add(value);
      });
    });
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
    return Scaffold(
            appBar: TopBarWitBackNav(
            title: "Iban",
            rightIcon: CupertinoIcons.plus,
            isRightIcon: true,
            height: 54,
            onTapRight: () {

        showCupertinoModalBottomSheet(
              expand: false,
              context: context,
              builder: (context) => AddIbanPage(),
                                  );
            }),
            
            body: SafeArea(
              child: StreamBuilder<List<BankAccount>>(
                  stream: databaseService.userBankAccounts.stream,
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator();
                    if(snapshot.hasError) return Text("i've a bad felling");
                    if(snapshot.data.isEmpty) return Text("its empty out there");
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (ctx, index){
                        return ListTile(
                          title: Text("*************" + " " + snapshot.data[index].last4),
                          trailing: Icon(CupertinoIcons.check_mark_circled, color: Colors.green,),
                        );
                    });
                  }
                ),
            ),
    );
  }
}