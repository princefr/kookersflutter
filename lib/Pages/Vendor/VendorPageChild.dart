
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Services/CurrencyService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StatusChip.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:lottie/lottie.dart';
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
  StreamSubscription<int> get notificationIncoming => this.order.where((event) => event.notificationSeller > 0).map((event) => event.notificationSeller).listen((event) => event);


  double percentage(percent, total) {
        return (percent / 100) * total;
  }

  double fees;
  double total;


  @override
  void initState() { 
        fees = this.percentage(15, double.parse(this.widget.vendor.totalPrice));
        total = double.parse(this.widget.vendor.totalPrice) - fees;
        Future.delayed(Duration.zero, (){
        final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
          this.orderSubscription = databaseService.getOrderSeller(this.widget.vendor.id, this.order);
          notificationIncoming.onData((data) {
              databaseService.cleanNotificationSeller(this.widget.vendor.id).then((value) => databaseService.loadSellerOrders());
          });
    });
    super.initState();
    
  }


  @override
  void dispose() { 
    this.orderSubscription.cancel();
    this.notificationIncoming.cancel();
    this.order.close();
    super.dispose();
  }

  Future<Room> createRoom(GraphQLClient client, String user1, String user2) async {
    final MutationOptions _options  = MutationOptions(
          documentNode: gql(r"""
            mutation CreateChatRoom($user1: String!, $user2: String!, $uid: String!){
                  createChatRoom(user1:$user1 , user2: $user2, uid: $uid){
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
            "user2": user2,
            "uid": user2
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
 bool isLoading = false;



  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    
      return Scaffold(
        appBar: TopBarWitBackNav(
                          title: "ref:" + this.widget.vendor.shortId,
                          rightIcon: CupertinoIcons.chat_bubble,
                          isRightIcon: false,
                          height: 54
                          ),
        body: Center(
          child: ListView(
            children: [
              Visibility(visible: this.isLoading, child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
              Divider(),

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

              SizedBox(height:15),

              ListTile(
                autofocus: false,
                leading: Lottie.asset('assets/lottie/lf30_KvGsoi.json', height: 140, repeat: true),
                title: Text("La santé des membres de notre communauté nous est importante , c’est pourquoi nous vous rappelons qu’il est important de porter vos équipements de cuisine (masques, gants, charlottes ) quand vous cuisinez pour un membre.", style: GoogleFonts.montserrat(fontSize:13)),
                
              ),


             SizedBox(height:10),

             ListTile(
               autofocus: false,
               leading: Text("À livrer: ", style: GoogleFonts.montserrat(fontSize: 18))
             ),

              ListTile(
                autofocus: false,
                leading: Icon(CupertinoIcons.location),
                title: Text(this.widget.vendor.adress.title, style: GoogleFonts.montserrat()),
                
              ),

              ListTile(
                autofocus: false,
                leading: Text("x" + this.widget.vendor.quantity.toString(), style: GoogleFonts.montserrat(fontSize: 20, color: Colors.green)),
                title: Text(this.widget.vendor.publication.title, style: GoogleFonts.montserrat()),
                trailing: Text(this.widget.vendor.totalPrice + " " + CurrencyService.getCurrencySymbol(this.widget.vendor.currency) , style: GoogleFonts.montserrat(fontSize: 20)),
              ),

              ListTile(
                autofocus: false,
                leading: Icon(CupertinoIcons.exclamationmark_circle),
                title: Text("Frais d'applicaton", style: GoogleFonts.montserrat()),
                trailing: Text(this.fees.toString() + " " + CurrencyService.getCurrencySymbol(this.widget.vendor.currency) , style: GoogleFonts.montserrat(fontSize: 20)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Ce montant represente les frais prélévés dans le cadre des frais d'application kookers , il represente 15% du prix de chaque plat vendu et est degressif en fonction de la quantité vendu.",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 10))),
              ),

              SizedBox(height: 10),

            ListTile(
              autofocus: false,
        leading: Icon(CupertinoIcons.calendar),
        title: Text(Jiffy(this.widget.vendor.deliveryDay).format("do MMMM yyyy [ À ] HH:mm"), style: GoogleFonts.montserrat(),),
            ),

              ListTile(
                autofocus: false,
                leading: Text("Vous recevrez: ", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                trailing: Text(this.total.toString() + " " + CurrencyService.getCurrencySymbol(this.widget.vendor.currency), style: GoogleFonts.montserrat(fontSize: 24, color: Colors.green)),
              ),

              Divider(),


             
             
              ListTile(
                autofocus: false,
                    onTap: (){
                            setState((){
                              this.isLoading = true;
                            });
                            this.createRoom(databaseService.client, this.widget.vendor.buyerID, databaseService.user.value.id).then((result) async {
                              await databaseService.loadrooms();
                              setState(() {
                                this.isLoading = false;
                              });
                              Navigator.push(context,
                            CupertinoPageRoute(
                              builder: (context) => ChatPage(room: result, uid: databaseService.user.value.id)));
                            }).catchError((onError) {
                              setState(() {
                                this.isLoading = false;
                              });
                            });
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  radius: 25,
                backgroundImage:
                    CachedNetworkImageProvider(this.widget.vendor.buyer.photoUrl),
              ),

              title: Text(this.widget.vendor.buyer.firstName + " " + this.widget.vendor.buyer.lastName),
              trailing: Icon(CupertinoIcons.chat_bubble),

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