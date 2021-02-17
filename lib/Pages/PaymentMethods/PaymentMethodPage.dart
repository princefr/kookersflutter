import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/external/platform_check/platform_check.dart';
import 'package:kookers/Pages/PaymentMethods/CreditCardItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StripeServices.dart';
import 'package:kookers/Widgets/EmptyView.dart';
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
      return WillPopScope(
        onWillPop: () async {
          if(PlatformCheck.isAndroid) return false;
          return true;
        },
              child: Scaffold(
          appBar: TopBarWitBackNav(title: "Methodes de paiements", height: 54, rightIcon: CupertinoIcons.plus, isRightIcon: true, onTapRight: (){
                    stripeService.registrarCardWithForm().then((paymentMethod) {
                      databaseService.addattachPaymentToCustomer(paymentMethod.id).then((value) {
                        databaseService.updatedDefaultSource(paymentMethod.id).then((value){
                          databaseService.user.value.defaultSource = paymentMethod.id;
                          databaseService.loadUserData();
                        });
                      });
                    }).catchError((onError){
                      print(onError);
                    });
                  }),
                body: SmartRefresher(
                  onRefresh: () async {
                                  await databaseService.loadUserData();
                                  this._refreshController.refreshCompleted();
                              },
                            controller: this._refreshController,
                            enablePullDown: true,
                            enablePullUp: false,
                  child: StreamBuilder(
                  stream: databaseService.user$,
                  builder: (context, AsyncSnapshot<UserDef> snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                      if(snapshot.hasError) return Text("i've a bad felling");
                      if(snapshot.data.allCards.isEmpty) return EmptyViewElse(text: "Vous n'avez pas de cartes.");
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data.allCards.map((e) => CardItem(card: e, isDefault: databaseService.user.value.defaultSource == e.id ? true : false, onCheckBoxClicked: () {
                      databaseService.user.value.defaultSource = e.id;
                      databaseService.updatedDefaultSource(e.id);
                      databaseService.loadUserData();
                          },)).toList(),
                        );
                  }
                      ),
                )
        ),
      );

  }
}