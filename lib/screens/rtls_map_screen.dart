import 'package:flutter/material.dart';

/// RTLS Live Map Screen
class RtlsMapScreen extends StatefulWidget {
  const RtlsMapScreen({super.key});

  @override
  State<RtlsMapScreen> createState() => _RtlsMapScreenState();
}

class _RtlsMapScreenState extends State<RtlsMapScreen> {
  // Mock data for tags
  final List<MapTag> _tags = [
    MapTag(id: '001', name: 'Worker-1', x: 150, y: 200, isActive: true),
    MapTag(id: '002', name: 'Worker-2', x: 300, y: 350, isActive: true),
    MapTag(id: '003', name: 'Forklift-1', x: 450, y: 150, isActive: true),
    MapTag(id: '004', name: 'Cart-1', x: 200, y: 450, isActive: false),
  ];

  bool _isEditMode = false;
  MapTag? _selectedTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('RTLS Live Map'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
                if (!_isEditMode) _selectedTag = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      _isEditMode ? 'Edit mode enabled' : 'Edit mode disabled'),
                ),
              );
            },
            tooltip: _isEditMode ? 'Done' : 'Edit Map',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map refreshed')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                    // Grid background
                    CustomPaint(
                      painter: GridPainter(),
                      size: Size.infinite,
                    ),

                    // Tags
                    ..._tags
                        .map((tag) => Positioned(
                              left: tag.x,
                              top: tag.y,
                              child: _buildTag(tag),
                            ))
                        .toList(),

                    // Legend
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _buildLegend(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tag List
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      return _buildTagCard(tag);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isEditMode && _selectedTag != null
          ? FloatingActionButton.extended(
              onPressed: () {
                _deleteTag(_selectedTag!);
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Tag'),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                // Navigate to add tag screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTagScreen()),
                );
              },
              backgroundColor: const Color(0xFF00FFC6),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('Add Tag'),
            ),
    );
  }

  Widget _buildTag(MapTag tag) {
    final isSelected = _selectedTag?.id == tag.id;

    return GestureDetector(
      onTap: () {
        if (_isEditMode) {
          setState(() {
            _selectedTag = isSelected ? null : tag;
          });
        } else {
          _showTagDetails(tag);
        }
      },
      onPanUpdate: _isEditMode
          ? (details) {
              setState(() {
                tag.x += details.delta.dx;
                tag.y += details.delta.dy;
              });
            }
          : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: tag.isActive ? const Color(0xFF00FFC6) : Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.red : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (tag.isActive ? const Color(0xFF00FFC6) : Colors.grey)
                  .withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            tag.id,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(const Color(0xFF00FFC6), 'Active'),
          const SizedBox(height: 4),
          _buildLegendItem(Colors.grey, 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTagCard(MapTag tag) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tag.isActive
              ? const Color(0xFF00FFC6).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tag.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ID: ${tag.id}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tag.isActive ? const Color(0xFF00FFC6) : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                tag.isActive ? 'Active' : 'Offline',
                style: TextStyle(
                  color: tag.isActive ? const Color(0xFF00FFC6) : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteTag(MapTag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Delete Tag',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${tag.name}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tags.removeWhere((t) => t.id == tag.id);
                _selectedTag = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tag ${tag.name} deleted'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showTagDetails(MapTag tag) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tag.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', tag.id),
              _buildDetailRow(
                  'Position', 'X: ${tag.x.toInt()}, Y: ${tag.y.toInt()}'),
              _buildDetailRow('Status', tag.isActive ? 'Active' : 'Offline'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Tag Model
class MapTag {
  final String id;
  final String name;
  double x;
  double y;
  final bool isActive;

  MapTag({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.isActive,
  });
}

// Add Tag Screen
class AddTagScreen extends StatefulWidget {
  const AddTagScreen({super.key});

  @override
  State<AddTagScreen> createState() => _AddTagScreenState();
}

class _AddTagScreenState extends State<AddTagScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  String _tagType = 'Worker';

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Add UWB Tag'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tag Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Tag ID
              TextFormField(
                controller: _idController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tag ID',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.tag, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007AFF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tag ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Tag Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tag Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.label, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF007AFF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tag name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Tag Type
              const Text(
                'Tag Type',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children:
                    ['Worker', 'Equipment', 'Vehicle', 'Asset'].map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _tagType == type,
                    onSelected: (selected) {
                      setState(() => _tagType = type);
                    },
                    selectedColor: const Color(0xFF007AFF),
                    backgroundColor: const Color(0xFF1F2937),
                    labelStyle: TextStyle(
                      color: _tagType == type ? Colors.white : Colors.grey,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tag'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag() {
    if (_formKey.currentState!.validate()) {
      // TODO: Add tag to database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag ${_idController.text} added successfully!'),
          backgroundColor: const Color(0xFF00FFC6),
        ),
      );
      Navigator.pop(context);
    }
  }
}
