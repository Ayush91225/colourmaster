


import '../../utils/global_key.dart';

class NotificationModel {

  List<NotificationData>? notificationDataArr;
  NotificationData? notificationData;
  bool? error;
  List<dynamic>? messages;
  NotificationModel({ this.notificationData,this.notificationDataArr,this.error,this.messages,});

  factory NotificationModel.fromJson(Map<String, dynamic> json)=>
     loginStatus?NotificationModel(
       notificationDataArr: json["data"] != null ? List<NotificationData>.from( json["data"].map((x) => NotificationData.fromJson(x))) : <NotificationData>[],
       error: json['error'] as bool,
       messages: json['messages']??List<dynamic>,
     ):NotificationModel(
        notificationData :json['data'] != null ? NotificationData.fromJson(json['data']) : null,
        error: json['error'] as bool,
        messages: json['messages']??List<dynamic>,
      );
  Map<String, dynamic> toJson() => {
    "data": notificationDataArr,
    "error": error,
    "messages": messages,
  };
}

class NotificationData {
  int? id;
  int? customerId;
  String? notification;
  String? image;
  int? isViewed;
  String? createdAt;

  NotificationData(
      {this.id,
        this.customerId,
        this.notification,
        this.image,
        this.isViewed,
        this.createdAt});

  NotificationData.fromJson(Map<String, dynamic> json){
    id = json['id'];
    customerId = json['customer_id'];
    notification = json['notification'];
    image = null;
    isViewed = json['is_viewed'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['notification'] = notification;
    data['image'] = image;
    data['is_viewed'] = isViewed;
    data['created_at'] = createdAt;
    return data;
  }
}