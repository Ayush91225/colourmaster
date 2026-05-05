class Register {
  String? message;
  int? status;
  Data? data;

  Register({this.message, this.status, this.data});

  Register.fromJson(Map<String, dynamic> json) {
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
  Errors? errors;

  Data({this.errors});

  Data.fromJson(Map<String, dynamic> json) {
    errors =
    json['errors'] != null ? Errors.fromJson(json['errors']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (errors != null) {
      data['errors'] = errors!.toJson();
    }
    return data;
  }
}

class Errors {
  List<dynamic>? name;
  List<dynamic>? email;
  List<dynamic>? mobileNumber;

  Errors({this.name, this.email, this.mobileNumber});

  Errors.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    mobileNumber = json['mobile_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['name'] = name;
    data['email'] = email;
    data['mobile_number'] = mobileNumber;
    return data;
  }
}