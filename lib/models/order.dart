import 'transaction.dart';

enum PaymentMode {
  terminal,
  qrCode,
  app,
}


class Order {
  String id; // id from supabase
  String txHash; // hash of the transaction

  int? orderId; // id of the order (for places only)
  PaymentMode? paymentMode; // payment mode (for places only)

  String fromAccountAddress; // address of the sender
  String toAccountAddress; // address of the receiver
  double amount; // amount of the transaction
  String? description; // description of the transaction
  TransactionStatus status; // status of the transaction
  DateTime createdAt; // date of the transaction

  Order({
    required this.id,
    required this.txHash,
    required this.createdAt,
    required this.fromAccountAddress,
    required this.toAccountAddress,
    required this.amount,
    this.description,
    required this.status,
    this.orderId,
    this.paymentMode,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      txHash: json['txHash'],
      createdAt: DateTime.parse(json['createdAt']),
      fromAccountAddress: json['fromAccountAddress'],
      toAccountAddress: json['toAccountAddress'],
      amount: json['amount'],
      description: json['description'],
      status: Transaction.parseTransactionStatus(json['status']),
      orderId: json['orderId'],
      paymentMode: _parsePaymentMode(json['paymentMode']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'txHash': txHash,
      'createdAt': createdAt.toIso8601String(),
      'fromAccountAddress': fromAccountAddress,
      'toAccountAddress': toAccountAddress,
      'amount': amount,
      'description': description,
      'status': status.name.toUpperCase(),
      'orderId': orderId,
      'paymentMode': paymentMode?.name.toUpperCase(),
    };
  }

  static PaymentMode? _parsePaymentMode(dynamic value) {
    if (value == null) return null;
    if (value is PaymentMode) return value;
    if (value is String) {
      try {
        return PaymentMode.values.byName(value.toLowerCase());
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
