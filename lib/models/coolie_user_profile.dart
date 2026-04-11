class CoolieUserProfile {
  final String id;
  final String name;
  final String mobileNo;
  final String emailId;
  final String gender;
  final String age;
  final String buckleNumber;
  final String stationId;
  final String address;
  final String faceEmbeddingId;
  final bool isApproved;
  final bool isActive;
  final bool isLoggedIn;
  final bool isDeleted;
  final String lastLoginTime;
  final String fcm;
  final double? latitude;
  final double? longitude;
  final String? currentBookingId;
  final String rating;
  final String totalRatings;
  final String completedBookings;
  final String rejectedBookings;
  final String deviceType;
  final String createdAt;
  final String updatedAt;
  final String v;
  final ImageData? image;
  final RateCard? rateCard;

  CoolieUserProfile({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.emailId,
    required this.gender,
    required this.age,
    required this.buckleNumber,
    required this.stationId,
    required this.address,
    required this.faceEmbeddingId,
    required this.isApproved,
    required this.isLoggedIn,
    required this.isActive,
    required this.isDeleted,
    required this.lastLoginTime,
    required this.fcm,
    this.latitude,
    this.longitude,
    this.currentBookingId,
    required this.rating,
    required this.totalRatings,
    required this.completedBookings,
    required this.rejectedBookings,
    required this.deviceType,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.image,
    this.rateCard,
  });

  factory CoolieUserProfile.fromJson(Map<String, dynamic> json) {
    return CoolieUserProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      emailId: json['emailId'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? '',
      buckleNumber: json['buckleNumber'] ?? '',
      stationId: json['stationId'] ?? '',
      address: json['address'] ?? '',
      faceEmbeddingId: json['faceEmbeddingId'] ?? '',
      isApproved: json['isApproved'] ?? false,
      isActive: json['isActive'] ?? false,
      isLoggedIn: json['isLoggedIn'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      lastLoginTime: json['lastLoginTime'] ?? '',
      fcm: json['fcm'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      currentBookingId: json['currentBookingId'],
      rating: json['rating']?.toString() ?? '0',
      totalRatings: json['totalRatings']?.toString() ?? '0',
      completedBookings: json['completedBookings']?.toString() ?? '0',
      rejectedBookings: json['rejectedBookings']?.toString() ?? '0',
      deviceType: json['deviceType'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v']?.toString() ?? '0',
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
      rateCard: json['rateCard'] != null ? RateCard.fromJson(json['rateCard']) : null,
    );
  }
}

class ImageData {
  final String url;
  final String s3Key;

  ImageData({required this.url, required this.s3Key});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(url: json['url'] ?? '', s3Key: json['s3Key'] ?? '');
  }
}

class RateCard {
  final String baseRate;
  final String baseTime;
  final String waitingRate;

  RateCard({required this.baseRate, required this.baseTime, required this.waitingRate});

  factory RateCard.fromJson(Map<String, dynamic> json) {
    return RateCard(baseRate: json['baseRate'] ?? '', baseTime: json['baseTime'] ?? '', waitingRate: json['waitingRate'] ?? '');
  }
}
