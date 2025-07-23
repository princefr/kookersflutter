class Balance {
  int currentBalance;
  int pendingBalance;
  String currency;

  Balance({required this.currentBalance, required this.pendingBalance, required this.currency});

  static Balance fromJson(Map<String, dynamic> map) => Balance(
    currentBalance: map["current_balance"],
    pendingBalance: map["pending_balance"],
    currency: map["currency"]
  );

  Map<String, dynamic> toJson() {
    return {
      'current_balance': currentBalance,
      'pending_balance': pendingBalance,  
      'currency': currency,
    };
  }
}