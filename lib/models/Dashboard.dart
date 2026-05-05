class Dashboard {
  String? message;
  int? status;
  Data? data;

  Dashboard({this.message, this.status, this.data});

  Dashboard.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Sliders>? sliders;
  User? user;
  LastTransaction? lastTransaction;
  var lifeTimBalance;
  var giftBalance;
  var giftLifetimeBalance;
  Data({
    this.sliders,
    this.user,
    this.lastTransaction,
    this.lifeTimBalance,
    this.giftBalance,
    this.giftLifetimeBalance,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['sliders'] != null) {
      sliders = <Sliders>[];
      json['sliders'].forEach((v) {
        sliders!.add(Sliders.fromJson(v));
      });
    }
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    lastTransaction = json['last_transaction'] != null
        ? new LastTransaction.fromJson(json['last_transaction'])
        : null;
    lifeTimBalance = json['lifetime_balance'];
    giftBalance = json['gift_balance'];
    giftLifetimeBalance = json['gift_lifetime_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sliders != null) {
      data['sliders'] = sliders!.map((v) => v.toJson()).toList();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (this.lastTransaction != null) {
      data['last_transaction'] = this.lastTransaction!.toJson();
    }
    lifeTimBalance = data['lifetime_balance'];
    giftBalance = data['gift_balance'];
    giftLifetimeBalance = data['gift_lifetime_balance'];
    return data;
  }
}

class Sliders {
  int? id;
  String? title;
  String? link;
  String? image;

  Sliders({this.id, this.title, this.link, this.image});

  Sliders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    link = json['link'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['link'] = link;
    data['image'] = image;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? balance;

  User({this.id, this.name, this.email, this.balance});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['balance'] = balance;
    return data;
  }
}

class LastTransaction {
  int? id;
  int? points;
  String? type;
  String? remark;
  String? createdAt;

  LastTransaction(
      {this.id, this.points, this.type, this.remark, this.createdAt});

  LastTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    points = json['points'];
    type = json['type'];
    remark = json['remark'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['points'] = this.points;
    data['type'] = this.type;
    data['remark'] = this.remark;
    data['created_at'] = this.createdAt;
    return data;
  }
}
