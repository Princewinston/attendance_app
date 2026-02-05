import '../models/student.dart';
import '../models/attendance.dart';

class InMemoryStorage {
  static final InMemoryStorage instance = InMemoryStorage._init();
  
  final Map<String, Student> _students = {};
  final List<Attendance> _attendanceRecords = [];
  int _attendanceIdCounter = 1;

  InMemoryStorage._init() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // II M Tech CSE Class List (Updated)
    // Using simple numbers (1-58) as RegNo based on user request
    final sampleStudents = [
      Student(regNo: '1', name: 'AADITHYA C S'),
      Student(regNo: '2', name: 'ANUCHAND S'),
      Student(regNo: '3', name: 'AZHAGHU MAATHAVAN M'),
      Student(regNo: '4', name: 'BHAVISH V'),
      Student(regNo: '5', name: 'BHUVANESWARI M'),
      Student(regNo: '6', name: 'DANUSRI A'),
      Student(regNo: '7', name: 'DEEPAK S'),
      Student(regNo: '8', name: 'DHANNISHAA P G'),
      Student(regNo: '9', name: 'DHANWANTHBALA S'),
      Student(regNo: '10', name: 'DUVARAKESH M'),
      Student(regNo: '11', name: 'GEORGE ALWIN JOSE'),
      Student(regNo: '12', name: 'GOWTHAM B'),
      Student(regNo: '13', name: 'GOWUTHAMAN S'),
      Student(regNo: '14', name: 'GURUPRASAAD S V'),
      Student(regNo: '15', name: 'HAREESHVAR V'),
      Student(regNo: '16', name: 'HARINI S'),
      Student(regNo: '17', name: 'JAGANNATHAN K'),
      Student(regNo: '18', name: 'JASHWIN SHARVESH S'),
      Student(regNo: '19', name: 'JEYA SURIYA K'),
      Student(regNo: '20', name: 'KAAVANYA D'),
      Student(regNo: '21', name: 'KAAVIYA SHREE M'),
      Student(regNo: '22', name: 'KALAIARASHI S B'),
      Student(regNo: '23', name: 'KARAN ATHITHYA P'),
      Student(regNo: '24', name: 'KARTHI V'),
      Student(regNo: '25', name: 'MANUBHARATHI V C'),
      Student(regNo: '26', name: 'MOHAMED AADIL G F'),
      Student(regNo: '27', name: 'MOHAMED ANEESH M'),
      Student(regNo: '28', name: 'MOHAMED FAYAZ S'),
      Student(regNo: '29', name: 'MOHAMED NIBRAS HAKEEM W'),
      Student(regNo: '30', name: 'NAWAZ F'),
      Student(regNo: '31', name: 'NIDHARSAN R'),
      Student(regNo: '32', name: 'NIHAAL S'),
      Student(regNo: '33', name: 'NITHIYA D'),
      Student(regNo: '34', name: 'PRINCE WINSTON P'),
      Student(regNo: '35', name: 'PRIYADARSHINI M'),
      Student(regNo: '36', name: 'PRIYANGA R'),
      Student(regNo: '37', name: 'PUNITH SIVA S'),
      Student(regNo: '38', name: 'RAHUL M'),
      Student(regNo: '39', name: 'RAMYA B'),
      Student(regNo: '40', name: 'SAADHANA K'),
      Student(regNo: '41', name: 'SHAMYUKTHA P R'),
      Student(regNo: '42', name: 'SHANMUGA PRIYA S'),
      Student(regNo: '43', name: 'SISMITHA A'),
      Student(regNo: '44', name: 'SOWMYA PARAMESHWARI J'),
      Student(regNo: '45', name: 'SREEHARSHAN R'),
      Student(regNo: '46', name: 'SURYA D N'),
      Student(regNo: '47', name: 'THARANYA G'),
      Student(regNo: '48', name: 'TINO DELPHIN C'),
      Student(regNo: '49', name: 'VAISHNAVI D N'),
      Student(regNo: '50', name: 'VASANTHAKUMAR P K'),
      Student(regNo: '51', name: 'VIGNESH M'),
      Student(regNo: '52', name: 'VISHAL S'),
      Student(regNo: '53', name: 'VISHNU ANAND A'),
      Student(regNo: '54', name: 'YAMUNADEVI P'),
      Student(regNo: '55', name: 'ISHWARYA N'),
      Student(regNo: '56', name: 'POOVIZHI P'),
      Student(regNo: '57', name: 'SHARVESH B'),
      Student(regNo: '58', name: 'MOHAMMED HAARITH S'),
    ];

    for (var student in sampleStudents) {
      _students[student.regNo] = student;
    }
  }

  // ===== STUDENT OPERATIONS =====

  Future<List<Student>> getAllStudents() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    final students = _students.values.toList();
    // Sort by integer value of RegNo
    students.sort((a, b) {
      try {
        return int.parse(a.regNo).compareTo(int.parse(b.regNo));
      } catch (e) {
        return a.regNo.compareTo(b.regNo);
      }
    });
    return students;
  }

  Future<Student?> getStudent(String regNo) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _students[regNo];
  }

  Future<int> insertStudent(Student student) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _students[student.regNo] = student;
    return 1;
  }

  Future<int> updateStudent(Student student) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _students[student.regNo] = student;
    return 1;
  }

  Future<int> deleteStudent(String regNo) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _students.remove(regNo);
    return 1;
  }

  // ===== ATTENDANCE OPERATIONS =====

  Future<int> insertAttendance(Attendance attendance) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final newAttendance = attendance.copyWith(id: _attendanceIdCounter++);
    _attendanceRecords.add(newAttendance);
    return newAttendance.id!;
  }

  Future<Attendance?> getAttendance(String date, String session, String regNo) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _attendanceRecords.firstWhere(
        (att) => att.date == date && att.session == session && att.regNo == regNo,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Attendance>> getAttendanceByDateAndSession(String date, String session) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final filtered = _attendanceRecords
        .where((att) => att.date == date && att.session == session)
        .toList();
    filtered.sort((a, b) {
       try {
        return int.parse(a.regNo).compareTo(int.parse(b.regNo));
      } catch (e) {
        return a.regNo.compareTo(b.regNo);
      }
    });
    return filtered;
  }

  Future<int> updateAttendance(Attendance attendance) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _attendanceRecords.indexWhere((att) => att.id == attendance.id);
    if (index != -1) {
      _attendanceRecords[index] = attendance;
      return 1;
    }
    return 0;
  }

  Future<int> upsertAttendance(Attendance attendance) async {
    final existing = await getAttendance(
      attendance.date,
      attendance.session,
      attendance.regNo,
    );

    if (existing != null) {
      return await updateAttendance(attendance.copyWith(id: existing.id));
    } else {
      return await insertAttendance(attendance);
    }
  }

  Future<int> deleteAttendance(int id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _attendanceRecords.removeWhere((att) => att.id == id);
    return 1;
  }

  Future<void> close() async {
    // Nothing to close for in-memory storage
  }
}
