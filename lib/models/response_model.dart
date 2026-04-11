import 'dart:convert';

ResponseModel responseModelFromJson(String str) => ResponseModel.fromJson(json.decode(str));

String responseModelToJson(ResponseModel data) => json.encode(data.toJson());

class ResponseModel {
  String message;
  dynamic data;
  int status;

  ResponseModel({required this.message, required this.data, required this.status});

  factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(message: json["message"], data: json["data"], status: json["status"]);

  Map<String, dynamic> toJson() => {"message": message, "data": data, "status": status};
}
