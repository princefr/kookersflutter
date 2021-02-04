
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/FullScreenImage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StatusChip.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class VendorPageChild extends StatefulWidget {
  final OrderVendor vendor;
  VendorPageChild({Key key, this.vendor}) : super(key: key);

  @override
  _VendorPageChildState createState() => _VendorPageChildState();
}

class _VendorPageChildState extends State<VendorPageChild> {


  StreamSubscription<OrderVendor> orderSubscription;
  // ignore: close_sinks
  BehaviorSubject<OrderVendor>  order = new BehaviorSubject<OrderVendor>();



  @override
  void initState() { 
        Future.delayed(Duration.zero, (){
        final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
          this.orderSubscription = databaseService.getOrderSeller(this.widget.vendor.id, this.order);
    });
    super.initState();
    
  }


  @override
  void dispose() { 
    this.orderSubscription.cancel();
    this.order.close();
    super.dispose();
  }

  Future<Room> createRoom(GraphQLClient client, String user1, String user2) async {
    final MutationOptions _options  = MutationOptions(
          documentNode: gql(r"""
            mutation CreateChatRoom($user1: String!, $user2: String!){
                  createChatRoom(user1:$user1 , user2: $user2){
                              _id
                              updatedAt
                              
                              
                              receiver {
                                  first_name
                                  last_name
                                  phonenumber
                                  photoUrl
                                  fcmToken
                              }
                              
                              messages {
                                  userId
                                  message
                                  createdAt
                                  message_picture
                                  is_sent
                                  is_read
                              }
                }
              }
          """),
          variables:  <String, String> {
            "user1": user1,
            "user2": user2
          }
        );

        return client.mutate(_options).then((result) => Room.fromJson(result.data["createChatRoom"], user2));
}


Future<void> refuseOrder(GraphQLClient client, OrderVendor order) async {
final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation RefuseOrder($order: OrderInput!){
              refuseOrder(order: $order){
                _id,
                orderState
              }
          }
      """),
      variables:  <String, dynamic> {
        "order": order.toJson()
      }
    );

    return await client.mutate(_options).then((result) => result.data["refuseOrder"]);
}


Future<void> acceptOrder(GraphQLClient client, OrderVendor order) async {
final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation AcceptOrder($order: OrderInput!){
              acceptOrder(order: $order){
                _id,
                orderState
              }
          }
      """),
      variables:  <String, dynamic> {
        "order": order.toJson()
      }
    );

    return await client.mutate(_options).then((result) => result.data["refuseOrder"]);
}


 StreamButtonController _streamButtonController = StreamButtonController();
 StreamButtonController _streamButtonController2 = StreamButtonController();


  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    
      return Scaffold(
        appBar: TopBarWitBackNav(
                          title: this.widget.vendor.deliveryDay,
                          rightIcon: CupertinoIcons.chat_bubble,
                          isRightIcon: true,
                          height: 54,
                          onTapRight: () {
                            
                            this.createRoom(databaseService.client, this.widget.vendor.buyerID, databaseService.user.value.id).then((result) => Navigator.push(context,
                            CupertinoPageRoute(
                              builder: (context) => ChatPage(room: result))));
                          }),
        body: Center(
          child: ListView(
            children: [
              Divider(),

              CarouselSlider(items: this.widget.vendor.publication.photoUrls.map((e) {
              return InkWell(
                onTap: (){
                  Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => FullScreenImage(url: e)));
                },
                              child: Hero(
                                tag: e,
                                                              child: Image(
                
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(e),
            ),
                              ),
              );
            }).toList(),
             options: CarouselOptions(height: 300.0, aspectRatio: 16/9, enlargeCenterPage: true, initialPage: 0,
             enableInfiniteScroll: false,)),

             SizedBox(height:10),

             Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(this.widget.vendor.totalPrice + " " + this.widget.vendor.currency,
                      style: GoogleFonts.montserrat(
                          fontSize: 26, color: Colors.grey)),
                )),

                
                
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("2"),)
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: SizedBox()),
                  StreamBuilder<OrderVendor>(
                        stream: this.order.stream,
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting) return Text("nope");
                          return StatusChip(state: EnumToString.fromString(OrderState.values, snapshot.data.orderState));
                        }
                      ),
                ],
              ),
            ),

              Container(
                height: 40,
                child: Builder(builder: (BuildContext ctx) {
                  if(this.widget.vendor.publication.preferences.any((element) => element.isSelected == true)){
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: this.widget.vendor.publication.preferences.where((element) => element.isSelected == true).toList().length,
                      itemBuilder: (ctx, index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5, top: 3),
                          child: Container(
                                  decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ), padding: EdgeInsets.all(10), child: Text(this.widget.vendor.publication.preferences.where((element) => element.isSelected == true).elementAt(index).title)),
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

             SizedBox(height:30),


             Text( "  réference: " + this.widget.vendor.id),


             SizedBox(height:30),
             
              ListTile(
                leading: CircleAvatar(
                  radius: 25,
                backgroundImage:
                    CachedNetworkImageProvider(this.widget.vendor.buyer.photoUrl),
              ),

              title: Text(this.widget.vendor.buyer.firstName + " " + this.widget.vendor.buyer.lastName),

              ),


              ListTile(
                leading: Icon(CupertinoIcons.calendar),
                title: Text(this.widget.vendor.deliveryDay)
              ),


              SizedBox(height: 50,),

              StreamBuilder<OrderVendor>(
                stream: this.order.stream,
                builder: (context, snapshot) {
                  return Builder(builder: (ctx) {
                    if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                                if (snapshot.hasError)
                                  return Text("i've a bad felling");
                                if (snapshot.data == null)
                                  return Text("its empty out there");

                    switch (snapshot.data.orderState) {
                      case "ACCEPTED":
                          return Center(child: Text("Le plat a été accepté", style: GoogleFonts.montserrat(fontSize: 17),));
                        break;
                      case "CANCELLED":
                          return Center(child: Text("le plat a été annulé par l'acheteur", style: GoogleFonts.montserrat(fontSize: 17)));
                        break;
                      case "DONE":
                        return Center(child: Text("plat recu par l'acheteur", style: GoogleFonts.montserrat(fontSize: 17)));
                        break;

                      case "NOT_ACCEPTED":
                        return Container(child: Column(children: [
                          StreamButton(buttonColor: Colors.green,
                                     buttonText: "Accepter la commande",
                                     errorText: "Une erreur s'est produite",
                                     loadingText: "Acceptation en cours",
                                     successText: "Commande acceptée",
                                      controller: _streamButtonController, onClick: () async {
                                        _streamButtonController.isLoading();
                                        this.acceptOrder(databaseService.client, this.widget.vendor).then((result) {
                                          _streamButtonController.isSuccess();
                                          databaseService.loadSellerOrders();
                                        }).catchError((err) {
                                          _streamButtonController.isError();

                                        });
                                        
                                  }),

                              SizedBox(height: 10),
                              Divider(),
                              SizedBox(height: 10),


                          StreamButton(buttonColor: Colors.red,
                                     buttonText: "Refuser la commande",
                                     errorText: "Une erreur s'est produite",
                                     loadingText: "Refus en cours",
                                     successText: "Commande refusée",
                                      controller: _streamButtonController2, onClick: () async {
                                        _streamButtonController2.isLoading();
                                        this.refuseOrder(databaseService.client, this.widget.vendor).then((result) {
                                          _streamButtonController2.isSuccess();
                                          databaseService.loadSellerOrders();
                                        }).catchError((onError) {
                                          _streamButtonController2.isError();
                                        });
                                        
                          }),

                        ]));
                        
                        break;
                      case "RATED":
                        return Center(child: Text("le plat est livré et noté", style: GoogleFonts.montserrat(fontSize: 17)));
                        break;

                      case "REFUSED":
                        return Center(child: Text("Vous avez refusé la commande.", style: GoogleFonts.montserrat(fontSize: 17)));
                        
                        break;

                        
                        
                      default:
                      return Text("");
                    }
                  });
                }
              )
            ],
          )
        ),
      );


  }
}