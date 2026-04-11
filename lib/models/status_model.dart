class BookingStatusResponse {
  final int status;
  final String message;
  final String data;

  BookingStatusResponse({required this.status, required this.message, required this.data});

  factory BookingStatusResponse.fromJson(Map<String, dynamic> json) {
    return BookingStatusResponse(status: json['status'] ?? 0, message: json['message'] ?? '', data: json['data'] ?? '');
  }
}
