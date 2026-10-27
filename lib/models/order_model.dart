class OrderItemModel {
  final String productId;
  final String title;
  final String thumbnail;
  final double price;
  final int quantity;
  final String? size;
  final String? color;

  OrderItemModel({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      size: json['size']?.toString(),
      color: json['color']?.toString(),
    );
  }
}

class RefundDetailsModel {
  final double refundAmount;
  final String transactionId;
  final String refundStatus;
  final DateTime? refundedAt;

  RefundDetailsModel({
    required this.refundAmount,
    required this.transactionId,
    required this.refundStatus,
    this.refundedAt,
  });

  factory RefundDetailsModel.fromJson(Map<String, dynamic> json) {
    return RefundDetailsModel(
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transactionId'] ?? '',
      refundStatus: json['refundStatus'] ?? '',
      refundedAt: json['refundedAt'] != null
          ? DateTime.tryParse(json['refundedAt'])
          : null,
    );
  }
}

class OrderAddressModel {
  final String fullName;
  final String mobile;
  final String pincode;
  final String state;
  final String city;
  final String area;
  final String houseNo;
  final String? landmark;

  OrderAddressModel({
    required this.fullName,
    required this.mobile,
    required this.pincode,
    required this.state,
    required this.city,
    required this.area,
    required this.houseNo,
    this.landmark,
  });

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderAddressModel(
      fullName: json['fullName'] ?? '',
      mobile: json['mobile'] ?? '',
      pincode: json['pincode'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      houseNo: json['houseNo'] ?? '',
      landmark: json['landmark'],
    );
  }
}

// OrderModel class ke andar yeh new fields add karein:
class OrderModel {
  // Existing fields...
  final String id;
  final String? userName;
  final String? userEmail;
  final List<OrderItemModel> items;
  final OrderAddressModel address;
  final double totalAmount;
  final double discount;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? courierPartner;
  final String? trackingId;
  final String? trackingUrl;
  final String? returnReason;
  final String? returnComment;
  final String? adminComment;            // 👈 Added
  final RefundDetailsModel? refundDetails; // 👈 Added
  final DateTime createdAt;

  OrderModel({
    required this.id,
    this.userName,
    this.userEmail,
    required this.items,
    required this.address,
    required this.totalAmount,
    required this.discount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.courierPartner,
    this.trackingId,
    this.trackingUrl,
    this.returnReason,
    this.returnComment,
    this.adminComment,
    this.refundDetails,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String? name;
    String? email;
    if (json['user'] is Map) {
      name = json['user']['fullName'] ?? json['user']['name'];
      email = json['user']['email'];
    }

    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userName: name,
      userEmail: email,
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      address: OrderAddressModel.fromJson(json['address'] ?? {}),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'COD',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      orderStatus: json['orderStatus'] ?? 'Pending',
      courierPartner: json['courierPartner'],
      trackingId: json['trackingId'],
      trackingUrl: json['trackingUrl'],
      returnReason: json['returnReason'],
      returnComment: json['returnComment'],
      adminComment: json['adminComment'],
      refundDetails: json['refundDetails'] != null
          ? RefundDetailsModel.fromJson(json['refundDetails'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}