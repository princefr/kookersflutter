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
  ReportPage({Key key,@required this.publicatonId,@required this.seller}) : super(key: key);

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

  String getEnum(ReportType enumstring){
    switch (enumstring) {
      case ReportType.ARNAQUE:
        return "Arnaque";
        break;
    case ReportType.NOTINTERRESTED:
        return "Pas interessé";
    break;
    case ReportType.COPYFRAUD:
        return "Autres";
    break;
    case ReportType.SPAM:
        return "Spam";
    break;
      default:
      return "Arnaque";
    }
  }

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
                            child: Text(getEnum(ReportType.ARNAQUE), style: GoogleFonts.montserrat(),),
                            value: 0,
                          ),

                          DropdownMenuItem(
                            child: Text(getEnum(ReportType.COPYFRAUD), style: GoogleFonts.montserrat()),
                            value: 1,
                          ),

                          DropdownMenuItem(
                            child: Text(getEnum(ReportType.NOTINTERRESTED), style: GoogleFonts.montserrat()),
                            value: 2,
                          ),

                          DropdownMenuItem(
                            child: Text(getEnum(ReportType.SPAM), style: GoogleFonts.montserrat()),
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
                      "Définissez le type de signalement que vous souhaitez effectuer.",
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
                      "Ajoutez une description à votre signalement pour nous aider à traiter plus efficacement la requête envoyée.",
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
