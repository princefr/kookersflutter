import 'dart:async';

import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kookers/GraphQlHelpers/ClientProvider.dart';
import 'package:kookers/Pages/Balance/BalancePage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/PaymentMethods/CreditCardItem.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';


class Location {
  double latitude;
  double longitude;
  Location({this.latitude, this.longitude});
}

class RatingUser {
  int ratingTotal;
  int ratingCount;
  RatingUser({this.ratingCount, this.ratingTotal});
}

class Adress {
  String title;
  Location location;
  bool isChosed;
  static List<Adress> allAdress;
  Adress({this.title,  this.location, this.isChosed});

  static List<Adress> fromJson(List<Object> map) {
    List<Adress> adresses = [];
  
    map.forEach((element) {
      final adress = element as Map<String, dynamic>;
      print(adress["location"]["latitude"]);
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

class FoodPreference {
int id;
String title;
bool isSelected;
static List<dynamic> allSelectedToArray;
static List<FoodPreference> allSelected;
FoodPreference({this.id, this.title, this.isSelected});

static List<FoodPreference> fromJSON(List<Object> map) {
    List<FoodPreference> prefs = [];
    final  selected = [];
    map.forEach((element) {
      final pref = element as Map<String, dynamic>;
      prefs.add(FoodPreference(
        id: pref["id"],
        title: pref["title"],
        isSelected: pref["is_selected"],
      ));

      if (pref["is_selected"]){
        selected.add(pref["title"]);
      }
    });
    FoodPreference.allSelectedToArray = selected;
    FoodPreference.allSelected = prefs;
    return prefs;
}

  static List<Map<String, dynamic>> getDataForServer() {
    final List<Map<String, dynamic>> all = [];
    FoodPriceRange.allSelected.forEach((element) {
      all.add({"id": element.id, "title": element.title, "is_selected": element.isSelected});
    });

    return all;
  }


  void toogle(){
    this.isSelected = !this.isSelected;
  }



}


class FoodPriceRange {
  int id;
  String title;
  bool isSelected;
  static List<dynamic> allSelectedToArray;
  static List<FoodPriceRange> allSelected;
  FoodPriceRange({this.id, this.title, this.isSelected});

  static List<FoodPriceRange> fromJSON(List<Object> map) {
    List<FoodPriceRange> ranges = [];
    final  selected = [];
    map.forEach((element) {
      final pref = element as Map<String, dynamic>;
      ranges.add(FoodPriceRange(
        id: pref["id"],
        title: pref["title"],
        isSelected: pref["is_selected"],
      ));

      if (pref["is_selected"]){
        selected.add(pref["title"]);
      }


    });

    FoodPriceRange.allSelectedToArray = selected;
    FoodPriceRange.allSelected = ranges;

    return ranges;
  }

  static List<Map<String, dynamic>> getDataForServer() {
    final List<Map<String, dynamic>> all = [];
    FoodPriceRange.allSelected.forEach((element) {
      all.add({"id": element.id, "title": element.title, "is_selected": element.isSelected});
    });

    return all;
  }

  void toogle(){
    print("its is toggle");
    this.isSelected = !this.isSelected;
  }


  
}


class UserSettings {
  int distanceFromSeller;
  List<FoodPreference> foodPreference;
  List<FoodPriceRange> foodPriceRange;
  String createdAt;
  String updatedAt;
  UserSettings({this.distanceFromSeller, this.foodPreference, this.foodPriceRange, this.createdAt, this.updatedAt});
  
  static UserSettings fromJson(Map<String, dynamic> map) => UserSettings(
    distanceFromSeller: map['distance_from_seller'],
    foodPreference: FoodPreference.fromJSON(map["food_preferences"]),
    foodPriceRange: FoodPriceRange.fromJSON(map["food_price_ranges"]),
    updatedAt: map['updatedAt'],
    createdAt: map['createdAt']
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["distance_from_seller"] = this.distanceFromSeller;
    data["createdAt"] = this.createdAt;
    data["updatedAt"] = DateTime.now().toIso8601String();
    data["food_preferences"] = this.foodPreference.map((e) => {"id": e.id, "title": e.title, "is_selected": e.isSelected}).toList();
    data["food_price_ranges"] = this.foodPriceRange.map((e) => {"id": e.id, "title": e.title, "is_selected": e.isSelected}).toList();
    return data;
  }
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
 String stripeaccountId;

 UserDef({this.id, this.email, this.firstName, this.lastName, this.phonenumber, this.fcmToken, this.settings, this.adresses, this.photoUrl, this.customerId, this.createdAt, this.updatedAt, this.defaultSource, this.country, this.currency, this.stripeaccountId});
 
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
  stripeaccountId: map["stripe_account"]
);
}





class SellerDef {
  String id;
  RatingUser rating;
  String email;
  String firstName;
  String lastName;
  String fcmToken;
  String photoUrl;
  SellerDef({this.id, this.rating, this.firstName, this.email, this.lastName, this.fcmToken, this.photoUrl});
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
  PublicationVendor publication;
  String stripeTransactionId;
  BuyerVendor buyer;

  OrderVendor({@required this.productId, @required this.quantity, @required this.totalPrice, @required this.buyerID, @required this.orderState, @required this.sellerId, @required this.deliveryDay, @required this.sellerStAccountid, @required this.paymentMethodAssociated, @required this.currency, this.publication, this.buyer, this.id, this.stripeTransactionId});

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
    id: data["_id"]
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
  String pricePerPie;
  List<Object> photoUrls;
  Adress adress;
  bool isOpen;
  List<FoodPreference> preferences;
  String createdAt;

  PublicationVendor({this.id, this.title, this.description, this.type, this.pricePerAll, this.pricePerPie, this.photoUrls, this.adress, this.isOpen, this.preferences, this.createdAt});
  

  static PublicationVendor fromJson(Map<String, dynamic> map) => PublicationVendor(
    id: map["_id"],
    title: map["title"],
    description : map["description"],
    type: map["type"],
    pricePerAll: map["price_per_all"].toString(),
    pricePerPie: map["price_per_pie"].toString(),
    photoUrls: map["photoUrls"] as List<Object>,
    adress: Adress(isChosed: false, location: Location(latitude: map["adress"]["location"]["latitude"], longitude: map["adress"]["location"]["lonngitude"]), title: map["adress"]["title"]),
    isOpen: map["is_open"],
    preferences: FoodPreference.fromJSON(map["food_preferences"]),
    createdAt: map["createdAt"]
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
  String pricePerPie;
  List<Object> photoUrls;
  Adress adress;
  SellerDef seller;
  List<FoodPreference> preferences;

  PublicationHome({this.id, this.title, this.description, this.type, this.pricePerAll, this.pricePerPie, this.photoUrls, this.adress, this.seller, this.preferences});
  

  static PublicationHome fromJson(Map<String, dynamic> map) => PublicationHome(
    id: map["_id"],
    title: map["title"],
    description : map["description"],
    type: map["type"],
    pricePerAll: map["price_per_all"].toString(),
    pricePerPie: map["price_per_pie"].toString(),
    photoUrls: map["photoUrls"] as List<Object>,
    adress: Adress(isChosed: false, location: Location(latitude: map["adress"]["location"]["latitude"], longitude: map["adress"]["location"]["longitude"]), title: ""),
    seller: SellerDef.fromJson(map["seller"]),
    preferences: FoodPreference.fromJSON(map["food_preferences"])
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
  String deliveryDay;
  String orderState;
  String sellerId;
  String sellerStAccountid;
  String paymentMethodAssociated;
  String currency;

  OrderInput({@required this.productId, @required this.quantity, @required this.totalPrice,@required this.buyerID, @required this.orderState, @required this.sellerId, @required this.deliveryDay, @required this.sellerStAccountid, @required this.paymentMethodAssociated, @required this.currency});


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

  // ignore: close_sinks
  BehaviorSubject<List<PublicationHome>> publications = new BehaviorSubject<List<PublicationHome>>();
  Stream<List<PublicationHome>> get publications$ => publications.stream;


  // ignore: close_sinks
  BehaviorSubject<List<PublicationVendor>> sellerPublications = new BehaviorSubject<List<PublicationVendor>>();

  // ignore: close_sinks
  BehaviorSubject<PublicationVendor> insellerPublication;
  StreamSubscription<PublicationVendor> getinPublicationSeller(String orderId, BehaviorSubject<PublicationVendor> pub){
    this.insellerPublication = pub;
    return this.sellerPublications.map((event) => event.firstWhere((order) => order.id == orderId)).listen((event) => insellerPublication.sink.add(event));
  }



    // ignore: close_sinks
  BehaviorSubject<List<OrderVendor>> sellerOrders = new BehaviorSubject<List<OrderVendor>>();
  // ignore: close_sinks
  BehaviorSubject<OrderVendor> inOrderSeller;
  StreamSubscription<OrderVendor> getOrderSeller(String orderId, BehaviorSubject<OrderVendor> sellorders){
    this.inOrderSeller = sellorders;
    return this.sellerOrders.map((event) => event.firstWhere((order) => order.id == orderId)).listen((event) => inOrderSeller.sink.add(event));
  }



      // ignore: close_sinks
  BehaviorSubject<List<Order>> buyerOrders = new BehaviorSubject<List<Order>>();
        // ignore: close_sinks
  BehaviorSubject<Order> inOrderBuyer;
  StreamSubscription<Order> getOrderBuyer(String orderId, BehaviorSubject<Order> order){
    this.inOrderBuyer = order;
    return this.buyerOrders.map((event) => event.firstWhere((order) => order.id == orderId)).listen((event) => inOrderBuyer.sink.add(event));
  }

  

  // ignore: close_sinks
  BehaviorSubject<List<BankAccount>> userBankAccounts = new BehaviorSubject<List<BankAccount>>();
  


  // ignore: close_sinks
  BehaviorSubject<List<Room>> rooms = new BehaviorSubject<List<Room>>();

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



     GraphQLClient _client = clientFor(uri: "https://kookers-app.herokuapp.com/graphql", subscriptionUri: 'wss://kookers-app.herokuapp.com/graphql').value;

     

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

      return await _client.mutate(_options).then((result) =>  result.data["updateDefaultSource"]);
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





  StreamSubscription<void> newMessageStream(String roomID) {
      final Operation _options = Operation(
        operationName: "getMEssagedAdded",
        documentNode: gql(subscribeToNewMessage),
        variables: <String, String>{"roomID": roomID},
      );

    return this._client.subscribe(_options).listen((event) => event.data);
  }


  StreamSubscription<dynamic> messageReadStream(String roomID) {
      final Operation _options = Operation(
        operationName: "getMessageRead",
        documentNode: gql(subscribeToMessageRead),
        variables: <String, String>{"roomID": roomID, "listener": this.user.value.id},
      );

    return this._client.subscribe(_options).listen((event) => event.data);
  }


  StreamSubscription<void> userIsWritingStream(String roomID){
      final Operation _options = Operation(
        operationName: "getUserIsWriting",
        documentNode: gql(subscribeToUserWriting),
        variables: <String, String>{"roomID": roomID},
      );

    return this._client.subscribe(_options).listen((event) => event.data);
  }





  Future<List<Room>>  loadrooms() {
  final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.networkOnly,
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

        return this._client.query(_options).then((result) {
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

    return await this._client.mutate(_options).then((result) =>  result.data["updateAllMessageForUser"]);
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

    return _client.mutate(_options).then((value) => value.data["createOrder"]);
  }


   Future<void> createBankAccount(String account) async {
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

    return _client.mutate(_options).then((result) => result.data["createBankAccountOnConnect"]);
  }


    Future<void> getPayoutList() async {
    final QueryOptions _options = QueryOptions(documentNode: gql(r"""
          query GetPayoutList($accountId: String!) {
            getPayoutList(accountId: $accountId){
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
          'accountId' : this.user.value.stripeaccountId,
        }
        );

    return _client.query(_options).then((result) => result.data["getPayoutList"]);
  }

  Future<List<BankAccount>> listExternalAccount() async {
    final QueryOptions _options = QueryOptions(documentNode: gql(r"""
          query ListExternalAccount($accountId: String!) {
            listExternalAccount(accountId: $accountId){
              id
              object
              account_holder_name
              account_holder_type
              bank_name
              last4
            }
          }
        """),
        variables: <String, dynamic> {
          'accountId' : this.user.value.stripeaccountId,
        }
        );

    return _client.query(_options).then((result) => BankAccount.fromJsonToList(result.data["listExternalAccount"]));
  }


  Future<List<Transaction>> getBalanceTransactions() async {
    final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      documentNode: gql(r"""
          query GetBalanceTransaction($accountId: String!) {
            getBalanceTransaction(accountId: $accountId){
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
          }
        """),
        variables: <String, dynamic> {
          'accountId' : this.user.value.stripeaccountId,
        }
        );

    return _client.query(_options).then((result) =>Transaction.fromJsonToList(result.data["getBalanceTransaction"]));
  }


  Future<void> makePayout(Balance balance) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          mutation MakePayout($account_id: String!, $amount: String!, $currency: String!) {
            makePayout(account_id: $account_id, amount: $amount, $currency: currency){
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
          'currency': balance.currency
        }
        );

    return _client.mutate(_options).then((result) => result.data["createReport"]);
  }


  

  // ignore: close_sinks
  BehaviorSubject<List<CardModel>> sources = new BehaviorSubject<List<CardModel>>();
  Stream<List<CardModel>> get sources$ => sources.stream.asBroadcastStream();
  
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

    return await _client.mutate(_options);
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

    return await _client.mutate(_options).then((value) => value.data["createBankAccountOnConnect"]);
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
                            
                            publication {
                                 _id
                                title
                                description
                                photoUrls
                                food_preferences {id, title, is_selected}
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

        return _client.query(_options).then((result) {
            List<Order> list = Order.fromJsonToList(result.data["getOrderOwnedBuyer"]);
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
                                deliveryDay
                                buyerID
                                sellerId
                                currency

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
                                    food_preferences {id, title, is_selected}
                                    adress {
                                      title
                                      location {
                                        latitude
                                        longitude
                                      }
                                    }
                                }
                            }
                        }
                      '''), variables: <String, String>{
          'uid': this.user.value.id
        });

        return _client.query(_options).then((result) {
            List<OrderVendor> list = OrderVendor.fromJsonToList(result.data["getOrderOwnedSeller"]);
            sellerOrders.add(list);
            return list;
            
        });
  }



  Future<List<PublicationVendor>>  loadSellerPublications() {
  final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      documentNode: gql(r'''
                query Order($uid: String!) {
                      getpublicationOwned(userId: $uid){
                          _id
                          title
                          description
                          type
                          price_all
                          price_per_pie
                          photoUrls
                          createdAt
                          is_open

                          food_preferences {id, title, is_selected}
                          
                          adress {
                            title
                            location {
                              latitude
                              longitude
                            }
                          }
                      }
                  }
              '''), variables: <String, String>{
          'uid': this.user.value.id
        });

        return _client.query(_options).then((result) {
            List<PublicationVendor> list = PublicationVendor.fromJsonToList(result.data["getpublicationOwned"]);
            sellerPublications.add(list);
            return list;
            
        });
  }

  Future<UserDef> loadUserData(String uid) {
  final QueryOptions _options = QueryOptions(
    fetchPolicy: FetchPolicy.cacheAndNetwork,
    documentNode: gql(r"""
            query GetIfUSerExist($uid: String!) {
                usersExist(firebase_uid: $uid){
              _id
              email
              first_name
              last_name
              phonenumber
              customerId
              country
              currency
              default_source
              stripe_account
              settings {
                  food_preferences {id, title, is_selected}
                  food_price_ranges {id, title, is_selected}
                  distance_from_seller
                  updatedAt
              }

              createdAt
              photoUrl
              updatedAt
              adresses {title, location {latitude, longitude}, is_chosed}
              fcmToken
              rating {rating_total, rating_count}
                }
            }
        """), variables: <String, String>{
        "uid": uid,
      });

      


      return _client.query(_options).then((kooker) {
                  final kookersUser = UserDef.fromJson(kooker.data["usersExist"]);
                  this.user.add(kookersUser);
                return kookersUser;
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



    Future<List<PublicationHome>> loadPublication() async {
      //Location location = this.user.value.adresses.firstWhere((element) => element.isChosed == true).location;
      Location location = this.user.value.adresses.firstWhere((element) => element.isChosed).location;
      List<String> geohashes = geohashWithinRange(location, this.user.value.settings.distanceFromSeller);
      
      final QueryOptions _options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheFirst,
        documentNode: gql(r"""
            query GetPublicationViaGeo($greather: String!, $lesser: String!, $userId: String!) {
                getPublicationViaGeo(greather: $greather, lesser: $lesser, userId: $userId){
                  _id
                  title
                  description
                  type
                  price_all
                  price_per_pie
                  photoUrls
                  createdAt

                  food_preferences {
                    id
                    title
                    is_selected
                  }

                  adress {
                    location {
                      latitude
                      longitude
                    }
                  }
                  
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
        "userId": this.user.value.id
      });

      return _client.query(_options).then((publicationsObject) {
        final publicationsall = PublicationHome.fromJsonToList(publicationsObject.data["getPublicationViaGeo"]);
        this.publications.add(publicationsall);
        return publicationsall;
      });
    }


    Future<List<CardModel>> loadSourceList(){
      final QueryOptions _options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        documentNode: gql( r'''
                      query GetAllCards($customer_id: String!) {
                            getAllCardsForCustomer(customer_id: $customer_id){
                                    id
                                    brand,
                                    exp_month,
                                    exp_year,
                                    last4,
                            }
                        }
                      '''), variables: <String, String>{
        'customer_id': this.user.value.customerId,
      });

      return _client.query(_options).then((sourceList) {
        final sourceAll = CardModel.fromJsonTolist(sourceList.data["getAllCardsForCustomer"]);
        this.sources.sink.add(sourceAll);
        return sourceAll;
      });
    }






}