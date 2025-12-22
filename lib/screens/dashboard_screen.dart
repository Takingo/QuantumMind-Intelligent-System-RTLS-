import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/map_background_manager.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'access_logs_screen.dart';
import 'advanced_rtls_map_screen.dart';

/// Premium Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Expansion state for each card
  bool _isTagsExpanded = false;
  bool _isDoorsExpanded = false;
  bool _isSensorsExpanded = false;
  bool _isAlertsExpanded = false;

  final MapBackgroundManager _mapManager = MapBackgroundManager();
  Offset _rtlsLegendOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/logo/Quantum Mind Logo 2.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.hub,
                      color: Color(0xFF00FFC6),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Quantum Mind UWB Intelligent System',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF00FFC6)],
                ).createShader(bounds),
                child: const Text(
                  'Welcome to QuantumMind!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Real-time monitoring and control system',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 32),

              // Main Content Area - RTLS Map and Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // RTLS Live Map - full width
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF007AFF).withOpacity(0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Global RTLS overview
                              Container(
                                color: const Color(0xFF0B0C10),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.public,
                                        size: 56,
                                        color: Color(0xFF00FFC6),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Global RTLS View',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _mapManager.floors.isEmpty
                                            ? 'No floors defined yet. Open RTLS Map to create floors.'
                                            : 'Floors: ${_mapManager.floors.length}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_mapManager.floors.isNotEmpty)
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            for (int i = 0;
                                                i < _mapManager.floors.length;
                                                i++)
                                              ChoiceChip(
                                                label: Text(
                                                  _mapManager.floors[i].name,
                                                ),
                                                selected: false,
                                                labelStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                                backgroundColor:
                                                    const Color(0xFF111827),
                                                selectedColor:
                                                    const Color(0xFF007AFF),
                                                onSelected: (_) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AdvancedRtlsMapScreen(
                                                        initialFloorIndex: i,
                                                      ),
                                                    ),
                                                  ).then((_) {
                                                    setState(() {});
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const AdvancedRtlsMapScreen(),
                                            ),
                                          ).then((_) {
                                            setState(() {});
                                          });
                                        },
                                        icon: const Icon(Icons.map,
                                            color: Color(0xFF00FFC6), size: 18),
                                        label: const Text(
                                          'Open Advanced RTLS Map',
                                          style: TextStyle(
                                            color: Color(0xFF00FFC6),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Map Legend - draggable
                              Positioned(
                                top: 16,
                                right: 16,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      _rtlsLegendOffset += details.delta;
                                    });
                                  },
                                  child: Transform.translate(
                                    offset: _rtlsLegendOffset,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B0C10)
                                            .withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF00FFC6),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Active Tags',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF007AFF),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Doors',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Stats Cards moved under the map
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildExpandableStatCard(
                            'Active Tags',
                            '24',
                            Icons.sensors,
                            const Color(0xFF00FFC6),
                            _isTagsExpanded,
                            () => setState(() {
                              _isTagsExpanded = !_isTagsExpanded;
                              _isDoorsExpanded = false;
                              _isSensorsExpanded = false;
                              _isAlertsExpanded = false;
                            }),
                          ),
                          const SizedBox(width: 12),
                          _buildExpandableStatCard(
                            'Doors',
                            '8',
                            Icons.door_front_door,
                            const Color(0xFF007AFF),
                            _isDoorsExpanded,
                            () => setState(() {
                              _isDoorsExpanded = !_isDoorsExpanded;
                              _isTagsExpanded = false;
                              _isSensorsExpanded = false;
                              _isAlertsExpanded = false;
                            }),
                          ),
                          const SizedBox(width: 12),
                          _buildExpandableStatCard(
                            'Sensors',
                            '12',
                            Icons.thermostat,
                            const Color(0xFF9D4EDD),
                            _isSensorsExpanded,
                            () => setState(() {
                              _isSensorsExpanded = !_isSensorsExpanded;
                              _isTagsExpanded = false;
                              _isDoorsExpanded = false;
                              _isAlertsExpanded = false;
                            }),
                          ),
                          const SizedBox(width: 12),
                          _buildExpandableStatCard(
                            'Alerts',
                            '0',
                            Icons.warning,
                            const Color(0xFFF59E0B),
                            _isAlertsExpanded,
                            () => setState(() {
                              _isAlertsExpanded = !_isAlertsExpanded;
                              _isTagsExpanded = false;
                              _isDoorsExpanded = false;
                              _isSensorsExpanded = false;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions - Scrollable at Bottom
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Scrollable Quick Actions (smaller and more modern)
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildActionButton(
                      context,
                      'Access Logs',
                      Icons.list_alt,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccessLogsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      context,
                      'RTLS Map',
                      Icons.map,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdvancedRtlsMapScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      context,
                      'Sensors',
                      Icons.thermostat,
                      () {
                        // TODO: Navigate to Sensors
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sensors screen coming soon...'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      context,
                      'Settings',
                      Icons.settings,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F2937),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 36),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$title: $value',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
            // Expanded Content (when expanded)
            if (isExpanded)
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed information about $title',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Add more detailed content here as needed
                    const Text(
                      'Status: Operational',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Last Updated: Just now',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF00A3FF)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
