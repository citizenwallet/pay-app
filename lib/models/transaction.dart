import './interaction.dart';

enum TransactionStatus {
  sending,
  pending,
  success,
  fail,
}

const String pendingTransactionId = 'TEMP_HASH';

class Transaction {
  String id; // id from supabase
  String txHash; // hash of the transaction

  String fromAccount; // address of the sender
  String toAccount; // address of the receiver
  double amount; // amount of the transaction
  String? description; // description of the transaction
  TransactionStatus status; // status of the transaction
  DateTime createdAt; // date of the transaction

  final ExchangeDirection exchangeDirection;

  Transaction({
    required this.id,
    required this.txHash,
    required this.createdAt,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    required this.exchangeDirection,
    required this.status,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      txHash: json['txHash'],
      createdAt: DateTime.parse(json['createdAt']),
      fromAccount: json['fromAccount'],
      toAccount: json['toAccount'],
      amount: json['amount'],
      exchangeDirection:
          Interaction.parseExchangeDirection(json['exchangeDirection']),
      description: json['description'] == '' ? null : json['description'],
      status: parseTransactionStatus(json['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'txHash': txHash,
      'createdAt': createdAt.toIso8601String(),
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'amount': amount,
      'direction': exchangeDirection
          .toString()
          .split('.')
          .last, // converts enum to string
      'description': description,
      'status': status.name.toUpperCase(),
    };
  }

  static TransactionStatus parseTransactionStatus(dynamic value) {
    if (value is TransactionStatus) return value;
    if (value is String) {
      try {
        return TransactionStatus.values.byName(value.toLowerCase());
      } catch (e) {
        return TransactionStatus.pending; // Default value
      }
    }
    return TransactionStatus.pending; // Default value
  }

  @override
  String toString() {
    return 'Transaction(id: $id, txHash: $txHash, createdAt: $createdAt, fromAccount: $fromAccount, toAccount: $toAccount, amount: $amount, exchangeDirection: $exchangeDirection, description: $description, status: $status)';
  }
}
