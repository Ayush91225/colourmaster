class Product {
  String? status;
  List<ProductData>? productDataArr;
  String? message;

  Product({
    this.status,
    this.productDataArr,
    this.message,
  });

  Product.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'] ?? "";
    if (json['data'] != null) {
      productDataArr = <ProductData>[];
      json['data'].forEach((v) {
        productDataArr!.add(ProductData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = this.message;
    if (this.productDataArr != null) {
      data['data'] = this.productDataArr!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductData {
  int? id;
  String? name;
  String? image;
  int? points;
  String? description;
  String? expiryDate;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  String? imageUrl;
  int? earnPoints;
  int? remainingPoints;

  ProductData(
      {this.id,
      this.name,
      this.image,
      this.points,
      this.description,
      this.expiryDate,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.imageUrl,
      this.earnPoints,
      this.remainingPoints});

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    points = json['points'];
    description = json['description'];
    expiryDate = json['expiry_date'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageUrl = json['image_url'];
    earnPoints = json['earn_points'];
    remainingPoints = json['remaining_points'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['points'] = points;
    data['description'] = description;
    data['expiry_date'] = expiryDate;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_url'] = imageUrl;
    data['earn_points'] = earnPoints;
    data['remaining_points'] = remainingPoints;
    return data;
  }
}
