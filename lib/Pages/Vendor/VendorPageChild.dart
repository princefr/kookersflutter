
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';

class VendorPageChild extends StatefulWidget {
  final OrderVendor vendor;
  VendorPageChild({Key key, this.vendor}) : super(key: key);

  @override
  _VendorPageChildState createState() => _VendorPageChildState();
}

class _VendorPageChildState extends State<VendorPageChild> {

  Future<Room> createRoom(GraphQLClient client, String user1, String user2) async {
    final MutationOptions _options  = MutationOptions(
          documentNode: gql(r"""
            mutation CreateChatRoom($user1: String!, $user2: String!){
                  createChatRoom(user1:$user1 , user2: $user2){
                              _id
                              updateAt
                              notificationCountUser_1
                              
                              receiver {
                                  first_name
                                  last_name
                                  phonenumber
                              }
                              
                              messages {
                                  userId
                                  message
                                  createdAt
                                  message_picture
                              }
                }
              }
          """),
          variables:  <String, String> {
            "user1": user1,
            "user2": user2
          }
        );

        return client.mutate(_options).then((result) => Room.fromJson(result.data["createChatRoom"]));
}


Future<Map<String, dynamic>> refuseOrder(GraphQLClient client, OrderVendor order) async {
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

    return await client.mutate(_options).then((result) => result.data);
}


Future<Map<String, dynamic>> acceptOrder(GraphQLClient client, OrderVendor order) async {
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

    return await client.mutate(_options).then((result) => result.data);
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


  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
        appBar: TopBarWitBackNav(
                          title: this.widget.vendor.deliveryDay,
                          rightIcon: CupertinoIcons.chat_bubble,
                          isRightIcon: true,
                          height: 54,
                          onTapRight: () {
                            
                            this.createRoom(client, this.widget.vendor.buyerID, databaseService.user.value.id).then((result) => Navigator.push(context,
                            CupertinoPageRoute(
                              builder: (context) => ChatPage(room: result))));
                          }),
        body: Center(
          child: ListView(
            children: [
              Builder(builder: (ctx) {
                switch (this.widget.vendor.orderState) {
                  case "ACCEPTED":
                      return Text("plat recu par l'acheteur");
                    break;
                  case "CANCELLED":
                      return Text("le plat a été annulé par l'acheteur");
                    break;
                  case "DONE":
                    return Text("plat recu par l'acheteur");
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
                                    this.acceptOrder(client, this.widget.vendor).then((result) {
                                      _streamButtonController.isSuccess();
                                      setState(() {
                                        this.widget.vendor.orderState = result["orderState"];
                                      });
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
                                    this.refuseOrder(client, this.widget.vendor).then((result) {
                                      _streamButtonController2.isSuccess();
                                      this.widget.vendor.orderState = result["orderState"];
                                    }).catchError((onError) {
                                      _streamButtonController2.isError();
                                    });
                                    
                      }),

                    ]));
                    
                    break;
                  case "RATED":
                    return Text("le plat est livré et noté");
                    break;

                  case "REFUSED":
                    return Text("Vous avez refusé la commande.");
                    
                    break;

                    
                    
                  default:
                  return Text("");
                }
              })
            ],
          )
        ),
      );

    });
  }
}