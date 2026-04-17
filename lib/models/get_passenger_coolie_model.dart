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
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "bookingId": bookingId,
    "__v": v,
  };
}

class Fare {
  String? baseFare;
  String? waitingTime;
  String? waitingCharges;
  String? totalFare;

  Fare({this.baseFare, this.waitingTime, this.waitingCharges, this.totalFare});

  factory Fare.fromJson(Map<String, dynamic> json) => Fare(baseFare: json["baseFare"], waitingTime: json["waitingTime"], waitingCharges: json["waitingCharges"], totalFare: json["totalFare"]);

  Map<String, dynamic> toJson() => {"baseFare": baseFare, "waitingTime": waitingTime, "waitingCharges": waitingCharges, "totalFare": totalFare};
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

class PickupDetails {
  String? station;
  String? weight;
  String? originalWeight;
  String? pnrNumber;
  String? utsNumber;
  String? ticketType;
  String? trainNumber;
  String? coachNumber;
  String? description;
  String? weightStatus;

  PickupDetails({this.station, this.weight, this.originalWeight, this.pnrNumber, this.utsNumber, this.trainNumber, this.ticketType, this.coachNumber, this.description, this.weightStatus});

  factory PickupDetails.fromJson(Map<String, dynamic> json) => PickupDetails(
    station: json["station"],
    weight: json['weight'],
    originalWeight: json['originalWeight'],
    pnrNumber: json["pnrNumber"],
    utsNumber: json["utsNumber"],
    trainNumber: json["trainNumber"],
    ticketType: json["ticketType"],
    coachNumber: json["coachNumber"],
    description: json["description"],
    weightStatus: json['weightStatus'],
  );

  Map<String, dynamic> toJson() => {
    "station": station,
    "weight": weight,
    "originalWeight": originalWeight,
    "pnrNumber": pnrNumber,
    "utsNumber": utsNumber,
    "trainNumber": trainNumber,
    "ticketType": ticketType,
    "coachNumber": coachNumber,
    "description": description,
    "weightStatus": weightStatus,
  };
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
