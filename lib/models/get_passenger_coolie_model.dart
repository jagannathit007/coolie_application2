import 'dart:convert';

GetPassengerCoolieModel getPassengerCoolieModelFromJson(String str) => GetPassengerCoolieModel.fromJson(json.decode(str));

String getPassengerCoolieModelToJson(GetPassengerCoolieModel data) => json.encode(data.toJson());

class GetPassengerCoolieModel {
  Booking? booking;

  GetPassengerCoolieModel({this.booking});

  factory GetPassengerCoolieModel.fromJson(Map<String, dynamic> json) => GetPassengerCoolieModel(booking: Booking.fromJson(json["booking"]));

  Map<String, dynamic> toJson() => {"booking": booking?.toJson()};
}

class Booking {
  PickupDetails? pickupDetails;
  Timestamp? timestamp;
  Fare? fare;
  String? id;
  PassengerId? passengerId;
  String? collieId;
  String? otp;
  String? status;
  String? destination;
  dynamic rating;
  String? feedback;
  String? complaint;
  bool? isDeleted;
  bool? allowCancel;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? bookingId;
  String? v;

  Booking({
    this.pickupDetails,
    this.timestamp,
    this.fare,
    this.id,
    this.passengerId,
    this.collieId,
    this.otp,
    this.status,
    this.destination,
    this.rating,
    this.feedback,
    this.complaint,
    this.isDeleted,
    this.allowCancel,
    this.createdAt,
    this.updatedAt,
    this.bookingId,
    this.v,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    pickupDetails: PickupDetails.fromJson(json["pickupDetails"]),
    timestamp: Timestamp.fromJson(json["timestamp"]),
    fare: Fare.fromJson(json["fare"]),
    id: json["_id"],
    passengerId: PassengerId.fromJson(json["passengerId"]),
    collieId: json["collieId"],
    otp: json["otp"],
    status: json["status"],
    destination: json["destination"],
    rating: json["rating"],
    feedback: json["feedback"],
    complaint: json["complaint"],
    isDeleted: json["isDeleted"],
    allowCancel: json["allowCancel"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    bookingId: json["bookingId"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "pickupDetails": pickupDetails?.toJson(),
    "timestamp": timestamp?.toJson(),
    "fare": fare?.toJson(),
    "_id": id,
    "passengerId": passengerId?.toJson(),
    "collieId": collieId,
    "otp": otp,
    "status": status,
    "destination": destination,
    "rating": rating,
    "feedback": feedback,
    "complaint": complaint,
    "isDeleted": isDeleted,
    "allowCancel": allowCancel,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "bookingId": bookingId,
    "__v": v,
  };
}

class Fare {
  final int baseFare;
  final int waitingTime;
  final int waitingCharges;
  final int totalFare;
  final int extraSlots;
  final int totalSeconds;

  Fare({required this.baseFare, required this.waitingTime, required this.waitingCharges, required this.totalFare, this.extraSlots = 0, this.totalSeconds = 0});

  factory Fare.fromJson(Map<String, dynamic> json) => Fare(
    baseFare: int.tryParse(json['baseFare']?.toString() ?? '0') ?? 0,
    waitingTime: int.tryParse((json['waitingTime'] ?? json['totalMinutes'])?.toString() ?? '0') ?? 0,
    waitingCharges: int.tryParse(json['waitingCharges']?.toString() ?? '0') ?? 0,
    totalFare: int.tryParse(json['totalFare']?.toString() ?? '0') ?? 0,
    extraSlots: int.tryParse(json['extraSlots']?.toString() ?? '0') ?? 0,
    totalSeconds: int.tryParse(json['totalSeconds']?.toString() ?? '0') ?? 0,
  );

  Map<String, dynamic> toJson() => {'baseFare': baseFare, 'waitingTime': waitingTime, 'waitingCharges': waitingCharges, 'totalFare': totalFare, 'extraSlots': extraSlots, 'totalSeconds': totalSeconds};
}

class PassengerId {
  final String name;
  final String mobileNo;
  final String image;

  PassengerId({required this.name, required this.mobileNo, required this.image});

  factory PassengerId.fromJson(Map<String, dynamic> json) {
    return PassengerId(name: json['name']?.toString() ?? 'Unknown Coolie', mobileNo: json['mobileNo']?.toString() ?? '', image: json['image']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {'name': name, 'mobileNo': mobileNo, 'image': image};
}

class BookingPackage {
  final String rangeId;
  final int minKg;
  final int? maxKg;
  final int rate;
  final int count;

  BookingPackage({required this.rangeId, required this.minKg, this.maxKg, required this.rate, required this.count});

  factory BookingPackage.fromJson(Map<String, dynamic> json) => BookingPackage(
    rangeId: json['rangeId']?.toString() ?? '',
    minKg: int.tryParse(json['minKg']?.toString() ?? '0') ?? 0,
    maxKg: json['maxKg'] != null ? int.tryParse(json['maxKg'].toString()) : null,
    rate: int.tryParse(json['rate']?.toString() ?? '0') ?? 0,
    count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
  );

  Map<String, dynamic> toJson() => {'rangeId': rangeId, 'minKg': minKg, if (maxKg != null) 'maxKg': maxKg, 'rate': rate, 'count': count};

  String get label => maxKg != null ? '$minKg–$maxKg kg' : '$minKg kg+';

  int get subtotal => rate * count;
}

class PickupDetails {
  final String? station;
  final String? pnrNumber;
  final String? utsNumber;
  final String? ticketType;
  final String? trainNumber;
  final String? coachNumber;
  final String? description;
  final List<BookingPackage> packages;

  PickupDetails({this.station, this.pnrNumber, this.utsNumber, this.trainNumber, this.ticketType, this.coachNumber, this.description, this.packages = const []});

  factory PickupDetails.fromJson(Map<String, dynamic> json) => PickupDetails(
    station: json["station"],
    pnrNumber: json["pnrNumber"],
    utsNumber: json["utsNumber"],
    trainNumber: json["trainNumber"],
    ticketType: json["ticketType"],
    coachNumber: json["coachNumber"],
    description: json["description"],
    packages: (json['packages'] as List<dynamic>?)?.map((e) => BookingPackage.fromJson(e as Map<String, dynamic>)).where((p) => p.count > 0).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    "station": station,
    "pnrNumber": pnrNumber,
    "utsNumber": utsNumber,
    "trainNumber": trainNumber,
    "ticketType": ticketType,
    "coachNumber": coachNumber,
    "description": description,
    "packages": packages.map((p) => p.toJson()).toList(),
  };

  int get totalPackages => packages.fold(0, (sum, p) => sum + p.count);
}

class Timestamp {
  DateTime? bookedAt;
  DateTime? acceptedAt;
  DateTime? pickupTime;
  DateTime? completedAt;

  Timestamp({this.bookedAt, this.acceptedAt, this.pickupTime, this.completedAt});

  factory Timestamp.fromJson(Map<String, dynamic> json) => Timestamp(
    bookedAt: DateTime.tryParse(json["bookedAt"].toString()),
    acceptedAt: DateTime.tryParse(json["acceptedAt"].toString()),
    pickupTime: DateTime.tryParse(json["pickupTime"].toString()),
    completedAt: DateTime.tryParse(json["completedAt"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "bookedAt": bookedAt?.toIso8601String(),
    "acceptedAt": acceptedAt?.toIso8601String(),
    "pickupTime": pickupTime?.toIso8601String(),
    "completedAt": completedAt?.toIso8601String(),
  };
}
