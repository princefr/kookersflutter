class Balance {
  int currentBalance;
  int pendingBalance;
  double totalBalance;
  String currency;

  Balance(
      {required this.currentBalance,
      required this.pendingBalance,
      required this.totalBalance,
      required this.currency});

  static Balance fromJson(Map<String, dynamic> map) => Balance(
      currentBalance: map["current_balance"] ?? 0,
      pendingBalance: map["pending_balance"] ?? 0,
      totalBalance:
          ((map["current_balance"] ?? 0) + (map["pending_balance"] ?? 0))
                  .toDouble() /
              100,
      currency: map["currency"]);

  Map<String, dynamic> toJson() {
    return {
      'current_balance': currentBalance,
      'pending_balance': pendingBalance,
      'total_balance': totalBalance,
      'currency': currency,
    };
  }
}
