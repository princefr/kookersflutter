import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Ratings/RatePlate.dart';
import 'package:kookers/Services/CurrencyService.dart';
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
  OrderPageChild({Key? key, required this.order}) : super(key: key);

  @override
  _OrderPageChildState createState() => _OrderPageChildState();
}

class _OrderPageChildState extends State<OrderPageChild> {
  StreamSubscription<Order>? orderSubscription;
  // ignore: close_sinks
  BehaviorSubject<Order> order = new BehaviorSubject<Order>();

  double percentage(percent, total) {
    return ((percent/ 100) * total);
  }

  StreamSubscription<int?> get notificationIncoming => this.order.where((event) => (event.notificationBuyer ?? 0) > 0).map((event) => event.notificationBuyer).listen((event) => event);

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      this.orderSubscription =
          databaseService.getOrderBuyer(this.widget.order.id ?? '', this.order);
          notificationIncoming.onData((data) {
            databaseService.cleanNotificationBuyer(this.widget.order.id ?? '').then((value) => databaseService.loadbuyerOrders());
          });
          
    });
    super.initState();
  }

  @override
  void dispose() {
    this.orderSubscription?.cancel();
    this.notificationIncoming.cancel();
    this.order.close();
    super.dispose();
  }

  List<String> tagfood = ['Végétarien', 'Vegan'];
  List<String> foodpreferences = [
    'Végétarien',
    'Vegan',
    'Sans gluten',
    'Hallal',
    'Adapté aux allergies alimentaires'
  ];

  Future<Map<String, dynamic>> cancelOrder(
      GraphQLClient client, Order order) async {
    final MutationOptions _options = MutationOptions(document: gql(r"""
        mutation CancelOrder($order: OrderInputBuyer!){
              cancelOrder(order: $order){
                _id
              }
          }
      """), variables: <String, dynamic>{"order": order.toJSON()});

    return await client
        .mutate(_options)
        .then((result) => result.data?["cancelOrder"]);
  }

  Future<Map<String, dynamic>> doneOrder(
      GraphQLClient client, Order order) async {
    final MutationOptions _options = MutationOptions(document: gql(r"""
        mutation ValidateOrder($order: OrderInputBuyer!){
              validateOrder(order: $order){
                _id
              }
          }
      """), variables: <String, dynamic>{"order": order.toJSON()});

    return await client
        .mutate(_options)
        .then((result) => result.data?["validateOrder"]);
  }

  Future<Room> createRoom(
      GraphQLClient client, String user1, String user2) async {
    final MutationOptions _options = MutationOptions(document: gql(r"""
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
          """), variables: <String, String>{
      "user1": user1,
      "user2": user2,
      "uid": user2
    });

    return client
        .mutate(_options)
        .then((result) => Room.fromJson(result.data?["createChatRoom"], user2));
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
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    return Scaffold(
      appBar: TopBarWitBackNav(
          title: "ref:" + " " + (this.widget.order.shortId ?? ''),
          rightIcon: CupertinoIcons.exclamationmark_circle_fill,
          isRightIcon: true,
          height: 54,
          onTapRight: () {
            showCupertinoModalBottomSheet(
              expand: false,
              context: context,
              builder: (context) => ReportPage(
                  publicatonId: this.widget.order.publication?.id ?? '',
                  seller: this.widget.order.seller?.id ?? ''),
            );
          }),
      body: Container(
        child: ListView(
          children: [
               Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: SizedBox(),),
                      StreamBuilder<Order>(
              stream: this.order.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Text("nope");
                return StatusChip(state: snapshot.data!.orderState ?? OrderState.NOT_ACCEPTED);
              }),
                    ],
                  ),
                ),


              SizedBox(height: 10),

              ListTile(
                autofocus: false,
                leading: Icon(CupertinoIcons.location),
                title: Text(this.widget.order.adress?.title ?? '', style: GoogleFonts.montserrat()),
                
              ),

              ListTile(
                autofocus: false,
                leading: Text("x" + this.widget.order.quantity.toString(), style: GoogleFonts.montserrat(fontSize: 20, color: Colors.green)),
                title: Text(this.widget.order.publication?.title ?? '', style: GoogleFonts.montserrat()),
                trailing: Text((this.widget.order.totalPrice ?? '') + " " + CurrencyService.getCurrencySymbol(this.widget.order.currency ?? '') , style: GoogleFonts.montserrat(fontSize: 20)),
              ),

              ListTile(
                autofocus: false,
                leading: Icon(CupertinoIcons.exclamationmark_circle),
                title: Text("Frais de service", style: GoogleFonts.montserrat()),
                trailing: Text((this.widget.order.fees ?? '') + " " + CurrencyService.getCurrencySymbol(this.widget.order.currency ?? '') , style: GoogleFonts.montserrat(fontSize: 20)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Ce montant représente la somme que vous paierez en guise de frais de service de l'application. Le montant maximum que vous paierez dans l'application ne dépassera jamais 2€.",
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 10))),
              ),

              SizedBox(height: 10),

            ListTile(
              autofocus: false,
        leading: Icon(CupertinoIcons.calendar),
        title: Text(Jiffy.parse(this.widget.order.deliveryDay ?? '').format(pattern: "do MMMM yyyy [ À ] HH:mm"), style: GoogleFonts.montserrat(),),
            ),

              ListTile(
                autofocus: false,
                leading: Text("Total Payé: ", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                trailing: Text((this.widget.order.totalWithFees ?? '') + " " + CurrencyService.getCurrencySymbol(this.widget.order.currency ?? ''), style: GoogleFonts.montserrat(fontSize: 24, color: Colors.green)),
              ),

              Divider(),

            ListTile(
              autofocus: false,
          onTap: () {
            this
                .createRoom(
                    databaseService.client,
                    this.widget.order.sellerId ?? '',
                    databaseService.user.value?.id ?? '')
                .then((result) async {
              await databaseService.loadrooms();
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => ChatPage(
                          room: result,
                          uid: databaseService.user.value?.id ?? '')));
            });
          },
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            radius: 15,
            backgroundImage: this.widget.order.seller?.photoUrl != null ? CachedNetworkImageProvider(
                this.widget.order.seller!.photoUrl!) : null,
          ),
          trailing: Icon(CupertinoIcons.chat_bubble),
          title: Text((this.widget.order.seller?.firstName ?? '') +
              " " +
              (this.widget.order.seller?.lastName ?? ''))),


            SizedBox(height: 100),
            StreamBuilder<Order>(
          stream: this.order,
          builder: (context, snapshot) {
            return Builder(
              // ignore: missing_return
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return LinearProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white));
                if (snapshot.hasError) return Text("i've a bad felling");
                if (snapshot.data == null)
                  return Text("its empty out there");
                switch (snapshot.data!.orderState) {
                  case OrderState.ACCEPTED:
                    return Container(
                        child: Column(children: [
                      StreamButton(
                          buttonColor: Color(0xFFF95F5F),
                          buttonText: "Valider la reception",
                          errorText: "Une erreur s'est produite",
                          loadingText: "Validation en cours",
                          successText: "Commande validée",
                          controller: _streamButtonController,
                          onClick: () async {
                            _streamButtonController.isLoading();
                            this
                                .doneOrder(databaseService.client,
                                    this.widget.order)
                                .then((result) async {
                              _streamButtonController.isSuccess();
                              databaseService.loadbuyerOrders();
                            }).catchError((err) {
                              _streamButtonController.isError();
                            });
                          }),
                      SizedBox(height: 30),
                      StreamButton(
                          buttonColor: Colors.red,
                          buttonText: "Annuler la commande",
                          errorText: "Une erreur s'est produite",
                          loadingText: "Annulation en cours",
                          successText: "Commande annulée",
                          controller: _streamButtonController2,
                          onClick: () async {
                            _streamButtonController2.isLoading();
                            this
                                .cancelOrder(databaseService.client,
                                    this.widget.order)
                                .then((result) async {
                              _streamButtonController2.isSuccess();
                              databaseService.loadbuyerOrders();
                            }).catchError((onError) {
                              _streamButtonController2.isError();
                            });
                          }),
                    ]));
                  case OrderState.CANCELLED:
                    return Center(
                      child: Text("La commande a été annulé",
                            style: GoogleFonts.montserrat(
                              fontSize: 17
                            )),
                    );
                  case OrderState.DONE:
                    return TextButton(
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                            expand: true,
                            context: context,
                            builder: (context) =>
                                RatePlate(order: this.widget.order),
                          );
                        },
                        child: KookersButton(
                            text: "Noter le plat",
                            color: Colors.black,
                            textcolor: Colors.white));
                  case OrderState.NOT_ACCEPTED:
                    return Column(
                      children: [
                        Center(
                          child: Text(
                            "Commande en attente d'acceptation",
                            style: GoogleFonts.montserrat(
                              fontSize: 17
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        StreamButton(
                            buttonColor: Colors.red,
                            buttonText: "Annuler la commande",
                            errorText: "Une erreur s'est produite",
                            loadingText: "Annulation en cours",
                            successText: "Commande annulée",
                            controller: _streamButtonController3,
                            onClick: () async {
                              _streamButtonController3.isLoading();
                              this
                                  .cancelOrder(databaseService.client,
                                      this.widget.order)
                                  .then((value) async {
                                _streamButtonController3.isSuccess();
                                databaseService.loadbuyerOrders();
                              }).catchError((onError) {
                                _streamButtonController3.isError();
                              });
                            }),
                      ],
                    );
                  case OrderState.RATED:
                    return Center(
                      child: Text("La commande est livrée",
                            style: GoogleFonts.montserrat(
                              fontSize: 17
                            )),
                    );
                  case OrderState.REFUSED:
                    return Center(
                      child: Text("La commande a été annulé",
                            style: GoogleFonts.montserrat(
                              fontSize: 17
                            )),
                    );
                  default:
                    return SizedBox();
                }
              },
            );
          })
          ]),
      ),
    );
  }
}
