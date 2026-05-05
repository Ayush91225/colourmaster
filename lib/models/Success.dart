

class Success {

  int? status;
  String? message;
  int? points;

  Success({this.status, this.message, this.points});

  Success.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    points = json['points'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['points'] = this.points;
    return data;
  }
}


