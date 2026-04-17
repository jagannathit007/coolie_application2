import 'package:license_sahayak/models/get_passenger_coolie_model.dart';
import 'package:license_sahayak/repositories/authentication_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingHistoryCtrl extends GetxController {
  final AuthenticationRepo authenticationRepo = AuthenticationRepo();
  final bookings = <Booking>[].obs;
  final isLoading = false.obs, hasMore = true.obs;
  final page = 1.obs;
  final limit = 10;
  final scrollController = ScrollController();

  final selectedStartDate = Rxn<DateTime>(DateTime.now()), selectedEndDate = Rxn<DateTime>(DateTime.now());

  String get startDateFormatted => selectedStartDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedStartDate.value!) : '';

  String get endDateFormatted => selectedEndDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate.value!) : '';

  String get startDateDisplay => selectedStartDate.value != null ? DateFormat('dd MMM yyyy').format(selectedStartDate.value!) : 'Start Date';

  String get endDateDisplay => selectedEndDate.value != null ? DateFormat('dd MMM yyyy').format(selectedEndDate.value!) : 'End Date';

  @override
  void onInit() {
    super.onInit();
    getHistory();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (hasMore.value && !isLoading.value) {
          getHistory();
        }
      }
    });
  }

  Future<void> clearFilters() async {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    await getHistory();
  }

  Future<void> getHistory() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final res = await authenticationRepo.getHistory(page: page.value, limit: limit, startDate: startDateFormatted, endDate: endDateFormatted);
      if (res != null) {
        final Map<String, dynamic> bookingsData = res['bookings'];
        final List<dynamic> docs = bookingsData['docs'];
        final bool hasNextPage = bookingsData['hasNextPage'] ?? false;
        final newBookings = docs.map((e) => Booking.fromJson(e)).toList();
        bookings.addAll(newBookings);
        hasMore.value = hasNextPage;
        if (hasNextPage) {
          page.value++;
        }
      }
    } catch (e) {
      debugPrint("ERROR in HISTORY: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> refreshHistory() async {
    bookings.clear();
    page.value = 1;
    hasMore.value = true;
    await getHistory();
  }

  String formatDate(String date) {
    try {
      return DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.parse(date).toUtc().toLocal());
    } catch (e) {
      return "N/A";
    }
  }

  String calculateTotalSpent() {
    if (bookings.isEmpty) return "0";
    try {
      double total = 0;
      for (var booking in bookings) {
        if (booking.fare?.baseFare != null) {
          total += double.tryParse(booking.fare!.baseFare.toString()) ?? 0;
        }
      }
      return total.toStringAsFixed(0);
    } catch (e) {
      return "0";
    }
  }

  bool get hasActiveFilter => selectedStartDate.value != null || selectedEndDate.value != null;

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
