class SignInResponseModel {
  final int status;
  final String message;
  final SignInData data;

  SignInResponseModel({required this.status, required this.message, required this.data});

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) {
    return SignInResponseModel(status: json['status'] ?? 0, message: json['message'] ?? '', data: json['data'] != null ? SignInData.fromJson(json['data']) : SignInData(requiresVerification: false));
  }
}

class SignInData {
  final bool requiresVerification;

  SignInData({required this.requiresVerification});

  factory SignInData.fromJson(Map<String, dynamic> json) {
    return SignInData(requiresVerification: json['requiresVerification'] ?? false);
  }
}
