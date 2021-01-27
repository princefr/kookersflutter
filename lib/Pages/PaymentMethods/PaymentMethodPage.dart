import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/PaymentMethods/CreditCardItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StripeServices.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class PaymentMethodPage extends StatefulWidget {
  PaymentMethodPage({Key key}) : super(key: key);

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {


  final stripeService = StripeServices();

  @override
  void initState() {
    new Future.delayed(Duration.zero, (){
      stripeService.initiateStripe();
    });
    
    
    super.initState();
    
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);




  
  


  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
    

      return Scaffold(
        appBar: TopBarWitBackNav(title: "Methodes de paiements", height: 54, rightIcon: CupertinoIcons.plus, isRightIcon: true, onTapRight: (){
                  stripeService.registrarCardWithForm().then((paymentMethod) {
                    databaseService.addattachPaymentToCustomer(paymentMethod.id).then((value) {
                      databaseService.loadSourceList();
                      databaseService.updatedDefaultSource(paymentMethod.id).then((value){
                        databaseService.user.value.defaultSource = paymentMethod.id;
                      });
                    });
                  });
                }),
              body: StreamBuilder(
              stream: databaseService.sources$,
              builder: (context, AsyncSnapshot<List<CardModel>> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator();
                  if(snapshot.hasError) return Text("i've a bad felling");
                  if(snapshot.data.isEmpty) return Text("its empty out there");
                return SmartRefresher(
                      onRefresh: () async {
                                databaseService.loadSourceList().then((value) {
                                Future.delayed(Duration(milliseconds: 1000)).then((value) {
                                  _refreshController.refreshCompleted();
                                });
                                
                                }).catchError((onError) {
                                  print("an error hapenned");
                                });
                                
                          },
                        controller: this._refreshController,
                        enablePullDown: true,
                        enablePullUp: false,
                        child: ListView(
                          children: snapshot.data.map((e) => CardItem(card: e, isDefault: databaseService.user.value.defaultSource == e.id ? true : false, onCheckBoxClicked: () {
                          setState(() {
                              databaseService.user.value.defaultSource = e.id;
                            });
                          databaseService.updatedDefaultSource(e.id);
                          databaseService.loadSourceList();
                      },)).toList(),
                    ),
                );
              }
                  )
      );

  }
}