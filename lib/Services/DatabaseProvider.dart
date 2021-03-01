import 'dart:async';
import 'dart:io';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kookers/Env/Environment.dart';
import 'package:kookers/GraphQlHelpers/ClientProvider.dart';
import 'package:kookers/Pages/Balance/BalancePage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/PaymentMethods/CreditCardItem.dart';
import 'package:kookers/Widgets/ButtonVerification.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';


class Location {
  double latitude;
  double longitude;
  Location({this.latitude, this.longitude});
}


class RatingPublication{
    double ratingTotal;
    int ratingCount;
    RatingPublication({this.ratingCount, this.ratingTotal});
}

class Adress {
  String title;
  Location location;
  bool isChosed;
  static List<Adress> allAdress;
  Adress({this.title,  this.location, this.isChosed});


  static Adress fromJsonOne(Map<String, dynamic> map) => Adress(
    title: map['title'],
    location: Location(latitude: map["location"]["latitude"], longitude: map["location"]["longitude"]),
  );
  

  static List<Adress> fromJson(List<Object> map) {
    List<Adress> adresses = [];
  
    map.forEach((element) {
      final adress = element as Map<String, dynamic>;
      adresses.add(Adress(
        title: adress["title"],
        location: Location(latitude: adress["location"]["latitude"], longitude: adress["location"]["longitude"]),
        isChosed : adress["is_chosed"]
      ));
    });
    Adress.allAdress = adresses;
    return adresses;
  }

  Map<String, dynamic> toJSON(){
    final adress = Map<String, dynamic>();
    adress["title"] = this.title;
    adress["is_chosed"] = this.isChosed;
    adress["location"] = {"latitude": this.location.latitude, "longitude": this.location.longitude};
    return adress;

  }

  void toogle(){
    this.isChosed = !this.isChosed;
  }

  static List<Map<String, Object>> toJson(List<Adress> allAdress) {
    return allAdress.map((e) => {"title": e.title, "is_chosed": e.isChosed, "location": {"longitude": e.location.longitude, "latitude": e.location.latitude}}).toList();
  }
}




class UserSettings {
  int distanceFromSeller;
  List<String> foodPreference;
  List<String> foodPriceRange;
  String createdAt;
  String updatedAt;
  UserSettings({this.distanceFromSeller, this.foodPreference, this.foodPriceRange, this.createdAt, this.updatedAt});
  
  static UserSettings fromJson(Map<String, dynamic> map) => UserSettings(
    distanceFromSeller: map['distance_from_seller'],
    foodPreference: List<String>.from(map["food_preferences"]),
    foodPriceRange: List<String>.from(map["food_price_ranges"]),
    updatedAt: map['updatedAt'],
    createdAt: map['createdAt']
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["distance_from_seller"] = this.distanceFromSeller;
    data["createdAt"] = this.createdAt;
    data["updatedAt"] = DateTime.now().toIso8601String();
    data["food_preferences"] = this.foodPreference;
    data["food_price_ranges"] = this.foodPriceRange;
    return data;
  }
}

class StripeRequirements {
       List<String> currentlyDue;
       List<String> eventuallyDue;
       List<String> pastDue;
       List<String> pendingVerification;
       String disabledReason;
       int currentDeadline;
       ButtonVerificationState idStatus;
       ButtonVerificationState residenceProof;
       StripeRequirements({this.currentlyDue, this.eventuallyDue, this.pastDue, this.pendingVerification,this.disabledReason, this.currentDeadline, this.idStatus, this.residenceProof});

       static StripeRequirements fromJson(Map<String, dynamic> map) => StripeRequirements(
         currentlyDue: List<String>.from(map["currently_due"].map((string) => string)),
         eventuallyDue: List<String>.from(map["eventually_due"].map((string) => string)),
         pastDue: List<String>.from(map["past_due"].map((string) => string)),
         pendingVerification: List<String>.from(map["pending_verification"].map((string) => string)),
         disabledReason: map["disabled_reason"],
         currentDeadline: map["current_deadline"],
         idStatus: StripeRequirements.buildIdStatus(map),
         residenceProof: StripeRequirements.buildResidenceStatus(map)
       );

      static ButtonVerificationState buildIdStatus(Map<String, dynamic> map){
        final pending = List<String>.from(map["pending_verification"].map((string) => string));
        final currently = List<String>.from(map["currently_due"].map((string) => string));
        final eventually = List<String>.from(map["eventually_due"].map((string) => string));
        if(!pending.contains("individual.verification.document") && !currently.contains("individual.verification.document") && !eventually.contains("individual.verification.document")){
          return ButtonVerificationState.Verified; 
        }
        else if(pending.contains("individual.verification.document")){
          return ButtonVerificationState.VerificationInProgress;
        }
        return ButtonVerificationState.Missing;
      }


    static ButtonVerificationState buildResidenceStatus(Map<String, dynamic> map){
        final pending = List<String>.from(map["pending_verification"].map((string) => string));
        final currently = List<String>.from(map["currently_due"].map((string) => string));
        final eventually = List<String>.from(map["eventually_due"].map((string) => string));
      if(!pending.contains("individual.verification.additional_document") && !currently.contains("individual.verification.additional_document") && !eventually.contains("individual.verification.additional_document")){
        return ButtonVerificationState.Verified; 
      }
      else if(pending.contains("individual.verification.additional_document")){
        return ButtonVerificationState.VerificationInProgress;
      }
      return ButtonVerificationState.Missing;
    }

}


class StripeAccount{
  bool chargesEnabled;
  bool payoutsEnabled;
  StripeRequirements stripeRequirements;
  StripeAccount({this.chargesEnabled, this.payoutsEnabled, this.stripeRequirements});
}




class UserDef {
 String id;
 String email;
 String firstName;
 String lastName;
 String phonenumber;
 String fcmToken;
 UserSettings settings;
 List<Adress> adresses;
 String photoUrl;
 String customerId;
 String currentAdress;
 String createdAt;
 String updatedAt;
 String defaultSource;
 String country;
 String currency;
 String defaultIban;
 String stripeaccountId;
 StripeAccount stripeAccount;
 List<Transaction> transactions;
 Balance balance;
 List<BankAccount> ibans;
 List<CardModel> allCards;
 bool isSeller;


 UserDef({this.id, this.email, this.firstName, this.lastName, this.phonenumber, this.fcmToken, this.settings, this.adresses,
  this.photoUrl, this.customerId, this.createdAt, this.updatedAt, this.defaultSource, this.country, this.currency,
   this.stripeaccountId, this.defaultIban, this.stripeAccount, this.transactions, this.balance, this.ibans, this.allCards, this.isSeller});
 
  static UserDef fromJson(Map<String, dynamic> map) => UserDef (
  id: map["_id"],
  email: map["email"],
  firstName: map["first_name"],
  lastName: map["last_name"],
  phonenumber: map["phonenumber"],
  settings: UserSettings.fromJson(map["settings"]),
  adresses: Adress.fromJson(map["adresses"]),
  fcmToken: map["fcmToken"],
  photoUrl: map["photoUrl"],
  customerId: map["customerId"],
  createdAt: map["createdAt"],
  updatedAt: map["updatedAt"],
  defaultSource: map["default_source"],
  country: map["country"],
  currency: map["currency"],
  stripeaccountId: map["stripe_account"],
  defaultIban: map["default_iban"],
  stripeAccount: StripeAccount(chargesEnabled: map["stripeAccount"]["charges_enabled"], payoutsEnabled: map["stripeAccount"]["payouts_enabled"], stripeRequirements: StripeRequirements.fromJson(map["stripeAccount"]["requirements"])),
  transactions: Transaction.fromJsonToList(map["transactions"]),
  balance: Balance.fromJson(map["balance"]),
  ibans: BankAccount.fromJsonToList(map["ibans"]),
  allCards: CardModel.fromJsonTolist(map["all_cards"]),
  isSeller: map["is_seller"]
);
}




class SellerDef {
  String id;
  String email;
  String firstName;
  String lastName;
  String fcmToken;
  String photoUrl;
  SellerDef({this.id, this.firstName, this.email, this.lastName, this.fcmToken, this.photoUrl});
  static SellerDef fromJson(Map<String, dynamic> map) => SellerDef(
    id: map["_id"],
    email: map["email"],
    firstName: map["first_name"],
    lastName: map["last_name"],
    fcmToken: map["fcmToken"],
    photoUrl: map["photoUrl"]
  );
}


class BuyerVendor{
  String id;
  String firstName;
  String lastName;
  String photoUrl;
  String fcmToken;
  
  BuyerVendor({this.id, this.firstName, this.lastName, this.photoUrl, this.fcmToken});
  static BuyerVendor fromJson(Map<String, dynamic> data) => BuyerVendor(
    id: data['_id'],
    firstName: data['first_name'],
    lastName: data["last_name"],
    photoUrl: data["photoUrl"],
    fcmToken: data["fcmToken"]

  );

}


class OrderVendor {
  String id;
  String productId;
  String quantity;
  String totalPrice;
  String buyerID;
  String deliveryDay;
  String orderState;
  String sellerId;
  String sellerStAccountid;
  String paymentMethodAssociated;
  String currency;
  int  notificationSeller;
  PublicationVendor publication;
  String stripeTransactionId;
  BuyerVendor buyer;
  Adress adress;
  String createdAt;
  String updatedAt;
  String shortId;
  String fees;
  String totalWithFees;

  OrderVendor({@required this.productId, @required this.quantity, @required this.totalPrice,
   @required this.buyerID, @required this.orderState, @required this.sellerId, @required this.deliveryDay, @required this.sellerStAccountid, @required this.paymentMethodAssociated, @required this.currency,
    this.publication, this.buyer, this.id, this.stripeTransactionId,  this.notificationSeller, this.adress, this.createdAt, this.updatedAt, this.shortId, this.fees, this.totalWithFees});

  static OrderVendor fromJson(Map<String, dynamic> data) => OrderVendor(
    productId: data["productId"],
    quantity: data["quantity"],
    totalPrice: data["total_price"], 
    buyerID: data["buyerID"],
    deliveryDay: data["deliveryDay"],
    orderState: data["orderState"],
    sellerId: data["sellerId"],
    sellerStAccountid: data["seller_stripe_account"],
    paymentMethodAssociated: data["payment_method_id"],
    currency: data["currency"],
    stripeTransactionId: data["stripeTransactionId"],
    publication: PublicationVendor.fromJson(data["publication"]),
    buyer: BuyerVendor.fromJson(data["buyer"]),
    id: data["_id"],
    notificationSeller: data["notificationSeller"],
    adress: Adress.fromJsonOne(data["adress"]),
    createdAt: data["createdAt"],
    updatedAt: data["updatedAt"],
    shortId: data["shortId"],
    fees: data["fees"],
    totalWithFees: data["total_with_fees"]
  );


   Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["productId"] = this.productId;
    data["quantity"] = int.parse(this.quantity);
    data["total_price"] = this.totalPrice;
    data["buyerID"] = this.buyerID;
    data["orderState"] = this.orderState;
    data["sellerId"] = this.sellerId;
    data["deliveryDay"] = this.deliveryDay;
    data["seller_stripe_account"] = this.sellerStAccountid;
    data["payment_method_id"] = this.paymentMethodAssociated;
    data["stripeTransactionId"] = this.stripeTransactionId;
    data["currency"] = this.currency;
    data["id"] = this.id;

    return data;
   }

    static List<OrderVendor> fromJsonToList(List<Object> map) {
      List<OrderVendor> allpublications = [];
      map.forEach((element) {
        final x = OrderVendor.fromJson(element);
        allpublications.add(x);
      });
      return allpublications;
  }

}


class PublicationVendor {
  String id;
  String title;
  String description;
  String type;
  String pricePerAll;
  List<Object> photoUrls;
  Adress adress;
  bool isOpen;
  List<String> preferences;
  String createdAt;
  RatingPublication rating;
  String currency;
  String shortId;

  PublicationVendor({this.id, this.title, this.description, this.type, this.pricePerAll, this.photoUrls, this.adress, this.isOpen, this.preferences, this.createdAt, this.rating, this.currency, this.shortId});
  

  static PublicationVendor fromJson(Map<String, dynamic> map) => PublicationVendor(
    id: map["_id"],
    title: map["title"],
    description : map["description"],
    type: map["type"],
    pricePerAll: map["price_all"].toString(),
    photoUrls: map["photoUrls"] as List<Object>,
    adress: Adress(isChosed: false, location: Location(latitude: map["adress"]["location"]["latitude"], longitude: map["adress"]["location"]["lonngitude"]), title: map["adress"]["title"]),
    isOpen: map["is_open"],
    preferences: List<String>.from(map["food_preferences"]),
    createdAt: map["createdAt"],
    rating: RatingPublication(ratingCount: int.parse(map["rating"]["rating_count"].toString()), ratingTotal: double.parse(map["rating"]["rating_total"].toString())),
    currency: map["currency"],
    shortId: map["shortId"]
  );

  static List<PublicationVendor> fromJsonToList(List<Object> map) {
    List<PublicationVendor> allpublications = [];
    map.forEach((element) {
      final x = PublicationVendor.fromJson(element);
      allpublications.add(x);
    });
    return allpublications;
  }
}


class PublicationHome {
  String id;
  String title;
  String description;
  String type;
  String pricePerAll;
  List<Object> photoUrls;
  Adress adress;
  SellerDef seller;
  List<String> preferences;
  RatingPublication rating;
  String currency;
  int likeCount;
  bool liked;

  

  PublicationHome({this.id, this.title, this.description, this.type, this.pricePerAll,  this.photoUrls, this.adress, this.seller, this.preferences, this.rating, this.currency, this.likeCount, this.liked});

  double getRating(){
    if((this.rating.ratingTotal / this.rating.ratingCount).isNaN) return 0;
    return (this.rating.ratingTotal / this.rating.ratingCount);
  }
  

  static PublicationHome fromJson(Map<String, dynamic> map) => PublicationHome(
    id: map["_id"],
    title: map["title"],
    description : map["description"],
    type: map["type"],
    pricePerAll: map["price_all"].toString(),
    photoUrls: map["photoUrls"] as List<Object>,
    adress: Adress(isChosed: false, location: Location(latitude: map["adress"]["location"]["latitude"], longitude: map["adress"]["location"]["longitude"]), title: ""),
    seller: SellerDef.fromJson(map["seller"]),
    preferences: List<String>.from(map["food_preferences"]),
    rating: RatingPublication(ratingCount: int.parse(map["rating"]["rating_count"].toString()), ratingTotal: double.parse(map["rating"]["rating_total"].toString())),
    currency: map["currency"],
    likeCount: map["likeCount"],
    liked: map["likes"]
  );

  static List<PublicationHome> fromJsonToList(List<Object> map) {
    List<PublicationHome> allpublications = [];
    map.forEach((element) {
      final x = PublicationHome.fromJson(element);
      allpublications.add(x);
    });
    return allpublications;
  }
}



  

class OrderInput {
  String productId;
  int quantity;
  String totalPrice;
  String buyerID;
  String fees;
  String totalWithFees;
  String deliveryDay;
  String orderState;
  String sellerId;
  String sellerStAccountid;
  String paymentMethodAssociated;
  String currency;
  String title;
  Adress adress;


  OrderInput({@required this.productId, @required this.quantity, @required this.totalPrice, @required this.buyerID, @required this.orderState,
   @required this.sellerId, @required this.deliveryDay, @required this.sellerStAccountid, @required this.paymentMethodAssociated, @required this.currency, this.fees, this.totalWithFees, this.title, @required this.adress});


   Map<String, dynamic> toJson(UserDef user) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["productId"] = this.productId;
    data["quantity"] = this.quantity;
    data["total_price"] = this.totalPrice;
    data["buyerID"] = this.buyerID;
    data["orderState"] = this.orderState;
    data["sellerId"] = this.sellerId;
    data["deliveryDay"] = this.deliveryDay;
    data["seller_stripe_account"] = this.sellerStAccountid;
    data["payment_method_id"] = user.defaultSource;
    data["currency"] = user.currency;
    data["customerId"] = user.customerId;
    data["fees"] = this.fees;
    data["total_with_fees"] = this.totalWithFees;
    data["title"]= this.title;
    data["adress"] = this.adress.toJSON();
    return data;
   }
}


class  Transaction {
    String id;
    String object;
    int amount;
    int availableOn;
    int created;
    String currency;
    String description;
    int fee;
    int net;
    String reportingCategory;
    String type;
    String status;
    String currencySymbol;



    Transaction({this.amount, this.availableOn, this.created, this.currency, this.description, this.fee, this.id, this.net, this.object, this.reportingCategory, this.status, this.type, this.currencySymbol});

  static Transaction fromJson(Map<String, dynamic> map) => Transaction(
    id: map["id"],
    object: map["object"],
    amount: map["amount"],
    availableOn: map["available_on"],
    created: map["created"],
    currency: map["currency"],
    description: map["descriptionn"],
    fee: map["fee"],
    net: map["net"],
    reportingCategory: map["reporting_category"],
    type: map["type"],
    status: map["status"],
    currencySymbol: NumberFormat.simpleCurrency(locale: "fr").currencySymbol
  );


    static List<Transaction> fromJsonToList(List<Object> map) {
        List<Transaction> alltransactions = [];
        map.forEach((element) {
          final x = Transaction.fromJson(element);
          alltransactions.add(x);
        });
        return alltransactions;
  }



}


class BankAccount {
    String id;
    String object;
    String accountHolderName;
    String accountHolderType;
    String bankName;
    String country;
    String currency;
    String last4;

    BankAccount({this.accountHolderName, this.accountHolderType, this.bankName, this.country, this.currency, this.id, this.last4, this.object});
    static BankAccount fromJson(Map<String, dynamic> map) => BankAccount(
      id: map["id"],
      object: map["object"],
      accountHolderName: map["account_holder_name"],
      accountHolderType: map["account_holder_type"],
      bankName: map["bank_name"],
      country: map["country"],
      currency: map["currency"],
      last4: map["last4"]
    );

    static List<BankAccount> fromJsonToList(List<Object> map) {
    List<BankAccount> allbankaccount = [];
    map.forEach((element) {
      final x = BankAccount.fromJson(element);
      allbankaccount.add(x);
    });
    return allbankaccount;
  }
}


class Payout {
    String id;
    String object;
    int arrivalDate;
    double amount;
    String type;
    String status;
    String description;

    Payout({this.id, this.object, this.arrivalDate, this.amount, this.type, this.description, this.status});
    static Payout fromJson(Map<String, dynamic> map) => Payout(
      id: map["id"],
      object: map["object"],
      arrivalDate: map["arrival_date"],
      amount: map["amount"],
      type: map["type"],
      status: map["status"],
      description: map["description"]
    );
}

class DatabaseProviderService {
  // ignore: close_sinks
  BehaviorSubject<UserDef> user = new BehaviorSubject<UserDef>();
  Stream<UserDef> get user$ => user.stream.asBroadcastStream();
  BehaviorSubject<Adress> adress = new BehaviorSubject<Adress>();

  User firebaseUser;


  void dispose(){
    this.user.add(null);
    this.publications.close();
    this.sellerPublications.close();
    this.sellerOrders.add(null);
    this.buyerOrders.add(null);
    this.rooms.add(null);
    this.adress.close();
  }



  BehaviorSubject<List<PublicationHome>> publications = new BehaviorSubject<List<PublicationHome>>();
  Stream<List<PublicationHome>> get publications$ => publications.stream;


  BehaviorSubject<PublicationHome> inHomePublication;
  StreamSubscription<PublicationHome> getinPublicationHome(String publicationId, BehaviorSubject<PublicationHome> pub){
    this.inHomePublication = pub;
    return this.publications.map((event) => event.firstWhere((publication) => publication.id == publicationId)).listen((event) => inHomePublication.sink.add(event));
  }


  void updateLikeInPublication(String pubId, bool liked){
    this.publications.value.firstWhere((element) => element.id == pubId).liked = liked;
  }



  BehaviorSubject<List<PublicationVendor>> sellerPublications = new BehaviorSubject<List<PublicationVendor>>();

  // ignore: close_sinks
  BehaviorSubject<PublicationVendor> insellerPublication;
  StreamSubscription<PublicationVendor> getinPublicationSeller(String orderId, BehaviorSubject<PublicationVendor> pub){
    this.insellerPublication = pub;
    return this.sellerPublications.map((event) => event.firstWhere((order) => order.id == orderId)).listen((event) => insellerPublication.sink.add(event));
  }



    // ignore: close_sinks
  BehaviorSubject<List<OrderVendor>> sellerOrders = new BehaviorSubject<List<OrderVendor>>();
  Stream<dynamic> get sellingNotificationCount => sellerOrders.stream.map((event) => event.map((order) => order.notificationSeller).fold(0, (previousValue, element) => previousValue + element));


  // ignore: close_sinks
  BehaviorSubject<OrderVendor> inOrderSeller;
  StreamSubscription<OrderVendor> getOrderSeller(String orderId, BehaviorSubject<OrderVendor> sellorders){
    this.inOrderSeller = sellorders;
    return this.sellerOrders.map((event) => event.firstWhere((order) => order.id == orderId)).listen((event) => inOrderSeller.sink.add(event));
  }



      // ignore: close_sinks
  BehaviorSubject<List<Order>> buyerOrders = new BehaviorSubject<List<Order>>();
  Stream<int> get buyingNotification => buyerOrders.stream.map((event) => event.map((order) => order.notificationBuyer).fold(0, (previousValue, element) => previousValue + element));

        // ignore: close_sinks
  BehaviorSubject<Order> inOrderBuyer;

  StreamSubscription<Order> getOrderBuyer(String orderId, BehaviorSubject<Order> order){
    this.inOrderBuyer = order;
    return this.buyerOrders.map((event) => event.firstWhere((order) => order.id == orderId)).listen((event) => inOrderBuyer.sink.add(event));
  }
  


  // ignore: close_sinks
  BehaviorSubject<List<Room>> rooms = new BehaviorSubject<List<Room>>();
  Stream<int> get messageNotificationCount => rooms.stream.map((event) => event.map((room) => room.messages.where((message) => message.userId != this.user.value.id && message.isRead == false).length).fold(0, (previousValue, element) => previousValue + element));

  // ignore: close_sinks
  BehaviorSubject<List<Message>> messagesInRoom;

  StreamSubscription<Room> getRoom(String roomId, BehaviorSubject<List<Message>> messages) {
    this.messagesInRoom = messages;
    return this.rooms.stream.map((event) => event.firstWhere((Room element) => element.id == roomId)).listen((event) => messagesInRoom.sink.add(event.messages));
  }
  //Stream<Message> getLastMessage(String roomId) => this.rooms.stream.map((event) => event.firstWhere((element) => element.id == roomId).messages.first);
  Stream<Message> get unreadMessage => this.messagesInRoom.map((event) => event.firstWhere((message) => message.userId != this.user.value.id && message.isRead == false, orElse: () => null));


  void updateSingleRoom(String roomId, Message message) {
    this.rooms.value.singleWhere((element) => element.id == roomId).messages.insert(0, message);
    this.rooms.sink.add(this.rooms.value);
  }


    final OptimisticCache cache = OptimisticCache(
      dataIdFromObject: typenameDataIdFromObject,
    );
    

     GraphQLClient client = clientFor(uri: environment['graphqlUrl'], subscriptionUri: environment['graphqlSocket'], authorization: "").value;

     

    Future<String> updatedDefaultSource(source) async {
          final MutationOptions _options  = MutationOptions(
        documentNode: gql(r"""
          mutation UpdateDefaultSource($userId: String!, $source: String!){
                updateDefaultSource(userId: $userId, source: $source)
            }
        """),
        variables:  <String, String> {
          "userId": this.user.value.id,
          "source": source,
        }
      );

      return await client.mutate(_options).then((result) =>  result.data["updateDefaultSource"]);
    }


    Future<String> updateIbanDeposit(String iban) async {
               final MutationOptions _options  = MutationOptions(
        documentNode: gql(r"""
          mutation UpdateIbanSource($userId: String!, $iban: String!){
                updateIbanSource(userId: $userId, iban: $iban)
            }
        """),
        variables:  <String, String> {
          "userId": this.user.value.id,
          "iban": iban,
        }
      );

      return await client.mutate(_options).then((result) =>  result.data["updateIbanSource"]); 
    }


      Future<String> updateFirebasetoken(String token) async {
               final MutationOptions _options  = MutationOptions(
        documentNode: gql(r"""
          mutation UpdateFirebasetoken($userId: String!, $token: String!){
                updateFirebasetoken(userId: $userId, token: $token)
            }
        """),
        variables:  <String, String> {
          "userId": this.user.value.id,
          "token": token,
        }
      );

      return await client.mutate(_options).then((result) =>  result.data["updateFirebasetoken"]); 
    }


    String subscribeToNewMessage = r"""
      subscription getMEssagedAdded($roomID: ID!)  {
        messageAdded(roomID: $roomID) {
          userId
          message
          createdAt
          message_picture
        }
      }
""";


  String subscribeToMessageRead = r"""
      subscription getMessageRead($roomID: ID!, $listener: String!)  {
        messageRead(roomID: $roomID, listener: $listener)
      }
""";

  String subscribeToUserWriting = r"""
      subscription getUserIsWriting($roomID: ID!)  {
        userIsWriting(roomID: $roomID)
      }
""";

  String subscribeToOrderBuyer = r"""
      subscription getorderUpdatedBuyer($listener: String!)  {
        orderUpdatedBuyer(listener: $listener)
      }
""";

  String subscribeToOrderSeller = r"""
      subscription getorderUpdatedSeller($listener: String!)  {
        orderUpdatedSeller(listener: $listener)
      }
""";

  StreamSubscription<dynamic> newMessageStream(String roomID) {
      final Operation _options = Operation(
        operationName: "getMEssagedAdded",
        documentNode: gql(subscribeToNewMessage),
        variables: <String, String>{"roomID": roomID},
      );

    return this.client.subscribe(_options).listen((event) => event.data);
  }

  StreamSubscription<dynamic> messageReadStream(String roomID) {
      final Operation _options = Operation(
        operationName: "getMessageRead",
        documentNode: gql(subscribeToMessageRead),
        variables: <String, String>{"roomID": roomID, "listener": this.user.value.id},
      );

    return this.client.subscribe(_options).listen((event) => event.data);
  }


    StreamSubscription<dynamic> orderUpdateBuyerStream() {
      final Operation _options = Operation(
        operationName: "getorderUpdatedBuyer",
        documentNode: gql(subscribeToOrderBuyer),
        variables: <String, String>{"listener": this.user.value.id},
      );

    return this.client.subscribe(_options).listen((event) => event.data);
  }


      StreamSubscription<dynamic> orderUpdateSellerStream() {
      final Operation _options = Operation(
        operationName: "getorderUpdatedSeller",
        documentNode: gql(subscribeToOrderSeller),
        variables: <String, String>{"listener": this.user.value.id},
      );

    return this.client.subscribe(_options).listen((event) => event.data);
  }


  StreamSubscription<void> userIsWritingStream(String roomID){
      final Operation _options = Operation(
        operationName: "getUserIsWriting",
        documentNode: gql(subscribeToUserWriting),
        variables: <String, String>{"roomID": roomID},
      );

    return this.client.subscribe(_options).listen((event) => event.data);
  }





  Future<List<Room>>  loadrooms() {
  final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      documentNode: gql( r'''
                  query GetUserRoom($uid: String!) {
                        getUserRooms(userId: $uid){
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
                  '''), variables: <String, String>{
          'uid': this.user.value.id
        });

        return this.client.query(_options).then((result) {
            List<Room> list = Room.fromJsonToList(result.data["getUserRooms"], this.user.value.id);
            rooms.sink.add(list);
            return list;
            
        });
  }

    Future<void> setIschatAreRead(String roomId) async {
        final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation UpdateAllMessageForUser($userID: String!, $roomId: String!){
              updateAllMessageForUser(userID: $userID, roomId: $roomId)
          }
      """),
      variables:  <String, String> {
        "userID": this.user.value.id,
        "roomId": roomId,
      }
    );

    return await this.client.mutate(_options).then((result) =>  result.data["updateAllMessageForUser"]);
  }


  Future<void> uploadMultipart(File img, String type, String stripeAccount) async {
    var byteData = img.readAsBytesSync();
    var file = MultipartFile.fromBytes(
          "photo",
          byteData,
          filename: '${DateTime.now().second}.jpg',
          contentType: MediaType("image", "jpg"),
        );
    final MutationOptions _options = MutationOptions(
      documentNode: gql(r"""
          mutation UploadFile($file: Upload!, $type: String!, $stripeAccount: String!){
            uploadFile(file: $file, type: $type, stripeAccount: $stripeAccount)
          }
      """),
      variables: <String , dynamic>{
        "file": file,
        "type": type,
        "stripeAccount": stripeAccount
      } 
    );
    return this.client.mutate(_options).then((result) => result.data["uploadFile"]).catchError((onError) => throw onError);
  }



   Future<void> createOrder(OrderInput order) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
              mutation CreateOrder($order: OrderInput){
                createOrder(order: $order)
              }
            """),
            variables: <String, dynamic> {
              "order": order.toJson(this.user.value)
            }
            );

    return client.mutate(_options).then((value) => value.data["createOrder"]);
  }


   Future<BankAccount> createBankAccount(String account) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          mutation CreateBankAccountOnConnect($account_id: String!, $country:String!, $currency: String!, $account_number: String!) {
            createBankAccountOnConnect(account_id: $account_id, country: $country, currency: $currency, account_number: $account_number){
              id
              object
              account_holder_name
              account_holder_type
              bank_name
            }
          }
        """),
        variables: <String, dynamic> {
          'account_id' : this.user.value.stripeaccountId,
          'country': this.user.value.country,
          'currency': this.user.value.currency,
          "account_number": account
        }
        );

    return client.mutate(_options).then((result) => BankAccount.fromJson(result.data["createBankAccountOnConnect"]));
  }



  Future<Payout> makePayout(Balance balance) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          mutation MakePayout($account_id: String!, $amount: Int!, $currency: String!, $destination: String!) {
            makePayout(account_id: $account_id, amount: $amount, currency: $currency, destination: $destination){
                  id
                  object
                  arrival_date
                  amount
                  type
                  status
                  description
            }
          }
        """),
        variables: <String, dynamic> {
          'account_id' : this.user.value.stripeaccountId,
          'amount': balance.currentBalance,
          'currency': balance.currency,
          'destination': this.user.value.defaultIban
        }
        );

    return client.mutate(_options).then((result){
      if(result.hasException){
       return throw result.exception.graphqlErrors[0].extensions;
      }
      return Payout.fromJson(result.data["makePayout"]);
    });
  }


  

  
  Future<QueryResult> addattachPaymentToCustomer(String methodeId) async {
    final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation AddattachPaymentToCustomer($customer_id: String!, $methode_id: String!){
              addattachPaymentToCustomer(customer_id: $customer_id, methode_id: $methode_id){
                id,
                object
              }
          }
      """),
      variables:  <String, String> {
        "customer_id": this.user.value.customerId,
        "methode_id": methodeId,
      }
    );

    return await client.mutate(_options);
}







  Future<void> createBankAccountOnConnect(String accountNumber) async {
    final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation CreateBankAccountOnConnect($account_id: String!, $country: String!, $currency: String!, $account_number: String!){
              createBankAccountOnConnect(account_id: $account_id, country: $country, currency:  $currency, account_number: $account_number){
                id
              }
          }
      """),
      variables:  <String, String> {
        "account_id": this.user.value.stripeaccountId,
        "country": this.user.value.country,
        "currency": this.user.value.currency,
        "account_number": accountNumber
      }
    );

    return await client.mutate(_options).then((value) => value.data["createBankAccountOnConnect"]);
}


  Future<void> cleanNotificationSeller(String orderId) async {
    final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation CleanNotificationSeller($orderId: String!){
              cleanNotificationSeller(orderId: $orderId){
                _id
              }
          }
      """),
      variables:  <String, String> {
        "orderId": orderId,
      }
    );
    return await client.mutate(_options).then((value) => value.data["cleanNotificationSeller"]);
}


  Future<void> cleanNotificationBuyer(String orderId) async {
    final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation CleanNotificationBuyer($orderId: String!){
              cleanNotificationBuyer(orderId: $orderId){
                _id
              }
          }
      """),
      variables:  <String, String> {
        "orderId": orderId,
      }
    );
    return await client.mutate(_options).then((value) => value.data["cleanNotificationBuyer"]);
}

Future<List<Order>>  loadbuyerOrders() {
  final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      documentNode: gql(r'''
                  query Order($uid: String!) {
                        getOrderOwnedBuyer(userId: $uid){
                            _id
                            productId
                            stripeTransactionId
                            orderState
                            deliveryDay
                            sellerId
                            quantity
                            total_price
                            notificationBuyer
                            fees
                            createdAt
                            updatedAt
                            total_with_fees
                            currency
                            shortId
                            adress {
                                  title
                                  location {
                                    latitude
                                    longitude
                                  }
                                }
                            
                            publication {
                                 _id
                                title
                                description
                                photoUrls
                                adress{title, location {latitude, longitude}} 
                                food_preferences
                            }

                            seller {
                                _id
                                first_name
                                last_name
                                photoUrl
                                fcmToken
                            }
                        }
                    }
                  '''), variables: <String, String>{
          'uid': this.user.value.id
        });

        return client.query(_options).then((result) {
            List<Order> list = Order.fromJsonToList(result.data["getOrderOwnedBuyer"]).reversed.toList();
            buyerOrders.add(list);
            return list;
            
        });
  }

  Future<List<OrderVendor>>  loadSellerOrders() {
  final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      documentNode: gql(r'''
                      query Order($uid: String!) {
                            getOrderOwnedSeller(userId: $uid){
                                _id
                                productId
                                stripeTransactionId
                                orderState
                                quantity
                                total_price
                                createdAt
                                updatedAt
                                deliveryDay
                                buyerID
                                sellerId
                                currency
                                notificationSeller
                                fees
                                total_with_fees
                                shortId
                                adress {
                                  title
                                  location {
                                    latitude
                                    longitude
                                  }
                                }

                                buyer {
                                  _id
                                  first_name
                                  last_name
                                  photoUrl
                                  fcmToken
                                }
                                
                                publication {
                                    _id
                                    title
                                    description
                                    photoUrls
                                    food_preferences
                                    adress {
                                      title
                                      location {
                                        latitude
                                        longitude
                                      }
                                    }
                                    rating {rating_total, rating_count}
                                }
                            }
                        }
                      '''), variables: <String, String>{
          'uid': this.user.value.id
        });

        return client.query(_options).then((result) {
            List<OrderVendor> list = OrderVendor.fromJsonToList(result.data["getOrderOwnedSeller"]).reversed.toList();
            sellerOrders.add(list);
            return list;
            
        });
  }



  Future<List<PublicationVendor>>  loadSellerPublications() {
  final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      documentNode: gql(r'''
                query PublicatioinOwned($uid: String!) {
                      getpublicationOwned(userId: $uid){
                          _id
                          title
                          description
                          type
                          price_all
                          photoUrls
                          createdAt
                          is_open
                          currency
                          shortId

                          food_preferences
                          
                          adress {
                            title
                            location {
                              latitude
                              longitude
                            }
                          }

                          rating {rating_total, rating_count}
                      }
                  }
              '''), variables: <String, String>{
          'uid': this.user.value.id
        });

        return client.query(_options).then((result) {
            List<PublicationVendor> list = PublicationVendor.fromJsonToList(result.data["getpublicationOwned"]).reversed.toList();
            sellerPublications.add(list);
            return list;
            
        });
  }



      Future<UserDef> setIsSeller() async {
        final MutationOptions _options  = MutationOptions(
      documentNode: gql(r"""
        mutation SetIsSeller($userId: String!){
              setIsSeller(userId: $userId) {
                              _id
              email
              first_name
              last_name
              phonenumber
              customerId
              country
              currency
              default_source
              default_iban
              stripe_account
              is_seller
              settings {
                  food_preferences
                  food_price_ranges
                  distance_from_seller
                  updatedAt
              }

              stripeAccount {
                charges_enabled
                payouts_enabled
                requirements {
                      currently_due
                      eventually_due
                      past_due
                      pending_verification
                      disabled_reason
                      current_deadline
                }
              }

              balance {
                current_balance
                pending_balance
                currency
              }

              transactions {
                    id
                    object
                    amount
                    available_on
                    created
                    currency
                    description
                    fee
                    net
                    reporting_category
                    type
                    status
              }

              all_cards {
                id
                brand
                country
                customer
                cvc_check
                exp_month
                exp_year
                fingerprint
                funding
                last4
              }

              ibans {
                    id
                    object
                    account_holder_name
                    account_holder_type
                    bank_name
                    country
                    currency
                    last4
              }

              createdAt
              photoUrl
              updatedAt
              adresses {title, location {latitude, longitude}, is_chosed}
              fcmToken
              }
          }
      """),
      variables:  <String, String> {
        "userId": this.user.value.id,
      }
    );

    return client.mutate(_options).then((kooker) {
        if(kooker.data["setIsSeller"] != null){
                  final kookersUser = UserDef.fromJson(kooker.data["setIsSeller"]);
                  this.user.add(kookersUser);
                  return kookersUser;
        }
        return null;
      });
  }

  Future<UserDef> loadUserData() {
  final QueryOptions _options = QueryOptions(
    fetchPolicy: FetchPolicy.cacheAndNetwork,
    documentNode: gql(r"""
            query GetIfUSerExist($uid: String!) {
                usersExist(firebase_uid: $uid){
              _id
              email
              first_name
              last_name
              is_seller
              phonenumber
              customerId
              country
              currency
              default_source
              default_iban
              stripe_account
              settings {
                  food_preferences
                  food_price_ranges
                  distance_from_seller
                  updatedAt
              }

              stripeAccount {
                charges_enabled
                payouts_enabled
                requirements {
                      currently_due
                      eventually_due
                      past_due
                      pending_verification
                      disabled_reason
                      current_deadline
                }
              }

              balance {
                current_balance
                pending_balance
                currency
              }

              transactions {
                    id
                    object
                    amount
                    available_on
                    created
                    currency
                    description
                    fee
                    net
                    reporting_category
                    type
                    status
              }

              all_cards {
                id
                brand
                country
                customer
                cvc_check
                exp_month
                exp_year
                fingerprint
                funding
                last4
              }

              ibans {
                    id
                    object
                    account_holder_name
                    account_holder_type
                    bank_name
                    country
                    currency
                    last4
              }

              createdAt
              photoUrl
              updatedAt
              adresses {title, location {latitude, longitude}, is_chosed}
              fcmToken
                }
            }
        """), variables: <String, String>{
        "uid": this.firebaseUser.uid
      });

      


      return client.query(_options).then((kooker) {
        if(kooker.data["usersExist"] != null){
                  final kookersUser = UserDef.fromJson(kooker.data["usersExist"]);
                  this.user.add(kookersUser);
                  return kookersUser;
        }
        return null;
      });
    }


    List<String> geohashWithinRange(Location location, int distance) {
      GeoHasher geoHasher = GeoHasher();
      final distanceMiles = distance / 1.609;
      final lat = 0.0144927536231884; // degrees latitude per mile
      final lon = 0.0181818181818182;

      final lowerLat = location.latitude - lat * distanceMiles;
      final lowerLon = location.longitude - lon * distanceMiles;

      final upperLat = location.latitude + lat * distanceMiles;
      final upperLon = location.longitude + lon * distanceMiles;

      final lower = geoHasher.encode(lowerLon, lowerLat);
      final upper = geoHasher.encode(upperLon, upperLat);

      return [lower, upper];

    }


      Future<void> setLikePost(String postId) async {
        final MutationOptions _options  = MutationOptions(
          documentNode: gql(r"""
            mutation SetLike($likeId: String!, $userId: String!){
                  setLike(likeId: $likeId, userId: $userId)
              }
          """),
          variables:  <String, String> {
            "likeId": postId,
            "userId": this.user.value.id
          }
        );
        return await client.mutate(_options).then((value) => value.data["setLike"]);
    }

      Future<void> setDislikePost(String postId) async {
        final MutationOptions _options  = MutationOptions(
          documentNode: gql(r"""
            mutation SetDisklike($likeId: String!, $userId: String!){
                  setDisklike(likeId: $likeId, userId: $userId)
              }
          """),
          variables:  <String, String> {
            "likeId": postId,
            "userId": this.user.value.id
          }
        );
        return await client.mutate(_options).then((value) => value.data["setDisklike"]);
    }



    Future<List<PublicationHome>> loadPublication(Location location, int distance) async {
      List<String> geohashes = geohashWithinRange(location, distance);
      
      final QueryOptions _options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        documentNode: gql(r"""
            query GetPublicationViaGeo($greather: String!, $lesser: String!, $userId: String) {
                getPublicationViaGeo(greather: $greather, lesser: $lesser, userId: $userId){
                  _id
                  title
                  description
                  type
                  price_all
                  photoUrls
                  createdAt
                  currency
                  likeCount
                  likes

                  food_preferences

                  adress {
                    location {
                      latitude
                      longitude
                    }
                  }

                  rating {rating_total, rating_count}
                  
                  seller {
                    _id
                    email
                    first_name
                    last_name
                    fcmToken
                    photoUrl
                    rating {rating_total, rating_count}
                  }
                }
            }
        """), variables: <String, String>{
        "greather": geohashes[0],
        "lesser": geohashes[1],
        "userId": this.user.value == null ? null : this.user.value.id
      });

      return client.query(_options).then((publicationsObject) {
        final publicationsall = PublicationHome.fromJsonToList(publicationsObject.data["getPublicationViaGeo"]).reversed.toList();
        this.publications.add(publicationsall);
        return publicationsall;
      });
    }









}