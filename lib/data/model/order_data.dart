class Order {
  String orderId;
  DateTime? timestamp;
  String serviceName;
  String amount;
  String customerName;
  String customerAddress;
  String customerPhone;

  Order({
    required this.orderId,
    required this.timestamp,
    required this.serviceName,
    required this.amount,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
  });

  Order copyWith({
    String? orderId,
    DateTime? timestamp,
    String? serviceName,
    String? amount,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      timestamp: timestamp ?? this.timestamp,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'timestamp': timestamp?.toIso8601String(),
      'serviceName': serviceName,
      'amount': amount,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      serviceName: json['serviceName'] as String,
      amount: json['amount'] as String,
      customerName: json['customerName'] as String,
      customerAddress: json['customerAddress'] as String,
      customerPhone: json['customerPhone'] as String,
    );
  }
}
