


import 'package:kookers/Mixins/OrderValidation.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:rxdart/rxdart.dart';

class OrderProvider with OrderValidation {


  OrderProvider();

    void dispose (){
    this.quantity.close();
    this.deliveryDate.close();
  }

  BehaviorSubject<int> quantity = new BehaviorSubject<int>.seeded(0);
  Stream<int> get quantity$ => quantity.stream.transform(validateQuantity);
  Sink<int> get inQuantity => quantity.sink;



  BehaviorSubject<DateTime> deliveryDate = new BehaviorSubject<DateTime>.seeded(DateTime.now().add(Duration(hours: 3)));
  Stream<DateTime> get deliveryDate$ => deliveryDate.stream;
  Sink<DateTime> get inDeliveryDate => deliveryDate.sink;


  Stream<bool> hasCard(BehaviorSubject<UserDef> user) => user.map((event) => event.allCards.isEmpty);




  Stream<bool> get isAllFilled$ => CombineLatestStream([quantity$], (values) => true).asBroadcastStream();
  
  Future<OrderInput> validate(DatabaseProviderService database, PublicationHome publication, int total) async {
   final order =  OrderInput(productId: publication.id, quantity: this.quantity.value, totalPrice: total.toString(),  buyerID: database.user.value.id, orderState: "NOT_ACCEPTED", sellerId: publication.seller.id, deliveryDay: deliveryDate.value.toIso8601String(), sellerStAccountid: "acct_1BZhCVFQoUnpFDpj", paymentMethodAssociated: database.user.value.defaultSource, currency: database.user.value.currency);
   return order;
  }



}