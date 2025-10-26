import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Access Logs Screen - Entry/Exit Records
class AccessLogsScreen extends StatefulWidget {
  const AccessLogsScreen({super.key});

  @override
  State<AccessLogsScreen> createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  String _selectedFilter = 'All';

  // Demo access logs data
  final List<Map<String, dynamic>> _accessLogs = [
    {
      'id': '1',
      'personName': 'Ahmet Yılmaz',
      'personId': 'EMP-001',
      'department': 'Engineering',
      'action': 'Entry',
      'location': 'Main Entrance',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
    },
    {
      'id': '2',
      'personName': 'Ayşe Kaya',
      'personId': 'EMP-042',
      'department': 'HR',
      'action': 'Exit',
      'location': 'Office Entrance',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 32)),
    },
    {
      'id': '3',
      'personName': 'Mehmet Demir',
      'personId': 'EMP-015',
      'department': 'Operations',
      'action': 'Entry',
      'location': 'Warehouse Door 1',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
    },
    {
      'id': '4',
      'personName': 'Fatma Şahin',
      'personId': 'EMP-028',
      'department': 'Finance',
      'action': 'Exit',
      'location': 'Main Entrance',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
    },
    {
      'id': '5',
      'personName': 'Ali Yıldız',
      'personId': 'EMP-033',
      'department': 'Engineering',
      'action': 'Entry',
      'location': 'Warehouse Door 2',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
    },
    {
      'id': '6',
      'personName': 'Zeynep Aksoy',
      'personId': 'EMP-019',
      'department': 'Marketing',
      'action': 'Entry',
      'location': 'Office Entrance',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 4, minutes: 10)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _selectedFilter == 'All'
        ? _accessLogs
        : _accessLogs.where((log) => log['action'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Access Logs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting access logs...')),
              );
            },
            tooltip: 'Export Logs',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Entry'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Exit'),
                ],
              ),
            ),

            // Stats summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Today',
                      '${_accessLogs.length}',
                      Icons.list_alt,
                      const Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Entries',
                      '${_accessLogs.where((l) => l['action'] == 'Entry').length}',
                      Icons.login,
                      const Color(0xFF00FFC6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Exits',
                      '${_accessLogs.where((l) => l['action'] == 'Exit').length}',
                      Icons.logout,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Access logs list
            Expanded(
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Text(
                        'No $_selectedFilter logs',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        return _buildLogCard(log);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: const Color(0xFF1F2937),
      selectedColor: const Color(0xFF007AFF),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final isEntry = log['action'] == 'Entry';
    final timestamp = log['timestamp'] as DateTime;
    final timeStr = DateFormat('HH:mm').format(timestamp);
    final dateStr = DateFormat('dd MMM yyyy').format(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isEntry ? const Color(0xFF00FFC6) : Colors.redAccent)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Action icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isEntry ? const Color(0xFF00FFC6) : Colors.redAccent)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEntry ? Icons.login : Icons.logout,
              color: isEntry ? const Color(0xFF00FFC6) : Colors.redAccent,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Person info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['personName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log['personId'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.work,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log['department'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log['location'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isEntry ? const Color(0xFF00FFC6) : Colors.redAccent)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  log['action'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isEntry ? const Color(0xFF00FFC6) : Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
