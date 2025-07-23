import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/Ratings/RatingModel.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';


class RatePlate extends StatefulWidget {
  final Order order;
  RatePlate({Key? key, required this.order}) : super(key: key);

  @override
  _RatePlateState createState() => _RatePlateState();
}

class _RatePlateState extends State<RatePlate> {

Future<void> rateFood(GraphQLClient client, RatingInput rating) async {
  
  final MutationOptions _options  = MutationOptions(document: gql(r"""
          mutation CreatRating($rating: RatingInput!){
                createRating(rating: $rating){
                  orderId
                }
            }
        """),
        variables:  <String, dynamic> {
          "rating": rating.toJSON()
        }
      );

    return await client.mutate(_options).then((result) => result.data?["createRating"]);
}


BehaviorSubject<double> initialRate = BehaviorSubject<double>.seeded(3.0);
BehaviorSubject<String> comment = BehaviorSubject<String>();
  StreamButtonController _streamButtonController = StreamButtonController();


  @override
  void dispose() {
    this.initialRate.close();
    this.comment.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
        return Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                  decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                height: 7, width: 80
              ),
            ),

              SizedBox(height: 90),

                Flexible(
                    child: ListView(
                    children: [
                      Container(
                        child: CircleAvatar(
                            radius: 60,
                            backgroundImage: CachedNetworkImageProvider(
                                (this.widget.order.publication?.imagesUrls?.isNotEmpty == true ? this.widget.order.publication!.imagesUrls![0] : '') as String),
                          ),
                      ),

                                        SizedBox(height: 40),

                  Align(
                    alignment: Alignment.center,
                    child: StreamBuilder<double>(
                      stream: this.initialRate,
                      builder: (context, snapshot) {
                        return RatingBar.builder(
                                  initialRating: this.initialRate.value,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 35,
                                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    CupertinoIcons.star_fill,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: this.initialRate.add
                              );
                      }
                    )
                  ),

                  SizedBox(height:40),

                    StreamBuilder<String>(
                      stream: this.comment,
                      builder: (context, snapshot) {
                        return TextField(
                              minLines: 1,
                              maxLines: 5,
                              onChanged: this.comment.add,
                              decoration: InputDecoration(
                              hintText: 'Ajouter un commentaire',
                              fillColor: Colors.grey[200],
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              ),
                              
                        );
                      }
                    ),


              SizedBox(height: 100),


              StreamButton(buttonColor: Colors.black,
                                     buttonText: "Noter le plat",
                                     errorText: "Une erreur s'est produite",
                                     loadingText: "Notation en cours",
                                     successText: "Plat noté",
                                      controller: _streamButtonController, onClick: () async {
                                        _streamButtonController.isLoading();
                                        RatingInput rating = RatingInput(comment: comment.value ?? '', createdAt: DateTime.now().toIso8601String() , orderId: this.widget.order.id ?? '', publicationId: this.widget.order.publication?.id ?? '', rate: initialRate.value.toString(), whoRate: databaseService.user.value?.id ?? '');
                                        this.rateFood(databaseService.client, rating).then((value){
                                          _streamButtonController.isSuccess().then((value) async {
                                            databaseService.loadbuyerOrders();
                                            await _streamButtonController.isSuccess();
                                            Navigator.pop(context);
                                          });
                                          
                                        }).catchError((onError) {
                                          _streamButtonController.isError();
                                        });
                                        
                                  }),
                    ],
                  ),
                ),



              
            ],
          )
      ),
    );

  }
}