import 'package:cached_network_image/cached_network_image.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/Vendor/VendorPageChild.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StatusChip.dart';

class OrderItemSellerShimmer extends StatelessWidget {
  const OrderItemSellerShimmer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
          child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),
                    height: 350,
                    width: 100,
        ),
        title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),child: Text("this.vendor.publication.title")),
          Container(
            decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),
            child: Text("this.vendor.productId",
                style: GoogleFonts.montserrat(fontSize: 13)),
          ),
        ]),
      )),
    );
  }
}

class OrderItemSeller extends StatelessWidget {
  final OrderVendor vendor;
  const OrderItemSeller({Key key, this.vendor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
          child: ListTile(
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => VendorPageChild(vendor: this.vendor))),
        leading: Container(
        height: 350,
        width: 100,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  image: DecorationImage(image: CachedNetworkImageProvider(this.vendor.publication.photoUrls[0]), fit: BoxFit.cover),                
        ),
      ),
        title: Column(mainAxisAlignment:  MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(this.vendor.publication.title),
                Text(this.vendor.productId,
              style: GoogleFonts.montserrat(fontSize: 13)),

              StatusChip(state: EnumToString.fromString(OrderState.values, vendor.orderState))
        ]),
      )),
    );
  }
}