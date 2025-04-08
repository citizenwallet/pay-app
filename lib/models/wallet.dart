import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class CWWallet {
  String name;
  final String address;
  final String alias;
  final String account;
  String _balance;
  final String currencyName;
  final String symbol;
  final String currencyLogo;
  final int decimalDigits;

  CWWallet(
    this._balance, {
    required this.name,
    required this.address,
    required this.alias,
    required this.account,
    required this.currencyName,
    required this.symbol,
    required this.currencyLogo,
    this.decimalDigits = 2,
  });

  // copy
  CWWallet copyWith({
    String? name,
    String? address,
    String? alias,
    String? account,
    String? balance,
    String? currencyName,
    String? symbol,
    String? currencyLogo,
    int? decimalDigits,
  }) {
    return CWWallet(balance ?? _balance,
        name: name ?? this.name,
        address: address ?? this.address,
        alias: alias ?? this.alias,
        account: account ?? this.account,
        currencyName: currencyName ?? this.currencyName,
        symbol: symbol ?? this.symbol,
        currencyLogo: currencyLogo ?? this.currencyLogo);
  }

  String get balance => _balance;
  double get doubleBalance => double.tryParse(_balance) ?? 0.0;
  double get formattedBalance => doubleBalance / pow(10, decimalDigits);


  

  /// Converts a JSON map to a CWWallet object
  CWWallet.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        address = json['address'],
        alias = json['alias'] ?? dotenv.get('DEFAULT_COMMUNITY_ALIAS'),
        account = json['account'],
        _balance = json['balance'],
        currencyName = json['currencyName'],
        symbol = json['symbol'],
        currencyLogo = json['currencyLogo'],
        decimalDigits = json['decimalDigits'] ?? 2;

  // Convert a Conversation object into a Map object.
  // The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'alias': alias,
        'account': account,
        'balance': _balance,
        'currencyName': currencyName,
        'symbol': symbol,
        'currencyLogo': currencyLogo,
        'decimalDigits': decimalDigits
      };

  void setBalance(String balance) {
    _balance = balance;
  }
}
