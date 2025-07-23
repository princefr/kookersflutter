


class CurrencyService {
  static String getCurrencySymbol(String currencyName){
    switch (currencyName.toUpperCase()) {
      case 'USD':
          return "\$"; // US Dollar
      case 'EUR':
          return "€"; // Euro
      case 'CRC':
          return "₡"; // Costa Rican Colón
      case 'GBP':
          return "£";  // British Pound Sterling
      case 'ILS':
          return "₪";  // Israeli New Sheqel
      case 'INR':
          return "₹";  // Indian Rupee
      case 'JPY':
          return "¥";  // Japanese Yen
      case 'KRW':
          return "₩";  // South Korean Won
      case 'NGN':
          return "₦";  // Nigerian Naira
      case 'PHP':
          return "₱"; // Philippine Peso
      case 'PLN':
          return "zł";  // Polish Zloty
      case 'PYG':
          return "₲";  // Paraguayan Guarani
      case 'THB':
          return "฿";  // Thai Baht
      case 'UAH':
          return "₴";  // Ukrainian Hryvnia
      case 'VND':
          return "₫";  // Vietnamese Dong
      default:
        return "\$"; // US Dollar
    }
  }
}