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
  String contract; // contract of the transaction

  String fromAccount; // address of the sender
  String toAccount; // address of the receiver
  String amount; // amount of the transaction
  String? description; // description of the transaction
  TransactionStatus status; // status of the transaction
  DateTime createdAt; // date of the transaction

  Transaction({
    required this.id,
    required this.txHash,
    required this.contract,
    required this.createdAt,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    required this.status,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      txHash: json['hash'],
      contract: json['contract'],
      createdAt: DateTime.parse(json['created_at']),
      fromAccount: json['from'],
      toAccount: json['to'],
      amount: json['value'],
      description: json['description'] == '' ? null : json['description'],
      status: parseTransactionStatus(json['status']),
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      txHash: map['tx_hash'],
      contract: map['contract'],
      createdAt: DateTime.parse(map['created_at']),
      fromAccount: map['from_account'],
      toAccount: map['to_account'],
      amount: map['amount'],
      description: map['description'] == '' ? null : map['description'],
      status: parseTransactionStatus(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tx_hash': txHash,
      'contract': contract,
      'created_at': createdAt.toIso8601String(),
      'from_account': fromAccount,
      'to_account': toAccount,
      'amount': amount,
      'description': description,
      'status': status.name.toUpperCase(),
    };
  }

  Transaction copyWith({
    String? id,
    String? txHash,
    String? contract,
    DateTime? createdAt,
    String? fromAccount,
    String? toAccount,
    String? amount,
    TransactionStatus? status,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      txHash: txHash ?? this.txHash,
      contract: contract ?? this.contract,
      createdAt: createdAt ?? this.createdAt,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  static Transaction upsert(Transaction existing, Transaction updated) {
    if (existing.id != updated.id) {
      throw ArgumentError('Cannot upsert transactions with different IDs');
    }

    return existing.copyWith(
      id: updated.id,
      txHash: updated.txHash,
      contract: updated.contract,
      createdAt: updated.createdAt,
      fromAccount: updated.fromAccount,
      toAccount: updated.toAccount,
      amount: updated.amount,
      status: updated.status,
      description: updated.description,
    );
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

  ExchangeDirection exchangeDirection(String account) {
    return fromAccount == account
        ? ExchangeDirection.sent
        : ExchangeDirection.received;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, txHash: $txHash, createdAt: $createdAt, fromAccount: $fromAccount, toAccount: $toAccount, amount: $amount, exchangeDirection: $exchangeDirection, description: $description, status: $status)';
  }
}
