class QRRedeem {
  int? status;
  String? message;
  String? productName;
  int? points;
  String? balance;
  AlreadyUseQrUserData? alreadyUseQrUserData;
  ScannedQRData? scannedQRData;
  ScannedTransactionData? scannedTransactionData;
  QRRedeem(
      {this.status,
      this.message,
      this.points,
      this.balance,
      this.alreadyUseQrUserData,
      this.scannedQRData,
      this.scannedTransactionData});

  QRRedeem.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    points = json['points'];
    productName = json['product_name'];
    balance = json['balance'];
    alreadyUseQrUserData = json['data'] != null
        ? AlreadyUseQrUserData.fromJson(json['data'])
        : null;
    scannedQRData =
        json['qr'] != null ? ScannedQRData.fromJson(json['qr']) : null;
    scannedTransactionData = json['transaction'] != null
        ? ScannedTransactionData.fromJson(json['transaction'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['points'] = points;
    data['balance'] = balance;
    data['product_name'] = productName;
    if (alreadyUseQrUserData != null) {
      data['data'] = alreadyUseQrUserData!.toJson();
    }
    if (scannedQRData != null) {
      data['qr'] = scannedQRData!.toJson();
    }
    if (scannedTransactionData != null) {
      data['transaction'] = scannedTransactionData!.toJson();
    }
    return data;
  }
}

class AlreadyUseQrUserData {
  String? name;

  AlreadyUseQrUserData({this.name});

  AlreadyUseQrUserData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}

class ScannedQRData {
  int? id;
  String? qrId;
  String? qrImage;
  int? points;
  Null? remark;
  bool? isUsed;
  int? usedBy;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;
  String? qrType;
  ScannedQRData({
    this.id,
    this.qrId,
    this.qrImage,
    this.points,
    this.remark,
    this.isUsed,
    this.usedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.qrType,
  });

  ScannedQRData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    qrId = json['qr_id'];
    qrImage = json['qr_image'];
    points = json['points'];
    remark = json['remark'];
    isUsed = json['is_used'];
    usedBy = json['used_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    qrType = json['qr_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['qr_id'] = qrId;
    data['qr_image'] = qrImage;
    data['points'] = points;
    data['remark'] = remark;
    data['is_used'] = isUsed;
    data['used_by'] = usedBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['qr_type'] = qrType;
    return data;
  }
}

class ScannedTransactionData {
  int? userId;
  int? points;
  String? type;
  String? remark;
  String? transactionId;
  String? updatedAt;
  String? createdAt;
  int? id;

  ScannedTransactionData(
      {this.userId,
      this.points,
      this.type,
      this.remark,
      this.transactionId,
      this.updatedAt,
      this.createdAt,
      this.id});

  ScannedTransactionData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    points = json['points'];
    type = json['type'];
    remark = json['remark'];
    transactionId = json['transaction_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['points'] = points;
    data['type'] = type;
    data['remark'] = remark;
    data['transaction_id'] = transactionId;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
