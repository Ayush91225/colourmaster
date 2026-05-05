// ignore_for_file: file_names
class RedeemHistoryData {
  var title;
  var amount;
  var date;

  RedeemHistoryData({
    this.title,
    this.amount,
    this.date,
  });

  factory RedeemHistoryData.fromJson(Map<String, dynamic> json) =>RedeemHistoryData (
    title:json['title'],
    amount:json['amount'],
    date:json['date'],
  );

  Map<String, dynamic> toJson() => {
    "title":title,
    "amount":amount,
    "date":date,
  };
}