import 'package:intl/intl.dart';
import 'package:kookers/Widgets/ButtonVerification.dart';

class StripeRequirements {
  List<String> currentlyDue;
  List<String> eventuallyDue;
  List<String> pastDue;
  List<String> pendingVerification;
  String disabledReason;
  int currentDeadline;
  ButtonVerificationState idStatus;
  ButtonVerificationState residenceProof;
  
  StripeRequirements({
    required this.currentlyDue, required this.eventuallyDue, required this.pastDue, required this.pendingVerification,
    required this.disabledReason, required this.currentDeadline, required this.idStatus, required this.residenceProof
  });

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

  static ButtonVerificationState buildIdStatus(Map<String, dynamic> map) {
    final pending = List<String>.from(map["pending_verification"].map((string) => string));
    final currently = List<String>.from(map["currently_due"].map((string) => string));
    final eventually = List<String>.from(map["eventually_due"].map((string) => string));
    
    if (!pending.contains("individual.verification.document") && 
        !currently.contains("individual.verification.document") && 
        !eventually.contains("individual.verification.document")) {
      return ButtonVerificationState.Verified; 
    } else if (pending.contains("individual.verification.document")) {
      return ButtonVerificationState.VerificationInProgress;
    }
    return ButtonVerificationState.Missing;
  }

  static ButtonVerificationState buildResidenceStatus(Map<String, dynamic> map) {
    final pending = List<String>.from(map["pending_verification"].map((string) => string));
    final currently = List<String>.from(map["currently_due"].map((string) => string));
    final eventually = List<String>.from(map["eventually_due"].map((string) => string));
    
    if (!pending.contains("individual.verification.additional_document") && 
        !currently.contains("individual.verification.additional_document") && 
        !eventually.contains("individual.verification.additional_document")) {
      return ButtonVerificationState.Verified; 
    } else if (pending.contains("individual.verification.additional_document")) {
      return ButtonVerificationState.VerificationInProgress;
    }
    return ButtonVerificationState.Missing;
  }
}

class StripeAccount {
  bool chargesEnabled;
  bool payoutsEnabled;
  StripeRequirements stripeRequirements;
  
  StripeAccount({required this.chargesEnabled, required this.payoutsEnabled, required this.stripeRequirements});
}

class Transaction {
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

  Transaction({
    required this.amount, required this.availableOn, required this.created, required this.currency, required this.description, 
    required this.fee, required this.id, required this.net, required this.object, required this.reportingCategory, required this.status, 
    required this.type, required this.currencySymbol
  });

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
      final x = Transaction.fromJson(element as Map<String, dynamic>);
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

  BankAccount({
    required this.accountHolderName, required this.accountHolderType, required this.bankName, 
    required this.country, required this.currency, required this.id, required this.last4, required this.object
  });
  
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
      final x = BankAccount.fromJson(element as Map<String, dynamic>);
      allbankaccount.add(x);
    });
    return allbankaccount;
  }
}

class CardModel {
  // Add CardModel implementation here based on your needs
  static List<CardModel> fromJsonTolist(List<Object> map) {
    // Implementation needed
    return [];
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

  Payout({
    required this.id, required this.object, required this.arrivalDate, required this.amount, 
    required this.type, required this.description, required this.status
  });
  
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