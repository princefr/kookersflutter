import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/KookersButton.dart';
import 'package:kookers/Widgets/TopBar.dart';


class VendorPubPage extends StatefulWidget {
  final PublicationVendor publication;
  VendorPubPage({Key key, this.publication}) : super(key: key);

  @override
  _VendorPubPageState createState() => _VendorPubPageState();
}

class _VendorPubPageState extends State<VendorPubPage> {

     Future<bool> cLosePublication(GraphQLClient client, String publicationId, bool isClosed) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          mutation updatePublication($publication_id: String, $is_closed: Boolean) {
                closePublication(publication_id: $publication_id, is_closed: $is_closed){
                    is_open
                }
            }
        """),
        variables: <String,  dynamic> {
          "publication_id": publicationId,
          "is_closed": isClosed
        }
      );

    return client.mutate(_options).then((value) => value.data["closePublication"]["is_open"]);
  }
  
  @override
  Widget build(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
        return Scaffold(
          appBar: TopBarWitBackNav(
                              title: this.widget.publication.id,
                              rightIcon: CupertinoIcons.chat_bubble,
                              isRightIcon: false,
                              height: 54,
                              onTapRight: () {

                              }),
          body: Container(
            child: ListView(
              children: [
                

                FlatButton(onPressed: (){
                      this.cLosePublication(client, this.widget.publication.id, !this.widget.publication.isOpen).then((value) => {
                        this.widget.publication.isOpen = value
                      });
                }, child: KookersButton(text: this.widget.publication.isOpen == true? "Fermer la vente" : "Ouvrir la vente", color: Colors.black, textcolor: Colors.white))


                
              ]
            ),
          ),
        );

    });
  }
}