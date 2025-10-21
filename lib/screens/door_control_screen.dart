import 'package:flutter/material.dart';

/// Door Control Screen
class DoorControlScreen extends StatelessWidget {
  const DoorControlScreen({super.key});

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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDoorCard(
              context,
              'Main Entrance',
              'Building A',
              true,
            ),
            const SizedBox(height: 16),
            _buildDoorCard(
              context,
              'Warehouse Door 1',
              'Building B',
              false,
            ),
            const SizedBox(height: 16),
            _buildDoorCard(
              context,
              'Warehouse Door 2',
              'Building B',
              false,
            ),
            const SizedBox(height: 16),
            _buildDoorCard(
              context,
              'Office Entrance',
              'Building C',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoorCard(
    BuildContext context,
    String name,
    String location,
    bool isLocked,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isLocked ? Colors.redAccent : const Color(0xFF00FFC6))
              .withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.door_front_door,
                color: isLocked ? Colors.redAccent : const Color(0xFF00FFC6),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isLocked ? Colors.redAccent : const Color(0xFF00FFC6))
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLocked ? 'LOCKED' : 'UNLOCKED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        isLocked ? Colors.redAccent : const Color(0xFF00FFC6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening $name...')),
                    );
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC6),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Closing $name...')),
                    );
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
