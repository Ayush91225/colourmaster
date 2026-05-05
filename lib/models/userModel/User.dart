// ignore_for_file: file_names
class User {
  var status;
  var message;
  final ErrorData? errorData;
  User({
    this.status,
    this.message,
    this.errorData,
  });

  factory User.fromJson(Map<String, dynamic> json) =>User (
    status:json['status'],
    message:json['message'],
    errorData : json['errors'] != null ? ErrorData.fromJson(json['errors']) : null,
  );

  Map<String, dynamic> toJson() => {
    "status":status,
    "message":message,
    "errors":errorData,
  };
}

class ErrorData {
  final List<dynamic>? messages;
  ErrorData({
    this.messages
  });

  factory ErrorData.fromJson(Map<String, dynamic> json) =>ErrorData (
    messages: json['email']?? List<dynamic> ,
  );

  Map<String, dynamic> toJson() => {
    "email":messages,
  };
}