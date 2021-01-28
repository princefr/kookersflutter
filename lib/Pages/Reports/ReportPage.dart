import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Reports/ReportModel.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';


enum ReportType {
  NOTINTERRESTED,
  SPAM,
  COPYFRAUD,
  ARNAQUE
}

class ReportPage extends StatefulWidget {
  final String publicatonId;
  final String seller;
  ReportPage({Key key, this.publicatonId, this.seller}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {


  Future<void> createReport(GraphQLClient client, ReportInput report) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          mutation CreateReport($report: ReportInput!) {
            createReport(report: $report){
              _id
            }
          }
        """),
        variables: <String, dynamic> {
          "report": report.toJSON()
        }
        );

    return client.mutate(_options).then((result) => result.data["createReport"]);
  }

  int _value = 0;
  StreamButtonController _streamButtonController = StreamButtonController();

  // ignore: close_sinks
  BehaviorSubject<String> comment =   BehaviorSubject<String>();

  @override
  Widget build(BuildContext context) {

    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
    

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
                  SizedBox(height: 50),

                
                  DropdownButton(
                      value: _value,
                      isExpanded: true,
                      elevation: 2,
                      items: [
                          DropdownMenuItem(
                            child: Text(ReportType.ARNAQUE.toString()),
                            value: 0,
                          ),

                          DropdownMenuItem(
                            child: Text(ReportType.COPYFRAUD.toString()),
                            value: 1,
                          ),

                          DropdownMenuItem(
                            child: Text(ReportType.NOTINTERRESTED.toString()),
                            value: 2,
                          ),

                          DropdownMenuItem(
                            child: Text(ReportType.SPAM.toString()),
                            value: 3,
                          ),
                      ], onChanged: (int value) {
                        setState(() {
                          this._value = value;
                        });
                        },
                    ),

                    SizedBox(height:10),

                  Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                      style: GoogleFonts.montserrat(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 10))),

                    SizedBox(height:30),

                    StreamBuilder<Object>(
                      stream: this.comment,
                      builder: (context, snapshot) {
                        return TextField(
                              minLines: 1,
                              maxLines: 5,
                              onChanged: this.comment.add,
                              decoration: InputDecoration(
                              hintText: 'Ajouter une description du signalement',
                              fillColor: Colors.grey[200],
                              filled: true,
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

                  SizedBox(height:10),

                  Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                      style: GoogleFonts.montserrat(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 10))),

                    Expanded(child: SizedBox()),
                    
                                StreamButton(buttonColor: Colors.red,
                                     buttonText: "Signaler",
                                     errorText: "Une erreur s'est produite",
                                     loadingText: "Signalement en cours",
                                     successText: "Post signalé",
                                      controller: _streamButtonController, onClick: () async {
                                        _streamButtonController.isLoading();
                                        ReportInput report  = ReportInput(description: this.comment.value, userReported: this.widget.seller,  userReporting: databaseService.user.value.id,  type: EnumToString.convertToString(ReportType.values[this._value], camelCase: true));
                                        createReport(databaseService.client, report).then((result){
                                          _streamButtonController.isSuccess().then((value){
                                            Navigator.pop(context);
                                          });
                                        }).catchError((onError) {
                                          _streamButtonController.isError();
                                        });
                                        
                                        
                                  }),
                  SizedBox(height: 30)
                ],
              )),
        ),
      );

  }
}
