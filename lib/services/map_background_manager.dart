import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/map_element_models.dart';

/// Map Background Manager
/// Handles floor plan imports, grid creation, and background management
class MapBackgroundManager {
  // Multi-floor support
  List<MapFloor> _floors = [];
  int _currentFloorIndex = 0;

  // Current floor getters
  MapFloor get currentFloor =>
      _floors.isNotEmpty ? _floors[_currentFloorIndex] : _createDefaultFloor();

  List<MapFloor> get floors => _floors;
  int get currentFloorIndex => _currentFloorIndex;

  // Initialize with a default floor
  MapBackgroundManager() {
    _floors.add(_createDefaultFloor());
  }

  MapFloor _createDefaultFloor() {
    return MapFloor(
      id: 'floor_0',
      name: 'Ground Floor',
    );
  }

  /// Add a new floor
  void addFloor(String name) {
    final newFloor = MapFloor(
      id: 'floor_${_floors.length}',
      name: name,
    );
    _floors.add(newFloor);
  }

  /// Remove a floor
  void removeFloor(int index) {
    if (_floors.length > 1 && index >= 0 && index < _floors.length) {
      _floors.removeAt(index);
      if (_currentFloorIndex >= _floors.length) {
        _currentFloorIndex = _floors.length - 1;
      }
    }
  }

  /// Switch to a different floor
  void switchToFloor(int index) {
    if (index >= 0 && index < _floors.length) {
      _currentFloorIndex = index;
    }
  }

  /// Rename a floor
  void renameFloor(int index, String newName) {
    if (index >= 0 && index < _floors.length) {
      _floors[index].name = newName;
    }
  }

  /// Import floor plan from file (image or PDF) for current floor
  Future<bool> importFloorPlan(BuildContext context) async {
    try {
      // Show options dialog
      final choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: const Text(
              'Import Floor Plan',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: const Text('From Gallery (Image)',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pop('image'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('From Camera',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pop('camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('From PDF',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).pop('pdf'),
                ),
              ],
            ),
          );
        },
      );

      if (choice == null) return false;

      Uint8List? bytes;
      String? filePath;

      if (choice == 'pdf') {
        // For PDF, we'll use the document picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.bytes != null) {
            bytes = file.bytes;
          } else if (file.path != null) {
            final platformFile = File(file.path!);
            bytes = await platformFile.readAsBytes();
          }
          filePath = file.path;
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final source =
            choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
        final imageFile = await picker.pickImage(source: source);

        if (imageFile != null) {
          bytes = await imageFile.readAsBytes();
          filePath = imageFile.path;
        }
      }

      if (bytes != null) {
        currentFloor.backgroundImageBytes = bytes;
        currentFloor.backgroundImagePath = filePath;
        currentFloor.isManualGrid = false;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Floor plan imported successfully'),
              backgroundColor: Color(0xFF00FFC6),
            ),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Create a new blank map with grid for current floor
  void createNewMap() {
    currentFloor.backgroundImageBytes = null;
    currentFloor.backgroundImagePath = null;
    currentFloor.isManualGrid = true;
    currentFloor.backgroundScale = 1.0;
    currentFloor.backgroundPosition = Offset.zero;
  }

  /// Replace current background for current floor
  Future<bool> replaceBackground(BuildContext context) async {
    return await importFloorPlan(context);
  }

  /// Hide/show background for current floor
  void toggleBackgroundVisibility() {
    if (currentFloor.isManualGrid) {
      // If currently using grid, switch to image if available
      if (currentFloor.backgroundImageBytes != null) {
        currentFloor.isManualGrid = false;
      }
    } else {
      // If currently using image, switch to grid
      currentFloor.isManualGrid = true;
    }
  }

  /// Reset background to default grid for current floor
  void resetToGrid() {
    currentFloor.backgroundImageBytes = null;
    currentFloor.backgroundImagePath = null;
    currentFloor.isManualGrid = true;
    currentFloor.backgroundScale = 1.0;
    currentFloor.backgroundPosition = Offset.zero;
  }

  /// Update background scale (for zoom) for current floor
  void updateScale(double scale) {
    currentFloor.backgroundScale = scale;
  }

  /// Update background position (for pan) for current floor
  void updatePosition(Offset position) {
    currentFloor.backgroundPosition = position;
  }

  /// Export map with background to PDF
  Future<String?> exportToPdf({
    required List<MapZone> zones,
    required List<MapWall> walls,
    required List<MapDoor> doors,
    required List<MapAnchor> anchors,
    required List<MapTag> tags,
    required List<MapDistanceLine> distanceLines,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'QuantumMind RTLS - Factory Floor Plan',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Map Elements:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('• Zones: ${zones.length}'),
                pw.Text('• Walls: ${walls.length}'),
                pw.Text('• Doors: ${doors.length}'),
                pw.Text('• Anchors: ${anchors.length}'),
                pw.Text('• Tags: ${tags.length}'),
                pw.Text('• Distance Lines: ${distanceLines.length}'),
                pw.SizedBox(height: 20),
                if (zones.isNotEmpty) ...[
                  pw.Text(
                    'Zones:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  ...zones.map((zone) {
                    if (zone is MapZone) {
                      return pw.Text('  • ${zone.name}');
                    }
                    return pw.Text('  • Unknown Zone');
                  }).toList(),
                  pw.SizedBox(height: 10),
                ],
                if (tags.isNotEmpty) ...[
                  pw.Text(
                    'Tags:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  ...tags.map((tag) {
                    if (tag is MapTag) {
                      return pw.Text('  • ${tag.name} (${tag.type.label})');
                    }
                    return pw.Text('  • Unknown Tag');
                  }).toList(),
                  pw.SizedBox(height: 10),
                ],
                if (anchors.isNotEmpty) ...[
                  pw.Text(
                    'UWB Anchors:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  ...anchors.map((anchor) {
                    if (anchor is MapAnchor) {
                      return pw.Text('  • ${anchor.name} - ID: ${anchor.id}');
                    }
                    return pw.Text('  • Unknown Anchor');
                  }).toList(),
                ],
              ],
            );
          },
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final fileName = 'rtls_map_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Get background widget for rendering
  Widget getBackgroundWidget() {
    if (currentFloor.isManualGrid ||
        currentFloor.backgroundImageBytes == null) {
      return CustomPaint(painter: GridPainter());
    } else {
      return Image.memory(
        currentFloor.backgroundImageBytes!,
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
      );
    }
  }

  /// Check if background is currently visible
  bool isBackgroundVisible() {
    return !currentFloor.isManualGrid ||
        currentFloor.backgroundImageBytes != null;
  }
}

/// Grid Painter for manual map creation
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw grid lines
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
