import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/FullScreenImage.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Ratings/RatePlate.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/KookersButton.dart';
import 'package:kookers/Widgets/StatusChip.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:kookers/Pages/Reports/ReportPage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class OrderPageChild extends StatefulWidget {
  final Order order;
  OrderPageChild({Key key, @required this.order}) : super(key: key);

  @override
  _OrderPageChildState createState() => _OrderPageChildState();
}

class _OrderPageChildState extends State<OrderPageChild> {


  StreamSubscription<Order> orderSubscription;
  // ignore: close_sinks
  BehaviorSubject<Order>  order = new BehaviorSubject<Order>();


  @override
  void initState() { 
      Future.delayed(Duration.zero, (){
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
          this.orderSubscription = databaseService.getOrderBuyer(this.widget.order.id, this.order);
    });
    super.initState();
    
  }



  @override
  void dispose() { 
    this.orderSubscription.cancel();
    this.order.close();
    super.dispose();
  }

    List<String> tagfood = ['Végétarien', 'Vegan'];
    List<String> foodpreferences = [
    'Végétarien', 'Vegan', 'Sans gluten',
      'Hallal', 'Adapté aux allergies alimentaires'
    ];


Future<Map<String, dynamic>> cancelOrder(GraphQLClient client, Order order) async {
final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation CancelOrder($order: OrderInputBuyer!){
              cancelOrder(order: $order){
                _id
              }
          }
      """),
      variables:  <String, dynamic> {
        "order": order.toJSON()
      }
    );

    return await client.mutate(_options).then((result) => result.data["cancelOrder"]);
}

Future<Map<String, dynamic>> doneOrder(GraphQLClient client, Order order) async {
final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation ValidateOrder($order: OrderInputBuyer!){
              validateOrder(order: $order){
                _id
              }
          }
      """),
      variables:  <String, dynamic> {
        "order": order.toJSON()
      }
    );

    return await client.mutate(_options).then((result) => result.data["validateOrder"]);
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

  String subscribeToOrderUpdate = r"""
      subscription orderUpdated($id: ID!)  {
        orderUpdated(id: $id) {
          orderState
        }
      }
""";

 StreamButtonController _streamButtonController = StreamButtonController();
 StreamButtonController _streamButtonController2 = StreamButtonController();
  StreamButtonController _streamButtonController3 = StreamButtonController();




  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);

         return Scaffold(
           appBar: TopBarWitBackNav(
              title: this.widget.order.publication.title,
              rightIcon: CupertinoIcons.exclamationmark_circle_fill,
              isRightIcon: true,
              height: 54,
              onTapRight: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      builder: (context) => ReportPage(publicatonId: this.widget.order.publication.id, seller: this.widget.order.seller.id),
                    );
              }),
      body: Container(
        child: Column(children: [

          Expanded(
              child: ListView(
                children: [
                  CarouselSlider(items: this.widget.order.publication.imagesUrls.map((e) {
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


                 Row(children: [
                    Expanded(
                      child:
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("15 €", style:  GoogleFonts.montserrat(fontSize: 26, color: Colors.grey)),
                      )
                    ),

                    StreamBuilder<Order>(
                        stream: this.order.stream,
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting) return Text("nope");
                          return StatusChip(state: snapshot.data.orderState);
                        }
                      ),

                      SizedBox(width:5)
                  ],),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(this.widget.order.publication.description),
                  ),

                                Container(
                height: 40,
                child: Builder(builder: (BuildContext ctx) {
                  if(this.widget.order.publication.preferences.any((element) => element.isSelected == true)){
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: this.widget.order.publication.preferences.where((element) => element.isSelected == true).toList().length,
                      itemBuilder: (ctx, index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5, top: 3),
                          child: Container(
                                  decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ), padding: EdgeInsets.all(10), child: Text(this.widget.order.publication.preferences.where((element) => element.isSelected == true).elementAt(index).title)),
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
                    onTap: (){
                      this.createRoom(databaseService.client, this.widget.order.sellerId, databaseService.user.value.id).then((result) async {
                        await databaseService.loadrooms();
                        Navigator.push(context,
                            CupertinoPageRoute(
                              builder: (context) => ChatPage(room: result, uid: databaseService.user.value.id)));
                      });
                    },

                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      radius: 15, backgroundImage: CachedNetworkImageProvider(this.widget.order.seller.photoUrl),),
                    trailing: Icon(CupertinoIcons.chat_bubble),
                    title: Text(this.widget.order.seller.firstName + " " + this.widget.order.seller.lastName)
                  ),

                  

                  ListTile(
                    leading: Icon(CupertinoIcons.house_alt),
                    title: Text("303 quai aux fleurs"),
                    trailing: Text(this.widget.order.deliveryDay),
                  ),

                  SizedBox(height:10),

                  ListTile(
                    leading: Icon(CupertinoIcons.chart_pie),
                    title: Text(this.widget.order.quantity.toString()),
                    trailing: Text("parts"),
                  ),

                  SizedBox(height:30),

                  StreamBuilder<Order>(
                    stream: this.order,
                    builder: (context, snapshot) {
                      return Builder(
                        // ignore: missing_return
                        builder: (context) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                                if (snapshot.hasError)
                                  return Text("i've a bad felling");
                                if (snapshot.data == null)
                                  return Text("its empty out there"); 
                          switch (snapshot.data.orderState) {
                            case OrderState.ACCEPTED:
                              return Container(child: Column(
                                children: [
                                  StreamButton(buttonColor: Color(0xFFF95F5F),
                                     buttonText: "Valider la reception",
                                     errorText: "Une erreur s'est produite",
                                     loadingText: "Validation en cours",
                                     successText: "Commande validée",
                                      controller: _streamButtonController, onClick: () async {
                                        _streamButtonController.isLoading();
                                        this.doneOrder(databaseService.client, this.widget.order).then((result) async {
                                          
                                          _streamButtonController.isSuccess();
                                          databaseService.loadbuyerOrders();
                                          
                                        }).catchError((err) {
                                          _streamButtonController.isError();
                                        });
                                        
                                        
                                  }),

                                  SizedBox(height: 30),

                                  StreamButton(buttonColor: Colors.red,
                                     buttonText: "Annuler la commande",
                                     errorText: "Une erreur s'est produite",
                                     loadingText: "Annulation en cours",
                                     successText: "Commande annulée",
                                      controller: _streamButtonController2, onClick: () async {
                                        _streamButtonController2.isLoading();
                                          this.cancelOrder(databaseService.client, this.widget.order).then((result) async {
                                            
                                            _streamButtonController2.isSuccess();
                                            databaseService.loadbuyerOrders();
                                            }).catchError((onError) {
                                              _streamButtonController2.isError();
                                          });
                                        
                                  }),
                                ]
                              ));
                              break;
                            case OrderState.CANCELLED:
                                return Text("La commande a été annulé");
                              break;
                            case OrderState.DONE:
                              return FlatButton(onPressed: (){
                                showCupertinoModalBottomSheet(
                                  expand: true,
                                  context: context,
                                  builder: (context) => RatePlate(order: this.widget.order),
                                );
                              }, child: KookersButton(text: "Noter le plat", color: Colors.black, textcolor: Colors.white));

                              break;
                            case OrderState.NOT_ACCEPTED:
                              return Column(
                                children: [
                                  Text("Commande en attente d'acceptation", style: GoogleFonts.montserrat(color: Colors.green,),),
                                  SizedBox(height: 10),
                                  StreamButton(buttonColor: Colors.red,
                                         buttonText: "Annuler la commande",
                                         errorText: "Une erreur s'est produite",
                                         loadingText: "Annulation en cours",
                                         successText: "Commande annulée",
                                          controller: _streamButtonController3, onClick: () async {
                                            _streamButtonController3.isLoading();
                                            this.cancelOrder(databaseService.client, this.widget.order).then((value) async {
                                              _streamButtonController3.isSuccess();
                                              databaseService.loadbuyerOrders();
                                            }).catchError((onError) {
                                              _streamButtonController3.isError();
                                            });
                                            
                                      }),
                                ],
                              );
                              break;
                            case OrderState.RATED:
                                return Text("La commande est livrée et livrée");
                              break;
                            case OrderState.REFUSED:
                                return Text("La commande a été annulé");
                              break;
                          }
                        },
                      );
                    }
                  )
          ]))
        ]),
      ),
    ); 
  }
}
