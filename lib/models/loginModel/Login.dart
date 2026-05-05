

class Login {
  String? message;
  int? status;
  Data? data;

  Login({this.message, this.status, this.data});

  Login.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['message'] = message;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  UserData? user;
  String? token;

  Data({this.user, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    return data;
  }
}
class UserData {
  var id;
  String? name;
  String? email;
  var emailVerifiedAt;
  String? mobileNumber;
  String? balance;
  var otp;
  var otpExpiresAt;
  String? status;
  int? isAdmin;
  String? address;
  String? dob;
  var aadhaarImage;
  var createdAt;
  String? updatedAt;
  var deletedAt;
  var profileImage;
  UserData(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.mobileNumber,
        this.balance,
        this.otp,
        this.otpExpiresAt,
        this.status,
        this.isAdmin,
        this.address,
        this.dob,
        this.aadhaarImage,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.profileImage,});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    mobileNumber = json['mobile_number'];
    balance = json['balance'];
    otp = json['otp'];
    otpExpiresAt = json['otp_expires_at'];
    status = json['status'];
    isAdmin = json['is_admin'];
    address = json['address'];
    dob = json['dob'];
    aadhaarImage = json['aadhaar_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['mobile_number'] = mobileNumber;
    data['balance'] = balance;
    data['otp'] = otp;
    data['otp_expires_at'] = otpExpiresAt;
    data['status'] = status;
    data['is_admin'] = isAdmin;
    data['address'] = address;
    data['dob'] = dob;
    data['aadhaar_image'] = aadhaarImage;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['profile_image'] = profileImage;
    return data;
  }
}
