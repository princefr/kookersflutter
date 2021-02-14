import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Blocs/GuidelinesBloc.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';






class GuidelinesToSell extends StatefulWidget {

  
  GuidelinesToSell({Key key}) : super(key: key);

  @override
  _GuidelinesToSellState createState() => _GuidelinesToSellState();
}

class _GuidelinesToSellState extends State<GuidelinesToSell> with AutomaticKeepAliveClientMixin<GuidelinesToSell>  {
    @override
  bool get wantKeepAlive => true;

  GuidelineBloc bloc = GuidelineBloc();

  final StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    
    super.build(context);

    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);

    return Material(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                SizedBox(height: 10),

              

                Center(child: Container(child: Lottie.asset('assets/lottie/lf30_editor_yjzfwsfh.json', height: 200, fit: BoxFit.fill, repeat: true))),


                ListTile(
                leading: StreamBuilder<bool>(
                  stream: bloc.acceptMask$,
                  initialData: bloc.acceptMask.value,
                  builder: (context, snapshot) {
                    return CircularCheckBox(
                        activeColor: Colors.green,
                        value: snapshot.data ?? false,
                        onChanged: bloc.acceptMask.add
                          
                          );
                  }
                ),
                    title: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", style: GoogleFonts.montserrat(fontSize: 13),),
              ),

              SizedBox(height: 30),

              ListTile(
                leading: StreamBuilder<bool>(
                  stream: bloc.acceptGloves,
                  initialData: bloc.acceptGloves.value,
                  builder: (context, snapshot) {
                    return CircularCheckBox(
                        activeColor: Colors.green,
                        value: snapshot.data ?? false,
                        onChanged: bloc.acceptGloves.add
                          
                          );
                  }
                ),
                    title: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", style: GoogleFonts.montserrat(fontSize: 13),),
              ),



              SizedBox(height: 30),

              ListTile(
                leading: StreamBuilder<bool>(
                  stream: bloc.acceptBeenVerified$,
                  initialData: bloc.acceptBeenVerified.value,
                  builder: (context, snapshot) {
                    return CircularCheckBox(
                        activeColor: Colors.green,
                        value: snapshot.data ?? false,
                        onChanged: bloc.acceptBeenVerified.add
                          
                          );
                  }
                ),
                    title: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", style: GoogleFonts.montserrat(fontSize: 13),),
              ),


              Expanded(child: SizedBox()),

               StreamBuilder<bool>(
                stream: bloc.isAllFilled$,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  return StreamButton(buttonColor: (snapshot.data != null && snapshot.data != false) ? Colors.black : Colors.grey,
                                     buttonText: "Continuer",
                                     errorText: "Erreur, Veuiller ressayer",
                                     loadingText: "Traitement en cours",
                                     successText: "Vous etes désormais un vendeur.",
                                      controller: _streamButtonController, onClick: () async {
                                        if(snapshot.data != null && snapshot.data != false ) {
                                          _streamButtonController.isLoading();
                                          databaseService.setIsSeller().then((user) async {
                                            await  _streamButtonController.isSuccess();
                                            Navigator.pop(context);
                                          
                                          }).catchError((onError) {
                                              _streamButtonController.isError();
                                          });
                                      }
                                      });
                }
              ),
              SizedBox(height: 20)





          ],
        ),
      ),
    );
  }
}