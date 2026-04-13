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
  String? id;
  String? name;
  String? mobileNo;

  PassengerId({this.id, this.name, this.mobileNo});

  factory PassengerId.fromJson(Map<String, dynamic> json) => PassengerId(id: json["_id"], name: json["name"], mobileNo: json["mobileNo"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "mobileNo": mobileNo};
}

class PickupDetails {
  String? station;
  String? weight;
  String? coachNumber;
  String? description;

  PickupDetails({this.station, this.weight, this.coachNumber, this.description});

  factory PickupDetails.fromJson(Map<String, dynamic> json) => PickupDetails(station: json["station"], weight: json['weight'], coachNumber: json["coachNumber"], description: json["description"]);

  Map<String, dynamic> toJson() => {"station": station, "weight": weight, "coachNumber": coachNumber, "description": description};
}

class Timestamp {
  DateTime? bookedAt;
  dynamic acceptedAt;
  dynamic pickupTime;
  dynamic completedAt;

  Timestamp({this.bookedAt, this.acceptedAt, this.pickupTime, this.completedAt});

  factory Timestamp.fromJson(Map<String, dynamic> json) {
    return Timestamp(bookedAt: DateTime.parse(json["bookedAt"]), acceptedAt: json["acceptedAt"], pickupTime: json["pickupTime"], completedAt: json["completedAt"]);
  }

  Map<String, dynamic> toJson() => {"bookedAt": bookedAt?.toIso8601String(), "acceptedAt": acceptedAt, "pickupTime": pickupTime, "completedAt": completedAt};
}
