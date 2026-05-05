class GiftData {
  int? status;
  String? message;
  List<GiftListData>? data;

  GiftData({this.status, this.message, this.data});

  GiftData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <GiftListData>[];
      json['data'].forEach((v) {
        data!.add(new GiftListData.fromJson(v));
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

class GiftListData {
  int? id;
  String? name;
  int? points;
  int? worthPrice;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;
  String? imageUrl;

  GiftListData(
      {this.id,
      this.name,
      this.points,
      this.worthPrice,
      this.image,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.imageUrl});

  GiftListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    points = json['points'];
    worthPrice = json['worth_price'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['points'] = points;
    data['worth_price'] = worthPrice;
    data['image'] = image;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['image_url'] = imageUrl;
    return data;
  }
}
