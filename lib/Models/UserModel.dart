class UserModel {
  String name;
  String userPhone;
  String userLatitude;
  String userLongitude;
  String uid;
  String deviceId;
  String regDate;
  String address;
  String accountType;



  UserModel({
    required this.name,
    required this.userPhone,
    required this.userLatitude,
    required this.userLongitude,
    required this.uid,
    required this.deviceId,
    required this.regDate,
    required this.address,
    this.accountType = '',
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
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      userPhone: json['userphone'] ?? '',
      userLatitude: json['userlatitude'] ?? '',
      userLongitude: json['userlongitude'] ?? '',
      uid: json['uid'] ?? '',
      deviceId: json['deviceid'] ?? '',
      regDate: json['regdate'] ?? '',
      address: json['add'] ?? '',
      accountType: json['accounttype'] ?? '',
    );
  }
}
