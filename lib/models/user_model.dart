class UserModel {
  final User user;
  final String token;

  UserModel({required this.user, required this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(user: User.fromJson(json['user']), token: json['token']);
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }

  @override
  String toString() {
    return 'UserModel{user: $user, token: $token}';
  }
}

class User {
  final ImageData? image;
  final double? latitude;
  final double? longitude;
  final String? currentBookingId;
  final String id;
  final String name;
  final String mobileNo;
  final String age;
  final String deviceType;
  final String emailId;
  final String gender;
  final String buckleNumber;
  final String stationId;
  final String address;
  final bool isLoggedIn;
  final bool isCheckedIn;
  final bool? isApprovalRequested;
  final String v;

  User({
    this.image,
    this.latitude,
    this.longitude,
    this.currentBookingId,
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.age,
    required this.deviceType,
    required this.emailId,
    required this.gender,
    required this.buckleNumber,
    required this.stationId,
    required this.address,
    required this.isLoggedIn,
    required this.isCheckedIn,
    this.isApprovalRequested,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      currentBookingId: json['currentBookingId'],
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      age: json['age'] ?? '',
      deviceType: json['deviceType'] ?? '',
      emailId: json['emailId'] ?? '',
      gender: json['gender'] ?? '',
      buckleNumber: json['buckleNumber'] ?? '',
      stationId: json['stationId'] ?? '',
      address: json['address'] ?? '',
      isLoggedIn: json['isLoggedIn'] ?? false,
      isCheckedIn: json['isCheckedIn'] ?? false,
      isApprovalRequested: json['isApprovalRequested'] ?? false,
      v: json['__v'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'currentBookingId': currentBookingId,
      '_id': id,
      'name': name,
      'mobileNo': mobileNo,
      'age': age,
      'deviceType': deviceType,
      'emailId': emailId,
      'gender': gender,
      'buckleNumber': buckleNumber,
      'stationId': stationId,
      'address': address,
      'isLoggedIn': isLoggedIn,
      'isCheckedIn': isCheckedIn,
      'isApprovalRequested': isApprovalRequested,
      '__v': v,
    };
  }
}

class ImageData {
  final String url;

  ImageData({required this.url});

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(url: json['url'] ?? '');

  Map<String, dynamic> toJson() => {'url': url};
}

class RateCard {
  final String baseRate;
  final String baseTime;
  final String waitingRate;

  RateCard({required this.baseRate, required this.baseTime, required this.waitingRate});

  factory RateCard.fromJson(Map<String, dynamic> json) {
    return RateCard(baseRate: json['baseRate'] ?? '0', baseTime: json['baseTime'] ?? '0', waitingRate: json['waitingRate'] ?? '0');
  }

  Map<String, dynamic> toJson() {
    return {'baseRate': baseRate, 'baseTime': baseTime, 'waitingRate': waitingRate};
  }
}
