import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/attendance.dart';

class HistoryScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HistoryScreen({super.key, required this.onThemeChanged});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Cache of days that have attendance data
  Set<String> _daysWithData = {};
  
  // Data for the selected day
  bool _isLoadingDay = false;
  List<Attendance> _selectedDayAttendance = [];
  Map<String, List<Attendance>> _sessionsForDay = {}; // FN, AN -> List

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadHistoryDates();
    _loadDayData(_focusedDay);
  }

  Future<void> _loadHistoryDates() async {
    final historyDates = await _dbHelper.getHistoryDates();
    setState(() {
      _daysWithData = historyDates.map((e) => e['date'] as String).toSet();
    });
  }

  Future<void> _loadDayData(DateTime date) async {
    setState(() {
      _isLoadingDay = true;
      _sessionsForDay = {};
    });

    final dateStr = DateFormat('dd.MM.yyyy').format(date);
    
    // Check both FN and AN
    final fnData = await _dbHelper.getAttendanceByDateAndSession(dateStr, 'FN');
    final anData = await _dbHelper.getAttendanceByDateAndSession(dateStr, 'AN');

    setState(() {
      if (fnData.isNotEmpty) _sessionsForDay['FN'] = fnData;
      if (anData.isNotEmpty) _sessionsForDay['AN'] = anData;
      
      _selectedDayAttendance = [...fnData, ...anData];
      _isLoadingDay = false;
    });
  }
  
  Future<void> _deleteSession(String session) async {
    if (_selectedDay == null) return;
    
    final dateStr = DateFormat('dd.MM.yyyy').format(_selectedDay!);
    
    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attendance?'),
        content: Text('Are you sure you want to delete attendance for $dateStr ($session)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Get IDs to delete
      final records = _sessionsForDay[session] ?? [];
      for (var record in records) {
        if (record.id != null) {
          await _dbHelper.deleteAttendance(record.id!);
        }
      }
      
      // Refresh
      await _loadHistoryDates();
      await _loadDayData(_selectedDay!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History (Past 7 Days)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 30)), // Limit range slightly
            lastDay: DateTime.now().add(const Duration(days: 1)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadDayData(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            // Marker for days with data
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final dateStr = DateFormat('dd.MM.yyyy').format(date);
                if (_daysWithData.contains(dateStr)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      width: 6.0,
                      height: 6.0,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoadingDay 
                ? const Center(child: CircularProgressIndicator())
                : _sessionsForDay.isEmpty
                    ? const Center(child: Text('No attendance recorded for this date.'))
                    : ListView(
                        children: _sessionsForDay.entries.map((entry) {
                          final session = entry.key; // FN or AN
                          final records = entry.value;
                          final absentees = records.where((a) => a.status == 'A').toList();
                          final lateComers = records.where((a) => a.status == 'L').toList();
                          final presentCount = records.length - absentees.length; // Approximate if not tracking L as absent type
                          
                          // Convert 'L' status logic if needed, usually 'L' is present but late?
                          // Let's assume Present = Total - Absent. Only 'A' is strictly absent.
                          
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ExpansionTile(
                              title: Text('$session Session'),
                              subtitle: Text(
                                'Present: $presentCount / ${records.length}  |  Absent: ${absentees.length}',
                                style: TextStyle(
                                  color: absentees.isEmpty ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () => _deleteSession(session),
                              ),
                              children: [
                                if (absentees.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Absentees:',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  ...absentees.map((a) {
                                    final studentName = _getStudentName(a.regNo, records); // Need student mapping
                                    // Actually records don't have name... Attendance model has regNo.
                                    // We need to fetch student name. But for now show RegNo.
                                    // Better: We stored names in DB but Attendance object only has regNo probably?
                                    // Let's check Attendance model.
                                    return ListTile(
                                      title: Text('Reg No: ${a.regNo}'),
                                      dense: true,
                                      leading: const Icon(Icons.cancel, color: Colors.red, size: 16),
                                    );
                                  }),
                                ],
                                if (lateComers.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Late Comers:',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                  ...lateComers.map((a) {
                                    return ListTile(
                                      title: Text('Reg No: ${a.regNo}'),
                                      dense: true,
                                      leading: const Icon(Icons.access_time, color: Colors.orange, size: 16),
                                    );
                                  }),
                                ],
                                if (absentees.isEmpty && lateComers.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('All Present! 🎉', style: TextStyle(color: Colors.green)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
  
  // Helper to allow showing names if we had them. 
  // Since we only have attendance records, we might want to fetch names or just show RegNo. 
  // "just one week" usually implies quick check. RegNo is fine for now or I can fetch students map.
  String _getStudentName(String regNo, List<Attendance> records) {
    return regNo;
  }
}
