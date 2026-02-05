import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'import_attendance_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../db/settings_storage.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SettingsStorage _settings = SettingsStorage.instance;

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark 
        ? const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Light Blue Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('CR Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Direct Dark Mode Toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              final newMode = !isDark;
              widget.onThemeChanged(newMode);
            },
          ),
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                const SizedBox(height: 10),
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blue.shade900,
                  ),
                ),
                Text(
                  _settings.className, // "II M Tech CSE"
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Dashboard List
                Expanded(
                  child: ListView(
                    children: [
                      // Take Attendance Card
                      _buildDashboardCard(
                        context,
                        title: 'Take Attendance',
                        subtitle: 'Mark P/A/L for today',
                        icon: Icons.edit_note,
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceScreen(onThemeChanged: widget.onThemeChanged),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Import Card
                      _buildDashboardCard(
                        context,
                        title: 'Import List',
                        subtitle: 'Paste attendance from text',
                        icon: Icons.file_download,
                        color: Colors.green,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImportAttendanceScreen(onThemeChanged: widget.onThemeChanged),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // History Card
                      _buildDashboardCard(
                        context,
                        title: 'History (7 Days)',
                        subtitle: 'View calendar & records',
                        icon: Icons.history,
                        color: Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(onThemeChanged: widget.onThemeChanged),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 100, // Fixed height for consistency
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF333333) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[300],
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
