import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'attendance_screen.dart';
import '../db/database_helper.dart';
import '../models/student.dart';

class ImportAttendanceScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const ImportAttendanceScreen({super.key, required this.onThemeChanged});

  @override
  State<ImportAttendanceScreen> createState() => _ImportAttendanceScreenState();
}

class _ImportAttendanceScreenState extends State<ImportAttendanceScreen> {
  final TextEditingController _textController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Student> _allStudents = [];
  
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    _allStudents = await _dbHelper.getAllStudents();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _parseAttendanceText(String text) {
    try {
      final lines = text.trim().split('\n');
      if (lines.isEmpty) return null;

      // Parse first line: date and session
      final firstLine = lines[0].trim();
      final parts = firstLine.split(RegExp(r'\s+'));
      if (parts.length < 2) return null;

      String date = parts[0];
      String session = parts[1];

      // Find "Absentees" section
      int absenteesIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().contains('absentee')) {
          absenteesIndex = i;
          break;
        }
      }

      if (absenteesIndex == -1) return null;

      List<String> absenteeRegNos = [];

      // Parse absentees (starting from line after "Absentees:")
      for (int i = absenteesIndex + 1; i < lines.length; i++) {
        String line = lines[i].trim();
        
        // Stop if we hit "Late Comers" or empty line (end of section)
        if (line.toLowerCase().contains('late comer') || 
            line.isEmpty && absenteeRegNos.isNotEmpty) {
          break;
        }
        
        if (line.isEmpty || line.toLowerCase() == 'none') continue;

        // Mode A: Comma-separated numbers (e.g., "1, 2, 5, 6" or "8, 17, 24, 30.")
        if (line.contains(',')) {
          final numbers = line.split(',').map((n) => n.trim()).where((n) => n.isNotEmpty);
          for (var num in numbers) {
            // Extract only digits from the string (removes periods, spaces, etc.)
            final digitsOnly = num.replaceAll(RegExp(r'[^\d]'), '');
            if (digitsOnly.isNotEmpty) {
              absenteeRegNos.add(_convertToRegNo(digitsOnly));
            }
          }
        }
        // Mode B: Numbered list (e.g., "1. Aathiya" or just "1")
        else {
          // Extract number from start of line
          final match = RegExp(r'^(\d+)').firstMatch(line);
          if (match != null) {
            String num = match.group(1)!;
            absenteeRegNos.add(_convertToRegNo(num));
          }
        }
      }

      return {
        'date': date,
        'session': session,
        'absenteeRegNos': absenteeRegNos,
      };
    } catch (e) {
      print('Error parsing text: $e');
      return null;
    }
  }

  String _convertToRegNo(String shortNum) {
    // Convert "01" -> "1", "34" -> "34"
    int num = int.parse(shortNum);
    return num.toString();
  }

  void _processImport() async {
    final text = _textController.text;
    final parsed = _parseAttendanceText(text);

    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid format! Please check the pasted text.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Debug: Print parsed data
    print('Parsed Date: ${parsed['date']}');
    print('Parsed Session: ${parsed['session']}');
    print('Parsed Absentees: ${parsed['absenteeRegNos']}');

    // Navigate to attendance screen with parsed data
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceScreen(
            onThemeChanged: widget.onThemeChanged,
            importedDate: parsed['date'],
            importedSession: parsed['session'],
            importedAbsentees: List<String>.from(parsed['absenteeRegNos']),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Attendance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste Attendance Text',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paste the attendance list you received from another CR',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Example format
              Card(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF424242) 
                    : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info, 
                            size: 18, 
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.lightBlueAccent 
                                : Colors.blue.shade700
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Example Format:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mode A (Numbers):\n05.02.2025    FN\nAbsentees:\n1, 2, 5, 6, 12, 35\n\nMode B (List):\n05.02.2025    FN\nAbsentees:\n1. Aadithya\n2. Anuchand',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey.shade300 
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Text input
              TextField(
                controller: _textController,
                maxLines: null,
                minLines: 15, // Make it tall effectively like Expanded but scrollable
                decoration: InputDecoration(
                  hintText: 'Paste attendance text here...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey.shade500 
                        : Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF303030) 
                      : Colors.white,
                ),
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
                scrollPadding: const EdgeInsets.only(bottom: 100), // Helps with keyboard visibility
              ),
              const SizedBox(height: 16),
              
              // Import button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _processImport,
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Import & Continue Editing',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              // Add extra space at bottom for scrolling
              const SizedBox(height: 300), 
            ],
          ),
        ),
      ),
    );
  }
}
