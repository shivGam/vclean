enum PriorityList {
  urgent,
  usual
}

enum OrderStatus {
  pending,
  complete,
  cancelled
}

class Order {
  String orderId;
  DateTime? timestamp;
  String serviceName;
  String amount;
  String customerId;
  String customerName;
  String customerAddress;
  String customerPhone;
  List<String> branch;
  PriorityList priorities;
  OrderStatus status;
  DateTime? pickupTime;

  Order({
    required this.orderId,
    required this.timestamp,
    required this.serviceName,
    required this.amount,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.branch,
    this.priorities = PriorityList.usual,
    this.status = OrderStatus.pending,
    this.pickupTime,
  });

  Order copyWith({
    String? orderId,
    DateTime? timestamp,
    String? serviceName,
    String? amount,
    String? customerId,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    List<String>? branch,
    PriorityList? priorities,
    OrderStatus? status,
    DateTime? pickupTime,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      timestamp: timestamp ?? this.timestamp,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      branch: branch ?? this.branch,
      priorities: priorities ?? this.priorities,
      status: status ?? this.status,
      pickupTime: pickupTime ?? this.pickupTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'timestamp': timestamp?.toIso8601String(),
      'serviceName': serviceName,
      'amount': amount,
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'branch': branch,
      'priorities': priorities.index,
      'status': status.index,
      'pickupTime': pickupTime?.toIso8601String(),
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
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerAddress: json['customerAddress'] as String,
      customerPhone: json['customerPhone'] as String,
      branch: List<String>.from(json['branch'] as List),
      priorities: PriorityList.values.elementAtOrNull(json['priorities'] as int) ?? PriorityList.usual,
      status: OrderStatus.values.elementAtOrNull(json['status'] as int) ?? OrderStatus.pending,
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'] as String)
          : null,
    );
  }
}