


class CurrencyService {
  static String getCurrencySymbol(String currencyName){
    switch (currencyName.toUpperCase()) {
      case 'USD':
          return "\$"; // US Dollar
        break;
      case 'EUR':
          return "€"; // Euro
        break;
      case 'CRC':
          return "₡"; // Costa Rican Colón
        break;
      case 'GBP':
          return "£";  // British Pound Sterling
        break;
      case 'ILS':
          return "₪";  // Israeli New Sheqel
        break;
      case 'INR':
          return "₹";  // Indian Rupee
        break;
      case 'JPY':
          return "¥";  // Japanese Yen
        break;
      case 'KRW':
          return "₩";  // South Korean Won
        break;
      case 'NGN':
          return "₦";  // Nigerian Naira
        break;
      case 'PHP':
          return "₱"; // Philippine Peso
        break;
      case 'PLN':
          return "zł";  // Polish Zloty
        break;
      case 'PYG':
          return "₲";  // Paraguayan Guarani
        break;
      case 'THB':
          return "฿";  // Thai Baht
        break;
      case 'UAH':
          return "₴";  // Ukrainian Hryvnia
        break;
      case 'VND':
          return "₫";  // Vietnamese Dong
        break;
      default:
        return "\$"; // US Dollar
    }
  }
}