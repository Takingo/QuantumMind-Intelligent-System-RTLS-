import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rtls_provider.dart';

/// Real-Time Door Control Screen with MQTT Integration
class DoorControlScreen extends StatefulWidget {
  const DoorControlScreen({super.key});

  @override
  State<DoorControlScreen> createState() => _DoorControlScreenState();
}

class _DoorControlScreenState extends State<DoorControlScreen> {
  // Door IDs matching map doors
  final List<DoorInfo> _doors = [
    DoorInfo(id: 'door_1', name: 'Main Entrance', location: 'Building A'),
    DoorInfo(id: 'door_2', name: 'Warehouse Door 1', location: 'Building B'),
    DoorInfo(id: 'door_3', name: 'Warehouse Door 2', location: 'Building B'),
    DoorInfo(id: 'door_4', name: 'Office Entrance', location: 'Building C'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Door Control'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<RtlsProvider>(
            builder: (context, rtls, _) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rtls.isConnected
                      ? const Color(0xFF00FFC6).withOpacity(0.2)
                      : Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: rtls.isConnected
                          ? const Color(0xFF00FFC6)
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rtls.isConnected ? 'Live' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: rtls.isConnected
                            ? const Color(0xFF00FFC6)
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<RtlsProvider>(
          builder: (context, rtls, _) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _doors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final door = _doors[index];
                final status = rtls.getDoorStatus(door.id);
                return _buildDoorCard(context, rtls, door, status);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDoorCard(
    BuildContext context,
    RtlsProvider rtls,
    DoorInfo door,
    DoorStatus? status,
  ) {
    final isLocked = status?.isLocked ?? false;
    final doorState = status?.status ?? DoorState.unknown;
    final statusColor = status?.getStatusColor() ?? Colors.grey;
    final statusText = status?.getStatusText() ?? 'UNKNOWN';

    // Determine if door is in transition
    final isTransitioning =
        doorState == DoorState.opening || doorState == DoorState.closing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Animated door icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _getDoorIcon(doorState),
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      door.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      door.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (status != null)
                      Text(
                        'Updated: ${_formatTimestamp(status.timestamp)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              // Animated status badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isTransitioning)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(statusColor),
                        ),
                      ),
                    if (isTransitioning) const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isTransitioning ? null : () => rtls.openDoor(door.id),
                  icon: const Icon(Icons.lock_open, size: 18),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC6),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isTransitioning ? null : () => rtls.closeDoor(door.id),
                  icon: const Icon(Icons.lock, size: 18),
                  label: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isTransitioning ? null : () => rtls.lockDoor(door.id),
                  icon: const Icon(Icons.lock_clock, size: 18),
                  label: const Text('Lock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDoorIcon(DoorState state) {
    switch (state) {
      case DoorState.open:
        return Icons.door_front_door_outlined;
      case DoorState.closed:
        return Icons.door_front_door;
      case DoorState.locked:
        return Icons.lock;
      case DoorState.opening:
      case DoorState.closing:
        return Icons.sync;
      case DoorState.unknown:
        return Icons.help_outline;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}

/// Door Information Model
class DoorInfo {
  final String id;
  final String name;
  final String location;

  DoorInfo({
    required this.id,
    required this.name,
    required this.location,
  });
}
