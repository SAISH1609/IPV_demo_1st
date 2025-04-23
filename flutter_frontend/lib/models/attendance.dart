class Attendance {
  final int id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final double confidence;
  final String? imagePath;

  Attendance({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.confidence,
    this.imagePath,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      status: json['status'],
      confidence: json['confidence'].toDouble(),
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'status': status,
      'confidence': confidence,
      'image_path': imagePath,
    };
  }
} 