class Transaction {
  int? status;
  String? message;
  List<TransactionData>? data;

  Transaction({this.status, this.message, this.data});

  Transaction.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TransactionData>[];
      json['data'].forEach((v) {
        data!.add(new TransactionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TransactionData {
  int? id;
  int? userId;
  int? points;
  String? type;
  String? remark;
  String? createdAt;
  String? updatedAt;
  String? transactionId;
  String? status;
  String? transactionType;
  String? message;
  String? productName;

  TransactionData({
    this.id,
    this.userId,
    this.points,
    this.type,
    this.remark,
    this.createdAt,
    this.updatedAt,
    this.transactionId,
    this.status,
    this.transactionType,
    this.message,
    this.productName,
  });

  TransactionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    points = json['points'];
    type = json['type'];
    remark = json['remark'] ?? "";
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    transactionId = json['transaction_id'] ?? 'NA';
    status = json['status'];
    transactionType = json['transaction_type'];
    message = json['message'] ?? "NA";
    productName = json['product_name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['points'] = points;
    data['type'] = type;
    data['remark'] = remark;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['status'] = status;
    data['transaction_type'] = transactionType;
    data['message'] = message;
    data['product_name'] = productName;
    return data;
  }
}
