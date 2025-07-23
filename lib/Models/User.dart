import 'Address.dart';
import 'Balance.dart';
import 'PaymentModels.dart';

class UserSettings {
  int? distanceFromSeller;
  List<String>? foodPreference;
  List<String>? foodPriceRange;
  String? createdAt;
  String? updatedAt;
  
  UserSettings({
    this.distanceFromSeller, 
    this.foodPreference, 
    this.foodPriceRange, 
    this.createdAt, 
    this.updatedAt
  });
  
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

class UserDef {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? phonenumber;
  String? fcmToken;
  UserSettings? settings;
  List<Adress>? adresses;
  String? photoUrl;
  String? customerId;
  String? currentAdress;
  String? createdAt;
  String? updatedAt;
  String? defaultSource;
  String? country;
  String? currency;
  String? defaultIban;
  String? stripeaccountId;
  StripeAccount? stripeAccount;
  List<Transaction>? transactions;
  Balance? balance;
  List<BankAccount>? ibans;
  List<CardModel>? allCards;
  bool? isSeller;
  bool? notificationPermission;

  UserDef({
    this.id, this.email, this.firstName, this.lastName, this.phonenumber, 
    this.fcmToken, this.settings, this.adresses, this.photoUrl, this.customerId, 
    this.createdAt, this.updatedAt, this.defaultSource, this.country, this.currency,
    this.stripeaccountId, this.defaultIban, this.stripeAccount, this.transactions, 
    this.balance, this.ibans, this.allCards, this.isSeller, this.notificationPermission,
    this.currentAdress
  });
 
  static UserDef fromJson(Map<String, dynamic> map) => UserDef(
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
    stripeAccount: StripeAccount(
      chargesEnabled: map["stripeAccount"]["charges_enabled"], 
      payoutsEnabled: map["stripeAccount"]["payouts_enabled"], 
      stripeRequirements: StripeRequirements.fromJson(map["stripeAccount"]["requirements"])
    ),
    transactions: Transaction.fromJsonToList(map["transactions"]),
    balance: Balance.fromJson(map["balance"]),
    ibans: BankAccount.fromJsonToList(map["ibans"]),
    allCards: CardModel.fromJsonTolist(map["all_cards"]),
    isSeller: map["is_seller"],
    notificationPermission: map["notificationPermission"]
  );
}

class SellerDef {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? fcmToken;
  String? photoUrl;
  
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

class BuyerVendor {
  String? id;
  String? firstName;
  String? lastName;
  String? photoUrl;
  String? fcmToken;
  
  BuyerVendor({this.id, this.firstName, this.lastName, this.photoUrl, this.fcmToken});
  
  static BuyerVendor fromJson(Map<String, dynamic> data) => BuyerVendor(
    id: data['_id'],
    firstName: data['first_name'],
    lastName: data["last_name"],
    photoUrl: data["photoUrl"],
    fcmToken: data["fcmToken"]
  );
}