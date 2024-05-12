class KosiUserModel {
  String name;
  String userPhone;
  String userLatitude;
  String userLongitude;
  String uid;
  String deviceId;
  String regDate;
  String address;
  String accountType;
  String balance;
  String referalcode;



  KosiUserModel({
    required this.name,
    required this.userPhone,
    required this.userLatitude,
    required this.userLongitude,
    required this.uid,
    required this.deviceId,
    required this.regDate,
    required this.address,
    this.accountType = '',
    this.balance='',
    required this.referalcode,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userphone': userPhone,
      'userlatitude': userLatitude,
      'userlongitude': userLongitude,
      'uid': uid,
      'deviceid': deviceId,
      'regdate': regDate,
      'add': address,
      'accounttype': accountType,
      'referalcode':referalcode,
      'balance':balance,
    };
  }

  factory KosiUserModel.fromJson(Map<String, dynamic> json) {
    return KosiUserModel(
      name: json['name'] ?? '',
      userPhone: json['userphone'] ?? '',
      userLatitude: json['userlatitude'] ?? '',
      userLongitude: json['userlongitude'] ?? '',
      uid: json['uid'] ?? '',
      deviceId: json['deviceid'] ?? '',
      regDate: json['regdate'] ?? '',
      address: json['add'] ?? '',
      accountType: json['accounttype'] ?? '',
      referalcode: json['referalcode'] ?? '',
        balance:json['balance'] ?? ''
    );
  }
}
