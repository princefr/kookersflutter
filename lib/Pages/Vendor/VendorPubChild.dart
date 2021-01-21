import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                
                CarouselSlider(items: this.widget.publication.photoUrls.map((e) {
                  return Image(
                  
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(e),
                );
                }).toList(),
                options: CarouselOptions(height: 300.0, aspectRatio: 16/9, enlargeCenterPage: true, initialPage: 0,
                enableInfiniteScroll: false,)),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(this.widget.publication.pricePerAll,
                      style: GoogleFonts.montserrat(
                          fontSize: 26, color: Colors.grey)),
                    ),

                    Row(
                      children: [
                        Text(""),
                        SizedBox(width: 20),
                        Container(
                          decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(children: [
                                    Icon(CupertinoIcons.star_fill, size: 13, color: Colors.yellow[900]),
                                    SizedBox(width: 5),
                                    Text("4.7 (295)")

                                  ],),
                                ),

                                SizedBox(width: 15),

                      ]
                    )

                    
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(this.widget.publication.description),
                ),


                Container(
                height: 40,
                child: Builder(builder: (BuildContext ctx) {
                  if(this.widget.publication.preferences.any((element) => element.isSelected == true)){
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: this.widget.publication.preferences.where((element) => element.isSelected == true).toList().length,
                      itemBuilder: (ctx, index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5, top: 3),
                          child: Container(
                                  decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ), padding: EdgeInsets.all(10), child: Text(this.widget.publication.preferences.where((element) => element.isSelected == true).elementAt(index).title)),
                        );
                    });
                  }else{
                    return Container(height: 40, child: Text("Sans préférences"), decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ),);
                  }
                }),
              ),


              Divider(),


              ListTile(
                leading: Icon(CupertinoIcons.home),
                title: Text(this.widget.publication.adress.title),
              ),

              ListTile(
                leading: Icon(CupertinoIcons.time),
                title: Text(this.widget.publication.createdAt),
              ),


              SizedBox(height: 40),
                

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