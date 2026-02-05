class Attendance {
  final int? id;
  final String date; // Format: DD.MM.YYYY
  final String session; // "FN" or "AN"
  final String regNo;
  final String status; // "P", "A", "L"

  Attendance({
    this.id,
    required this.date,
    required this.session,
    required this.regNo,
    required this.status,
  });

  // Convert Attendance to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'session': session,
      'regNo': regNo,
      'status': status,
    };
  }

  // Create Attendance from Map (database query result)
  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      date: map['date'],
      session: map['session'],
      regNo: map['regNo'],
      status: map['status'],
    );
  }

  // Create a copy with updated fields
  Attendance copyWith({
    int? id,
    String? date,
    String? session,
    String? regNo,
    String? status,
  }) {
    return Attendance(
      id: id ?? this.id,
      date: date ?? this.date,
      session: session ?? this.session,
      regNo: regNo ?? this.regNo,
      status: status ?? this.status,
    );
  }
}
