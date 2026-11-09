enum TransactionStatus {
  success,
  declined,
  voided,
}

class TransactionModel {
  final String id;
  final int amount;
  final String brand;
  final String last4;
  final String? maskedPan;
  final TransactionStatus status;
  final String? reason;
  final DateTime createdAt;
  final String? idempotencyKey;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.brand,
    required this.last4,
    this.maskedPan,
    required this.status,
    this.reason,
    required this.createdAt,
    this.idempotencyKey,
  });

  String get formattedCard => '$brand •••• $last4';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    TransactionStatus parseStatus(String s) {
      switch (s.toUpperCase()) {
        case 'SUCCESS':
          return TransactionStatus.success;
        case 'DECLINED':
          return TransactionStatus.declined;
        case 'VOIDED':
          return TransactionStatus.voided;
        default:
          return TransactionStatus.success;
      }
    }

    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      brand: json['brand'] as String? ?? 'Kartu',
      last4: json['last4'] as String? ?? '••••',
      maskedPan: json['maskedPan'] as String?,
      status: json['status'] is TransactionStatus
          ? json['status'] as TransactionStatus
          : parseStatus(json['status'] as String? ?? 'SUCCESS'),
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      idempotencyKey: json['idempotencyKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'brand': brand,
    'last4': last4,
    'maskedPan': maskedPan,
    'status': status.name.toUpperCase(),
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
    'idempotencyKey': idempotencyKey,
  };

  TransactionModel copyWith({
    String? id,
    int? amount,
    String? brand,
    String? last4,
    String? maskedPan,
    TransactionStatus? status,
    String? reason,
    DateTime? createdAt,
    String? idempotencyKey,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      maskedPan: maskedPan ?? this.maskedPan,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }
}
