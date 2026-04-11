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
  final RateCard rateCard;
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
  final String address;
  final String faceId;
  final bool isApproved;
  final bool isActive;
  final bool isLoggedIn;
  final DateTime? lastLoginTime;
  final String fcm;
  final String rating;
  final String totalRatings;
  final String completedBookings;
  final String rejectedBookings;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String v;

  User({
    this.image,
    required this.rateCard,
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
    required this.address,
    required this.faceId,
    required this.isApproved,
    required this.isActive,
    required this.isLoggedIn,
    this.lastLoginTime,
    required this.fcm,
    required this.rating,
    required this.totalRatings,
    required this.completedBookings,
    required this.rejectedBookings,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
      rateCard: RateCard.fromJson(json['rateCard']),
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
      address: json['address'] ?? '',
      faceId: json['faceId'] ?? '',
      isApproved: json['isApproved'] ?? false,
      isActive: json['isActive'] ?? false,
      isLoggedIn: json['isLoggedIn'] ?? false,
      lastLoginTime: json['lastLoginTime'] != null ? DateTime.parse(json['lastLoginTime']) : null,
      fcm: json['fcm'] ?? '',
      rating: json['rating'] ?? '0',
      totalRatings: json['totalRatings'] ?? '0',
      completedBookings: json['completedBookings'] ?? '0',
      rejectedBookings: json['rejectedBookings'] ?? '0',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image?.toJson(),
      'rateCard': rateCard.toJson(),
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
      'address': address,
      'faceId': faceId,
      'isApproved': isApproved,
      'isActive': isActive,
      'isLoggedIn': isLoggedIn,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'fcm': fcm,
      'rating': rating,
      'totalRatings': totalRatings,
      'completedBookings': completedBookings,
      'rejectedBookings': rejectedBookings,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class ImageData {
  final String url;
  final String s3Key;

  ImageData({required this.url, required this.s3Key});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(url: json['url'] ?? '', s3Key: json['s3Key'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 's3Key': s3Key};
  }
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
