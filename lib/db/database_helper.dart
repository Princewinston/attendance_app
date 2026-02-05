import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/attendance.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
      onOpen: _onOpen,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Students table
    await db.execute('''
CREATE TABLE students ( 
  regNo $textType PRIMARY KEY,
  name $textType
)
''');

    // Attendance table
    await db.execute('''
CREATE TABLE attendance ( 
  id $idType,
  date $textType,
  session $textType,
  regNo $textType,
  status $textType,
  FOREIGN KEY (regNo) REFERENCES students (regNo)
)
''');
  }

  Future<void> _onOpen(Database db) async {
    // Auto-cleanup: Delete records older than 7 days
    await _cleanupOldRecords(db);
    
    // Check if students exist, if not initialize
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM students'));
    if (count == 0) {
      await _initializeDefaultStudents(db);
    }
  }

  Future<void> _initializeDefaultStudents(Database db) async {
    print('📥 Initializing default student list...');
    final students = [
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

    final batch = db.batch();
    for (var student in students) {
      batch.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    print('✅ Initialized ${students.length} students');
  }

  Future<void> _cleanupOldRecords(Database db) async {
    try {
      final now = DateTime.now();
      // Calculate date 7 days ago
      final cutoffDate = now.subtract(const Duration(days: 7));
      
      // We store dates as DD.MM.YYYY strings, which are hard to compare directly in SQL.
      // So we'll fetch unique dates first, parse them, and delete matching ones.
      
      final result = await db.rawQuery('SELECT DISTINCT date FROM attendance');
      
      List<String> datesToDelete = [];
      final dateFormat = DateFormat('dd.MM.yyyy');
      
      for (var row in result) {
        String dateStr = row['date'] as String;
        try {
          DateTime date = dateFormat.parse(dateStr);
          if (date.isBefore(cutoffDate)) {
            datesToDelete.add(dateStr);
          }
        } catch (e) {
          print('Error parsing date: $dateStr');
        }
      }
      
      if (datesToDelete.isNotEmpty) {
        print('🧹 Cleaning up old records: $datesToDelete');
        // Delete efficiently
        final placeholders = List.filled(datesToDelete.length, '?').join(',');
        await db.delete(
          'attendance',
          where: 'date IN ($placeholders)',
          whereArgs: datesToDelete,
        );
        print('✅ Deleted ${datesToDelete.length} old days of attendance');
      }
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  // ===== STUDENT OPERATIONS =====

  Future<int> insertStudent(Student student) async {
    final db = await instance.database;
    return await db.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Student?> getStudent(String regNo) async {
    final db = await instance.database;
    final maps = await db.query(
      'students',
      columns: ['regNo', 'name'],
      where: 'regNo = ?',
      whereArgs: [regNo],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students');
    
    final students = result.map((json) => Student.fromMap(json)).toList();
    
    // Sort numerically by ID
    students.sort((a, b) {
      try {
        return int.parse(a.regNo).compareTo(int.parse(b.regNo));
      } catch (e) {
        return a.regNo.compareTo(b.regNo);
      }
    });
    
    return students;
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return db.update(
      'students',
      student.toMap(),
      where: 'regNo = ?',
      whereArgs: [student.regNo],
    );
  }

  Future<int> deleteStudent(String regNo) async {
    final db = await instance.database;
    return await db.delete(
      'students',
      where: 'regNo = ?',
      whereArgs: [regNo],
    );
  }
  
  // Bulk insert for initialization
  Future<void> batchInsertStudents(List<Student> students) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var student in students) {
      batch.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ===== ATTENDANCE OPERATIONS =====

  Future<int> insertAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.insert('attendance', attendance.toMap());
  }
  
  // Upsert equivalent
  Future<int> upsertAttendance(Attendance attendance) async {
    final db = await instance.database;
    
    // Check if exists
    final existing = await db.query(
      'attendance',
      where: 'date = ? AND session = ? AND regNo = ?',
      whereArgs: [attendance.date, attendance.session, attendance.regNo],
    );
    
    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      // create a mutable copy of the map and remove 'id' to avoid setting PK to null
      final map = Map<String, dynamic>.from(attendance.toMap());
      map.remove('id'); 
      
      return await db.update(
        'attendance',
        map,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      return await db.insert('attendance', attendance.toMap());
    }
  }

  Future<Attendance?> getAttendance(String date, String session, String regNo) async {
    final db = await instance.database;
    final maps = await db.query(
      'attendance',
      columns: ['id', 'date', 'session', 'regNo', 'status'],
      where: 'date = ? AND session = ? AND regNo = ?',
      whereArgs: [date, session, regNo],
    );

    if (maps.isNotEmpty) {
      return Attendance.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Attendance>> getAttendanceByDateAndSession(String date, String session) async {
    final db = await instance.database;
    final result = await db.query(
      'attendance',
      where: 'date = ? AND session = ?',
      whereArgs: [date, session],
    );
    
    final list = result.map((json) => Attendance.fromMap(json)).toList();
    
    // Sort logic
    list.sort((a, b) {
      try {
        return int.parse(a.regNo).compareTo(int.parse(b.regNo));
      } catch (e) {
        return a.regNo.compareTo(b.regNo);
      }
    });
    
    return list;
  }
  
  // History: Get all unique dates with sessions
  Future<List<Map<String, dynamic>>> getHistoryDates() async {
    final db = await instance.database;
    // Get unique date, session pairs
    return await db.rawQuery('SELECT DISTINCT date, session FROM attendance ORDER BY date DESC, session DESC');
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await instance.database;
    return db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await instance.database;
    return await db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
