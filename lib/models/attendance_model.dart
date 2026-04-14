class AttendanceResponseModel {
  final MukadamInfo? mukadamInfo;
  final AttendanceSummary summary;
  final AttendancePagination attendance;

  AttendanceResponseModel({required this.mukadamInfo, required this.summary, required this.attendance});

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceResponseModel(
      mukadamInfo: json['mukadamInfo'] != null ? MukadamInfo.fromJson(json['mukadamInfo']) : null,
      summary: AttendanceSummary.fromJson(json['summary'] ?? {}),
      attendance: AttendancePagination.fromJson(json['attendance'] ?? {}),
    );
  }
}

class MukadamInfo {
  final String? mukadamId;
  final String? name;
  final String? mobileNo;
  final String? shiftType;
  final String? shiftTiming;
  final StationInfo? station;

  MukadamInfo({this.mukadamId, this.name, this.mobileNo, this.shiftType, this.shiftTiming, this.station});

  factory MukadamInfo.fromJson(Map<String, dynamic> json) {
    return MukadamInfo(
      mukadamId: json['mukadamId']?.toString(),
      name: json['name'],
      mobileNo: json['mobileNo'],
      shiftType: json['shiftType'],
      shiftTiming: json['shiftTiming'],
      station: json['station'] != null ? StationInfo.fromJson(json['station']) : null,
    );
  }
}

class StationInfo {
  final String? id;
  final String? name;
  final String? code;

  StationInfo({this.id, this.name, this.code});

  factory StationInfo.fromJson(Map<String, dynamic> json) {
    return StationInfo(id: json['_id']?.toString(), name: json['name'], code: json['code']);
  }
}

class AttendanceSummary {
  final int totalCheckIns;
  final int activeNow;
  final double totalOnlineHours;
  final int totalOnlineMinutes;
  final int totalJobsCompleted;
  final int totalJobsRejected;
  final int uniqueCollies;
  final int totalAssignedCollies;

  AttendanceSummary({
    required this.totalCheckIns,
    required this.activeNow,
    required this.totalOnlineHours,
    required this.totalOnlineMinutes,
    required this.totalJobsCompleted,
    required this.totalJobsRejected,
    required this.uniqueCollies,
    required this.totalAssignedCollies,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalCheckIns: int.tryParse(json['totalCheckIns'].toString()) ?? 0,
      activeNow: int.tryParse(json['activeNow'].toString()) ?? 0,
      totalOnlineHours: double.tryParse(json['totalOnlineHours'].toString()) ?? 0.0,
      totalOnlineMinutes: int.tryParse(json['totalOnlineMinutes'].toString()) ?? 0,
      totalJobsCompleted: int.tryParse(json['totalJobsCompleted'].toString()) ?? 0,
      totalJobsRejected: int.tryParse(json['totalJobsRejected'].toString()) ?? 0,
      uniqueCollies: int.tryParse(json['uniqueCollies'].toString()) ?? 0,
      totalAssignedCollies: int.tryParse(json['totalAssignedCollies'].toString()) ?? 0,
    );
  }
}

class AttendancePagination {
  final List<AttendanceRecord> docs;
  final int totalDocs;
  final int page;
  final int totalPages;
  final int limit;

  AttendancePagination({required this.docs, required this.totalDocs, required this.page, required this.totalPages, required this.limit});

  factory AttendancePagination.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['docs'] as List<dynamic>? ?? [];
    return AttendancePagination(
      docs: rawDocs.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>)).toList(),
      totalDocs: int.tryParse(json['totalDocs'].toString()) ?? 0,
      page: int.tryParse(json['page'].toString()) ?? 1,
      totalPages: int.tryParse(json['totalPages'].toString()) ?? 0,
      limit: int.tryParse(json['limit'].toString()) ?? 50,
    );
  }
}

class AttendanceRecord {
  final String? sessionId;
  final String? collieId;
  final String? collieName;
  final String? collieMobile;
  final String? collieBuckle;
  final String? collieImage;
  final String? stationName;
  final String? stationCode;
  final String? checkInTime;
  final String? checkOutTime;
  final bool isActive;
  final String? status;
  final double onlineDurationHours;
  final int onlineDurationMinutes;
  final int completedJobs;
  final int rejectedJobs;
  final double earningsAmount;
  final String? dayOfWeek;
  final String? date;
  final String? approvalStatus;

  AttendanceRecord({
    this.sessionId,
    this.collieId,
    this.collieName,
    this.collieMobile,
    this.collieBuckle,
    this.collieImage,
    this.stationName,
    this.stationCode,
    this.checkInTime,
    this.checkOutTime,
    required this.isActive,
    this.status,
    required this.onlineDurationHours,
    required this.onlineDurationMinutes,
    required this.completedJobs,
    required this.rejectedJobs,
    required this.earningsAmount,
    this.dayOfWeek,
    this.date,
    this.approvalStatus,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      sessionId: json['sessionId']?.toString() ?? json['_id']?.toString(),
      collieId: json['collieId']?.toString(),
      collieName: json['collieName'],
      collieMobile: json['collieMobile'],
      collieBuckle: json['collieBuckle'],
      collieImage: json['collieImage'],
      stationName: json['stationName'],
      stationCode: json['stationCode'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      isActive: json['isActive'] ?? false,
      status: json['status'],
      onlineDurationHours: double.tryParse(json['onlineDurationHours'].toString()) ?? 0.0,
      onlineDurationMinutes: int.tryParse(json['onlineDurationMinutes'].toString()) ?? 0,
      completedJobs: int.tryParse(json['completedJobs'].toString()) ?? 0,
      rejectedJobs: int.tryParse(json['rejectedJobs'].toString()) ?? 0,
      earningsAmount: double.tryParse(json['earningsAmount'].toString()) ?? 0.0,
      dayOfWeek: json['dayOfWeek'],
      date: json['date'],
      approvalStatus: json['approvalStatus'],
    );
  }
}
