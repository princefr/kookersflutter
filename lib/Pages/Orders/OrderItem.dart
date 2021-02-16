import 'package:cached_network_image/cached_network_image.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Orders/OrderPageChild.dart';
import 'package:kookers/Services/CurrencyService.dart';
import 'package:kookers/Widgets/StatusChip.dart';


enum OrderState {
    NOT_ACCEPTED,
    ACCEPTED,
    REFUSED,
    DONE,
    RATED,
    CANCELLED}

class Publication {
  String id;
  String title;
  String description;
  List<Object> imagesUrls;
  List<String> preferences;
  
  Publication({@required this.title, this.description, this.imagesUrls, this.id, this.preferences});

}


class Seller {
  String id;
  String firstName;
  String lastName;
  String photoUrl;
  String fcmToken;
  Seller({this.firstName, this.lastName, this.photoUrl, this.fcmToken, this.id});

  static Seller fromJson(Map<String, dynamic> map) => Seller(
    id: map["_id"],
    firstName: map['first_name'],
    lastName: map['last_name'],
    photoUrl: map['photoUrl'],
    fcmToken: map['fcmToken']
  );

}




class Order {
        String id;
        String productId;
        String stripeTransactionId;
        String deliveryDay;
        String totalPrice;
        String quantity;
        String sellerId;
        String currency;
        OrderState orderState;
        Publication publication;
        int notificationBuyer;
        String totalWithFees;
        String fees;
        Seller seller;
        Order({this.productId, this.stripeTransactionId, this.orderState, this.publication, this.deliveryDay,
         this.seller, this.currency, this.id, this.quantity, this.sellerId, this.totalPrice, this.notificationBuyer, this.totalWithFees, this.fees});

        static Order fromJson(Map<String, dynamic> map) => Order(
          productId: map["productId"],
          stripeTransactionId: map["stripeTransactionId"],
          deliveryDay: map["deliveryDay"],
          orderState: EnumToString.fromString(OrderState.values, map["orderState"]),
          publication: Publication(title: map["publication"]["title"], description: map["publication"]["description"], imagesUrls: map["publication"]["photoUrls"], id: map["publication"]["_id"], preferences: List<String>.from(map["publication"]["food_preferences"])),
          seller: Seller.fromJson(map["seller"]),
          id: map["_id"],
          quantity: map["quantity"],
          sellerId: map["sellerId"],
          currency: map["currency"],
          totalPrice: map["total_price"],
          notificationBuyer: map["notificationBuyer"],
          totalWithFees: map["total_with_fees"],
          fees: map["fees"]
          
        );

        Map<String, dynamic> toJSON() {
          final Map<String, dynamic> data = new Map<String, dynamic>();
          data["id"] = this.id;
          data["productId"] = this.productId;
          data["stripeTransactionId"] = this.stripeTransactionId;
          data["quantity"] = this.quantity;
          data["sellerId"] = this.seller.id;

          return data;
        }

         static List<Order> fromJsonToList(List<Object> map) {
            List<Order> allpublications = [];
            map.forEach((element) {
              final x = Order.fromJson(element);
              allpublications.add(x);
            });
            return allpublications;
          }

}


class OrderItemShimmer extends StatelessWidget {
  const OrderItemShimmer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
        child: InkWell(
            child: ListTile(
            leading: Container(
              decoration: BoxDecoration(color: Colors.grey[200],    
              borderRadius: BorderRadius.all(Radius.circular(5.0))  
                    ),
              height: 350,
               width: 100
              ),
            title: Align(
              alignment: Alignment.centerLeft,
                child: Column(
                mainAxisAlignment:  MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(decoration: BoxDecoration(
                        color: Colors.grey[200],      
                      ),child: Text("this.order.publication.this", style: GoogleFonts.montserrat(),)),

                      SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],      
                      ),child: Text("this.order.productId bitch i'm", style: GoogleFonts.montserrat(fontSize: 13))),

                      SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],      
                      ),child: Text("this.order.orderState",  style: GoogleFonts.montserrat(fontSize: 13))),
                  
                ]
              ),
            ),
            trailing: Container(decoration: BoxDecoration(
                        color: Colors.grey[200],      
                      ),child: Text("15€")),
          ),
        ),
      )
    );
  }
}

class OrderItem extends StatelessWidget {
  final Order order;
  final Function(Order) onOrderTap;
  OrderItem({Key key, @required this.order, this.onOrderTap}) : super(key: key);

  


  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.order.notificationBuyer > 0 ? Colors.red[100]: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
        child: InkWell(
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => OrderPageChild(order: this.order))),
            child: ListTile(
            leading: Image(height: 350, width: 100, fit: BoxFit.cover, image: CachedNetworkImageProvider(order.publication.imagesUrls[0])),
            title: Align(
              alignment: Alignment.centerLeft,
                child: Column(
                mainAxisAlignment:  MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(this.order.publication.title),
                  Text(this.order.productId, style: GoogleFonts.montserrat(fontSize: 13)),
                  StatusChip(state: this.order.orderState)
                ]
              ),
            ),
            trailing: Text(this.order.totalWithFees + CurrencyService.getCurrencySymbol(this.order.currency)),
          ),
        ),
      )
    );
  }
}