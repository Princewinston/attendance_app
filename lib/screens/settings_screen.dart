import 'package:flutter/material.dart';
import '../db/settings_storage.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsStorage _settings = SettingsStorage.instance;
  final TextEditingController _classNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _classNameController.text = _settings.className;
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Class Name
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Class Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _classNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter class name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _settings.setClassName(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Font Size
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Font Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<double>(
                    segments: const [
                      ButtonSegment(
                        value: 0.8,
                        label: Text('Small'),
                      ),
                      ButtonSegment(
                        value: 1.0,
                        label: Text('Medium'),
                      ),
                      ButtonSegment(
                        value: 1.2,
                        label: Text('Large'),
                      ),
                    ],
                    selected: {_settings.fontSize},
                    onSelectionChanged: (Set<double> newSelection) {
                      setState(() {
                        _settings.setFontSize(newSelection.first);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sorting
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort Students By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'regNo',
                        label: Text('Reg No'),
                        icon: Icon(Icons.numbers),
                      ),
                      ButtonSegment(
                        value: 'name',
                        label: Text('Name'),
                        icon: Icon(Icons.sort_by_alpha),
                      ),
                    ],
                    selected: {_settings.sortBy},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _settings.setSortBy(newSelection.first);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Dark Mode
          Card(
            child: SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Eye-friendly for evening use'),
              value: _settings.isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _settings.setDarkMode(value);
                  widget.onThemeChanged(value);
                });
              },
              secondary: Icon(
                _settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Reset Button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _settings.reset();
                _classNameController.text = _settings.className;
                widget.onThemeChanged(false);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to Defaults'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
