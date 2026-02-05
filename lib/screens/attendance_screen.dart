import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/database_helper.dart';
import '../db/settings_storage.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import 'settings_screen.dart';

class AttendanceScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final String? importedDate;
  final String? importedSession;
  final List<String>? importedAbsentees;
  
  const AttendanceScreen({
    super.key, 
    required this.onThemeChanged,
    this.importedDate,
    this.importedSession,
    this.importedAbsentees,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SettingsStorage _settings = SettingsStorage.instance;
  List<Student> _students = [];
  List<Student> _filteredStudents = []; // For search/filter results
  Map<String, String> _attendanceStatus = {}; // regNo -> status
  String _selectedSession = 'FN';
  String _currentDate = '';
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All'; // All, Present, Absent, Late

  @override
  void initState() {
    super.initState();
    
    // Handle imported data
    if (widget.importedDate != null && widget.importedSession != null) {
      _currentDate = widget.importedDate!;
      _selectedSession = widget.importedSession!;
    }
    
    _searchController.addListener(_onSearchChanged);
    _initializeScreen();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredStudents = _students.where((student) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery) ||
          student.regNo.toLowerCase().contains(_searchQuery);

      // Status filter
      final status = _attendanceStatus[student.regNo] ?? 'P';
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Present' && status == 'P') ||
          (_statusFilter == 'Absent' && status == 'A') ||
          (_statusFilter == 'Late' && status == 'L');

      return matchesSearch && matchesStatus;
    }).toList();
    
    // Apply sorting
    _applySorting();
  }
  
  void _applySorting() {
    if (_settings.sortBy == 'name') {
      _filteredStudents.sort((a, b) => a.name.compareTo(b.name));
    } else if (_settings.sortBy == 'regNo') {
      _filteredStudents.sort((a, b) {
        try {
          return int.parse(a.regNo).compareTo(int.parse(b.regNo));
        } catch (e) {
          return a.regNo.compareTo(b.regNo);
        }
      });
    }
  }



  Future<void> _initializeScreen() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current date in DD.MM.YYYY format (only if not importing)
      if (widget.importedDate == null) {
        final now = DateTime.now();
        _currentDate = DateFormat('dd.MM.yyyy').format(now);
      }
      // If importing, date is already set in initState

      // Load students
      _students = await _dbHelper.getAllStudents();

      // Debug print
      print('Loaded ${_students.length} students');
      print('Current date: $_currentDate, Session: $_selectedSession');
      if (widget.importedAbsentees != null) {
        print('Imported absentees: ${widget.importedAbsentees}');
      }

      // Load existing attendance or default to Present
      await _loadAttendance();
      
      // Apply initial filters
      _applyFilters();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show import confirmation
        if (widget.importedAbsentees != null && widget.importedAbsentees!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Imported ${widget.importedAbsentees!.length} absentees successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error initializing screen: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadAttendance() async {
    // If we're importing, don't load from database - let imported data apply first
    if (widget.importedAbsentees != null) {
      print('🔵 IMPORTING MODE: Applying imported absentees');
      print('🔵 Imported reg numbers: ${widget.importedAbsentees}');
      
      // Initialize all to Present
      _attendanceStatus = {};
      for (var student in _students) {
        _attendanceStatus[student.regNo] = 'P';
      }
      
      // IMMEDIATELY set imported students to Absent
      for (String regNo in widget.importedAbsentees!) {
        print('🔵 Setting $regNo to Absent');
        _attendanceStatus[regNo] = 'A';
      }
      
      print('🔵 Final status map: $_attendanceStatus');
      return;
    }
    
    final existingAttendance = await _dbHelper.getAttendanceByDateAndSession(
      _currentDate,
      _selectedSession,
    );

    // Create a map of existing attendance
    Map<String, String> attendanceMap = {};
    for (var att in existingAttendance) {
      attendanceMap[att.regNo] = att.status;
    }

    // Initialize status for all students (default to Present if not found)
    _attendanceStatus = {};
    for (var student in _students) {
      _attendanceStatus[student.regNo] = attendanceMap[student.regNo] ?? 'P';
    }
  }

  void _toggleStatus(String regNo) {
    setState(() {
      final currentStatus = _attendanceStatus[regNo] ?? 'P';
      switch (currentStatus) {
        case 'P':
          _attendanceStatus[regNo] = 'A';
          break;
        case 'A':
          _attendanceStatus[regNo] = 'L';
          break;
        case 'L':
          _attendanceStatus[regNo] = 'P';
          break;
      }
      _applyFilters(); // Re-apply filters after status change
    });
  }



  Future<void> _saveAttendance() async {
    setState(() {
      _isSaving = true;
    });

    try {
      for (var student in _students) {
        final attendance = Attendance(
          date: _currentDate,
          session: _selectedSession,
          regNo: student.regNo,
          status: _attendanceStatus[student.regNo] ?? 'P',
        );
        await _dbHelper.upsertAttendance(attendance);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareViaWhatsApp({
    required bool modeA,
    bool includeLateComers = false,
  }) async {
    // Generate the same text as copy
    List<Student> absentees = [];
    List<Student> lateComers = [];

    for (var student in _students) {
      final status = _attendanceStatus[student.regNo] ?? 'P';
      if (status == 'A') {
        absentees.add(student);
      } else if (status == 'L') {
        lateComers.add(student);
      }
    }

    String text = '$_currentDate    $_selectedSession\n\n';

    if (absentees.isEmpty) {
      text += 'Absentees:\nNone';
    } else {
      text += 'Absentees:\n';
      
      if (modeA) {
        List<String> numbers = [];
        for (var student in absentees) {
          String regNo = student.regNo;
          String number = regNo;
          numbers.add(number);
        }
        text += numbers.join(', ');
      } else {
        for (var student in absentees) {
          String regNo = student.regNo;
          String number = regNo;
          text += '$number. ${student.name}\n';
        }
      }
    }

    if (includeLateComers && lateComers.isNotEmpty) {
      text += '\n\nLate Comers:\n';
      
      if (modeA) {
        List<String> numbers = [];
        for (var student in lateComers) {
          String regNo = student.regNo;
          String number = regNo.substring(regNo.length - 2);
          number = int.parse(number).toString();
          numbers.add(number);
        }
        text += numbers.join(', ');
      } else {
        for (var student in lateComers) {
          String regNo = student.regNo;
          String number = regNo;
          text += '$number. ${student.name}\n';
        }
      }
    }

    // URL encode the text
    final encodedText = Uri.encodeComponent(text);
    final whatsappUrl = 'https://wa.me/?text=$encodedText';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to clipboard if WhatsApp not available
        await Clipboard.setData(ClipboardData(text: text));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp not available. Copied to clipboard instead!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Fallback to clipboard on error
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening WhatsApp. Copied to clipboard!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showCopyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool includeLateComers = false;
        return StatefulBuilder(
          builder: (context, setState) {
             return AlertDialog(
              title: const Text('Share via WhatsApp'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat, color: Colors.green),
                    title: const Text('WhatsApp - Mode A'),
                    subtitle: const Text('Reg No. only'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _shareViaWhatsApp(
                        modeA: true,
                        includeLateComers: false,
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.chat, color: Colors.green),
                    title: const Text('WhatsApp - Mode B'),
                    subtitle: const Text('Reg No. + Names'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _shareViaWhatsApp(
                        modeA: false,
                        includeLateComers: false,
                      );
                    },
                  ),
                ],
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  },
);
  }

  Future<void> _copyToClipboard({
    required bool modeA,
    bool includeLateComers = false,
  }) async {
    // Get absentees and late comers
    List<Student> absentees = [];
    List<Student> lateComers = [];

    for (var student in _students) {
      final status = _attendanceStatus[student.regNo] ?? 'P';
      if (status == 'A') {
        absentees.add(student);
      } else if (status == 'L') {
        lateComers.add(student);
      }
    }

    // Generate formatted text based on mode
    String text = '$_currentDate    $_selectedSession\n\n';

    if (absentees.isEmpty) {
      text += 'Absentees:\nNone';
    } else {
      text += 'Absentees:\n';

      if (modeA) {
        // Mode A: Numbers only (comma-separated)
        List<String> numbers = [];
        for (var student in absentees) {
          // Extract just the number part from regNo (e.g., "2401034" -> "34")
          String regNo = student.regNo;
          String number = regNo;
          numbers.add(number);
        }
        text += numbers.join(', ');
      } else {
        // Mode B: Numbers + Names (numbered list)
        for (var student in absentees) {
          // Extract just the number part from regNo
          String regNo = student.regNo;
          String number = regNo;
          text += '$number. ${student.name}\n';
        }
      }
    }

    // Add late comers section if enabled
    if (includeLateComers && lateComers.isNotEmpty) {
      text += '\n\nLate Comers:\n';
      
      if (modeA) {
        // Mode A: Numbers only (comma-separated)
        List<String> numbers = [];
        for (var student in lateComers) {
          String regNo = student.regNo;
          String number = regNo;
          numbers.add(number);
        }
        text += numbers.join(', ');
      } else {
        // Mode B: Numbers + Names (numbered list)
        for (var student in lateComers) {
          String regNo = student.regNo;
          String number = regNo;
          text += '$number. ${student.name}\n';
        }
      }
    }

    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            modeA ? 'Copied (Numbers Only)!' : 'Copied (Numbers + Names)!',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _changeSession(String session) async {
    setState(() {
      _selectedSession = session;
      _isLoading = true;
    });
    await _loadAttendance();
    setState(() {
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'P':
        return Colors.green;
      case 'A':
        return Colors.red;
      case 'L':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'P':
        return 'Present';
      case 'A':
        return 'Absent';
      case 'L':
        return 'Late';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CR Attendance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
              setState(() {
                _applyFilters(); // Re-apply sorting after settings change
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with date and session selector
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E) // Dark background for dark mode
                        : Colors.blue.shade50,   // Light blue for light mode
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentDate,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('FN (Forenoon)'),
                            selected: _selectedSession == 'FN',
                            onSelected: (selected) {
                              if (selected) _changeSession('FN');
                            },
                          ),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('AN (Afternoon)'),
                            selected: _selectedSession == 'AN',
                            onSelected: (selected) {
                              if (selected) _changeSession('AN');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or reg number...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _statusFilter == 'All',
                        onSelected: (selected) {
                          setState(() {
                            _statusFilter = 'All';
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Present'),
                        selected: _statusFilter == 'Present',
                        onSelected: (selected) {
                          setState(() {
                            _statusFilter = selected ? 'Present' : 'All';
                            _applyFilters();
                          });
                        },
                        backgroundColor: Colors.green.shade50,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Absent'),
                        selected: _statusFilter == 'Absent',
                        onSelected: (selected) {
                          setState(() {
                            _statusFilter = selected ? 'Absent' : 'All';
                            _applyFilters();
                          });
                        },
                        backgroundColor: Colors.red.shade50,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Late'),
                        selected: _statusFilter == 'Late',
                        onSelected: (selected) {
                          setState(() {
                            _statusFilter = selected ? 'Late' : 'All';
                            _applyFilters();
                          });
                        },
                        backgroundColor: Colors.orange.shade50,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                // Student list
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No students found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                      final status = _attendanceStatus[student.regNo] ?? 'P';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(status),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('Reg No: ${student.regNo}'),
                          trailing: ElevatedButton(
                            onPressed: () => _toggleStatus(student.regNo),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getStatusColor(status),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(_getStatusText(status)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bottom action buttons
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveAttendance,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showCopyDialog,
                          icon: const Icon(Icons.copy),
                          label: const Text('COPY'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
