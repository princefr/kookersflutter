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
                  autofocus: false,
                leading: StreamBuilder<bool>(
                  stream: bloc.acceptMask$,
                  initialData: bloc.acceptMask.value,
                  builder: (context, snapshot) {
                    return CircularCheckBox(
                        key: Key("firstTerm"),
                        activeColor: Colors.green,
                        value: snapshot.data ?? false,
                        onChanged: bloc.acceptMask.add
                          );
                  }
                ),// jhjhj
                    title: Text("Vous acceptez de devoir porter des gants et une charlotte lorsque vous cuisinez par les membres de la communauté.", style: GoogleFonts.montserrat(fontSize: 13),),
              ),

              SizedBox(height: 30),

              ListTile(
                autofocus: false,
                leading: StreamBuilder<bool>(
                  stream: bloc.acceptGloves,
                  initialData: bloc.acceptGloves.value,
                  builder: (context, snapshot) {
                    return CircularCheckBox(
                      key: Key("secondTerm"),
                        activeColor: Colors.green,
                        value: snapshot.data ?? false,
                        onChanged: bloc.acceptGloves.add
                          
                          );
                  }
                ),
                    title: Text("Vous acceptez de porter un masque lorsque vous cuisinez pour protéger la santé des autres utilisateurs. ", style: GoogleFonts.montserrat(fontSize: 13),),
              ),



              SizedBox(height: 30),

              ListTile(
                autofocus: false,
                leading: StreamBuilder<bool>(
                  stream: bloc.acceptBeenVerified$,
                  initialData: bloc.acceptBeenVerified.value,
                  builder: (context, snapshot) {
                    return CircularCheckBox(
                        key: Key("thirdTerm"),
                        activeColor: Colors.green,
                        value: snapshot.data ?? false,
                        onChanged: bloc.acceptBeenVerified.add
                          
                          );
                  }
                ),
                    title: Text("Vous acceptez de faire attention à l'hygiène de votre  cuisine , des instruments que vous utilisez , à la chaîne du froid et du chaud lorsque vous cuisinez pour les membres de la communauté.", style: GoogleFonts.montserrat(fontSize: 13),),
              ),


              Expanded(child: SizedBox()),

               StreamBuilder<bool>(
                stream: bloc.isAllFilled$,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  return StreamButton(
                    key: Key("SellingAcceptButton"),
                    buttonColor: (snapshot.data != null && snapshot.data != false) ? Colors.black : Colors.grey,
                                     buttonText: "Accepter",
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