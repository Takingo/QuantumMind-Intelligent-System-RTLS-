import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quantummind_rtls/models/map_element_models.dart';
import 'package:quantummind_rtls/services/map_background_manager.dart';

void main() {
  group('MapFloor Tests', () {
    test('MapFloor can be created with default values', () {
      final floor = MapFloor(id: 'test_floor', name: 'Test Floor');

      expect(floor.id, 'test_floor');
      expect(floor.name, 'Test Floor');
      expect(floor.zones, isEmpty);
      expect(floor.walls, isEmpty);
      expect(floor.doors, isEmpty);
      expect(floor.anchors, isEmpty);
      expect(floor.tags, isEmpty);
      expect(floor.distanceLines, isEmpty);
      expect(floor.isManualGrid, true);
      expect(floor.backgroundScale, 1.0);
    });

    test('MapFloor can be created with custom values', () {
      final zone = MapZone(
        name: 'Test Zone',
        x: 100,
        y: 100,
        width: 200,
        height: 150,
        color: const Color(0xFF0000FF),
      );

      final floor = MapFloor(
        id: 'custom_floor',
        name: 'Custom Floor',
        zones: [zone],
        isManualGrid: false,
        backgroundScale: 0.05,
      );

      expect(floor.id, 'custom_floor');
      expect(floor.name, 'Custom Floor');
      expect(floor.zones.length, 1);
      expect(floor.zones.first.name, 'Test Zone');
      expect(floor.isManualGrid, false);
      expect(floor.backgroundScale, 0.05);
    });

    test('MapFloor can be copied', () {
      final originalZone = MapZone(
        name: 'Original Zone',
        x: 50,
        y: 50,
        width: 100,
        height: 100,
        color: const Color(0xFFFF0000),
      );

      final originalFloor = MapFloor(
        id: 'original',
        name: 'Original Floor',
        zones: [originalZone],
        isManualGrid: false,
      );

      final copiedFloor = originalFloor.copy();

      expect(copiedFloor.id, 'original');
      expect(copiedFloor.name, 'Original Floor');
      expect(copiedFloor.zones.length, 1);
      expect(copiedFloor.zones.first.name, 'Original Zone');
      expect(copiedFloor.isManualGrid, false);

      // Verify it's a deep copy by modifying the original
      originalFloor.name = 'Modified Original';
      originalZone.name = 'Modified Zone';

      // The copy should remain unchanged
      expect(copiedFloor.name, 'Original Floor');
      expect(copiedFloor.zones.first.name, 'Original Zone');
    });
  });

  group('MapBackgroundManager Multi-Floor Tests', () {
    test('MapBackgroundManager starts with default floor', () {
      final manager = MapBackgroundManager();

      expect(manager.floors.length, 1);
      expect(manager.currentFloor.name, 'Ground Floor');
      expect(manager.currentFloorIndex, 0);
    });

    test('MapBackgroundManager can add floors', () {
      final manager = MapBackgroundManager();

      manager.addFloor('First Floor');
      manager.addFloor('Second Floor');

      expect(manager.floors.length, 3);
      expect(manager.floors[1].name, 'First Floor');
      expect(manager.floors[2].name, 'Second Floor');
    });

    test('MapBackgroundManager can switch between floors', () {
      final manager = MapBackgroundManager();

      manager.addFloor('First Floor');
      manager.addFloor('Second Floor');

      // Switch to second floor (index 2)
      manager.switchToFloor(2);
      expect(manager.currentFloorIndex, 2);
      expect(manager.currentFloor.name, 'Second Floor');

      // Switch back to first floor (index 1)
      manager.switchToFloor(1);
      expect(manager.currentFloorIndex, 1);
      expect(manager.currentFloor.name, 'First Floor');
    });

    test('MapBackgroundManager can remove floors', () {
      final manager = MapBackgroundManager();

      manager.addFloor('First Floor');
      manager.addFloor('Second Floor');
      manager.addFloor('Third Floor');

      expect(manager.floors.length, 4);

      // Remove second floor (index 1)
      manager.removeFloor(1);
      expect(manager.floors.length, 3);
      expect(manager.floors[1].name,
          'Second Floor',); // This should now be the third floor
    });

    test('MapBackgroundManager prevents removing the last floor', () {
      final manager = MapBackgroundManager();

      // Try to remove the only floor (should not work)
      manager.removeFloor(0);
      expect(manager.floors.length, 1);
    });
  });
}
