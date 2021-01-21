
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Vendor/VendorPubChild.dart';
import 'package:kookers/Services/DatabaseProvider.dart';


class PublicationItemVendorShimmer extends StatelessWidget {
  const PublicationItemVendorShimmer({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
      leading: Container(
        decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),
        height: 350,
          width: 100,
      ),
      title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(          decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),child: Text("this.publication.title")),
        Container(          decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),child: Text("this.publication.id", style: GoogleFonts.montserrat(fontSize: 13))),
        Container(          decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),child: Text("this.publication.adress.title"))
        //Text(this.publicati)
      ]),
    ));
  }
}


class PublicationItemVendor extends StatelessWidget {
  final PublicationVendor publication;
  const PublicationItemVendor({Key key, this.publication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
                  VendorPubPage(publication: this.publication))),
      leading: Image(
          height: 350,
          width: 100,
          fit: BoxFit.cover,
          image: NetworkImage(this.publication.photoUrls[0])),
      title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(this.publication.title),
        Text(this.publication.id, style: GoogleFonts.montserrat(fontSize: 13)),
        Text(this.publication.adress.title)
        //Text(this.publicati)
      ]),
    ));
  }
}