
class VerifyOTP {

  bool? error;
  List<dynamic>? messages;

  VerifyOTP({this.error,this.messages,});

  factory VerifyOTP.fromJson(Map<String, dynamic> json)=>
      VerifyOTP(
        error: json['error'] as bool,
        messages: json['messages']??List<dynamic>,
    );

  Map<String, dynamic> toJson() => {
    "error": error,
    "messages": messages,
  };
}

