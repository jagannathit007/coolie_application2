class PunchReportData {
  final PunchReportSummary summary;
  final PunchReportFilters filters;
  final PunchReport report;

  PunchReportData({required this.summary, required this.filters, required this.report});

  factory PunchReportData.fromJson(Map<String, dynamic> json) {
    return PunchReportData(
      summary: PunchReportSummary.fromJson(json['summary'] ?? {}),
      filters: PunchReportFilters.fromJson(json['filters'] ?? {}),
      report: PunchReport.fromJson(json['attendance'] ?? {}),
    );
  }
}

class PunchReportSummary {
  final int totalSessions;
  final int uniqueCollies;
  final double totalHours;
  final int totalMinutes;
  final int totalCompleted;
  final int totalRejected;
  final int totalEarnings;
  final int activeSessions;

  PunchReportSummary({
    required this.totalSessions,
    required this.uniqueCollies,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalCompleted,
    required this.totalRejected,
    required this.totalEarnings,
    required this.activeSessions,
  });

  factory PunchReportSummary.fromJson(Map<String, dynamic> json) {
    return PunchReportSummary(
      totalSessions: int.tryParse(json['totalSessions'].toString()) ?? 0,
      uniqueCollies: int.tryParse(json['uniqueCollies'].toString()) ?? 0,
      totalHours: double.tryParse(json['totalHours'].toString()) ?? 0.0,
      totalMinutes: int.tryParse(json['totalMinutes'].toString()) ?? 0,
      totalCompleted: int.tryParse(json['totalCompleted'].toString()) ?? 0,
      totalRejected: int.tryParse(json['totalRejected'].toString()) ?? 0,
      totalEarnings: int.tryParse(json['totalEarnings'].toString()) ?? 0,
      activeSessions: int.tryParse(json['activeSessions'].toString()) ?? 0,
    );
  }
}

class PunchReportFilters {
  final String? startDate;
  final String? endDate;
  final String? collieId;
  final String? stationId;

  PunchReportFilters({this.startDate, this.endDate, this.collieId, this.stationId});

  factory PunchReportFilters.fromJson(Map<String, dynamic> json) {
    return PunchReportFilters(startDate: json['startDate'], endDate: json['endDate'], collieId: json['collieId'], stationId: json['stationId']);
  }
}

class PunchReport {
  final List<PunchReportCollie> docs;
  final int totalDocs;
  final int limit;
  final int page;
  final int totalPages;
  final bool hasPrevPage;
  final bool hasNextPage;
  final int? prevPage;
  final int? nextPage;

  PunchReport({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.page,
    required this.totalPages,
    required this.hasPrevPage,
    required this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  factory PunchReport.fromJson(Map<String, dynamic> json) {
    return PunchReport(
      docs: (json['docs'] as List?)?.map((e) => PunchReportCollie.fromJson(e)).toList() ?? [],
      totalDocs: int.tryParse(json['totalDocs'].toString()) ?? 0,
      limit: int.tryParse(json['limit'].toString()) ?? 50,
      page: int.tryParse(json['page'].toString()) ?? 1,
      totalPages: int.tryParse(json['totalPages'].toString()) ?? 1,
      hasPrevPage: json['hasPrevPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
      prevPage: json['prevPage'],
      nextPage: json['nextPage'],
    );
  }
}

class PunchReportCollie {
  final String workerType;
  final String collieId;
  final String collieName;
  final String collieMobile;
  final String buckleNumber;
  final String? collieImage;
  final String stationId;
  final String stationName;
  final String stationCode;
  final int totalSessions;
  final double totalHours;
  final int totalMinutes;
  final int totalCompleted;
  final int totalRejected;
  final int totalEarnings;
  final bool isCurrentlyActive;
  final List<PunchSession> sessions;

  PunchReportCollie({
    required this.workerType,
    required this.collieId,
    required this.collieName,
    required this.collieMobile,
    required this.buckleNumber,
    this.collieImage,
    required this.stationId,
    required this.stationName,
    required this.stationCode,
    required this.totalSessions,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalCompleted,
    required this.totalRejected,
    required this.totalEarnings,
    required this.isCurrentlyActive,
    required this.sessions,
  });

  factory PunchReportCollie.fromJson(Map<String, dynamic> json) {
    return PunchReportCollie(
      workerType: json['workerType'] ?? 'collie',
      collieId: json['workerId'] ?? '',
      collieName: json['workerName'] ?? 'Unknown',
      collieMobile: json['workerMobile'] ?? '',
      buckleNumber: json['buckleNumber'] ?? '---',
      collieImage: json['workerImage'],
      stationId: json['stationId'] ?? '',
      stationName: json['stationName'] ?? '',
      stationCode: json['stationCode'] ?? '',
      totalSessions: int.tryParse(json['totalSessions'].toString()) ?? 0,
      totalHours: double.tryParse(json['totalHours'].toString()) ?? 0.0,
      totalMinutes: int.tryParse(json['totalMinutes'].toString()) ?? 0,
      totalCompleted: int.tryParse(json['totalCompleted'].toString()) ?? 0,
      totalRejected: int.tryParse(json['totalRejected'].toString()) ?? 0,
      totalEarnings: int.tryParse(json['totalEarnings'].toString()) ?? 0,
      isCurrentlyActive: json['isCurrentlyActive'] ?? false,
      sessions: (json['sessions'] as List?)?.map((e) => PunchSession.fromJson(e)).toList() ?? [],
    );
  }
}

class PunchSession {
  final String sessionId;
  final String? punchIn;
  final String? punchOut;
  final String date;
  final String dayOfWeek;
  final int durationMinutes;
  final String durationFormatted;
  final bool isActive;
  final String approvalStatus;
  final bool faceVerified;
  final double similarityScore;
  final int completedJobs;
  final int rejectedJobs;
  final int earnings;

  PunchSession({
    required this.sessionId,
    this.punchIn,
    this.punchOut,
    required this.date,
    required this.dayOfWeek,
    required this.durationMinutes,
    required this.durationFormatted,
    required this.isActive,
    required this.approvalStatus,
    required this.faceVerified,
    required this.similarityScore,
    required this.completedJobs,
    required this.rejectedJobs,
    required this.earnings,
  });

  factory PunchSession.fromJson(Map<String, dynamic> json) {
    return PunchSession(
      sessionId: json['sessionId'] ?? '',
      punchIn: json['punchIn'],
      punchOut: json['punchOut'],
      date: json['date'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      durationMinutes: int.tryParse(json['durationMinutes'].toString()) ?? 0,
      durationFormatted: json['durationFormatted'] ?? '',
      isActive: json['isActive'] ?? false,
      approvalStatus: json['approvalStatus'] ?? 'pending',
      faceVerified: json['faceVerified'] ?? false,
      similarityScore: double.tryParse(json['similarityScore'].toString()) ?? 0.0,
      completedJobs: int.tryParse(json['completedJobs'].toString()) ?? 0,
      rejectedJobs: int.tryParse(json['rejectedJobs'].toString()) ?? 0,
      earnings: int.tryParse(json['earnings'].toString()) ?? 0,
    );
  }
}
