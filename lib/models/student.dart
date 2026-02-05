class Student {
  final String regNo;
  final String name;

  Student({
    required this.regNo,
    required this.name,
  });

  // Convert Student to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'regNo': regNo,
      'name': name,
    };
  }

  // Create Student from Map (database query result)
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      regNo: map['regNo'],
      name: map['name'],
    );
  }
}
