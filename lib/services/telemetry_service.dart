import '../services/supabase_service.dart';

/// Telemetry Service for handling real-time tag position data
class TelemetryService {
  static TelemetryService? _instance;

  // Kalman filter parameters
  static const double kalmanQ = 0.01; // Process noise covariance
  static const double kalmanR = 0.1; // Measurement noise covariance

  // Filtered tag positions
  final Map<String, FilteredPosition> _filteredPositions = {};

  TelemetryService._();

  /// Get singleton instance
  static TelemetryService get instance {
    _instance ??= TelemetryService._();
    return _instance!;
  }

  /// Initialize real-time telemetry subscription
  void initializeTelemetryStream() {
    // Subscribe to telemetry table changes
    SupabaseService.instance.subscribeToTable(
      'telemetry',
      _handleTelemetryUpdate,
    );
  }

  /// Handle telemetry updates from Supabase
  void _handleTelemetryUpdate(dynamic event) {
    // Parse the event data
    if (event is Map<String, dynamic>) {
      final tagId = event['tag_id'] as String?;
      final x = event['x'] as num?;
      final y = event['y'] as num?;
      final z = event['z'] as num?;
      final timestamp = event['timestamp'] as String?;

      if (tagId != null && x != null && y != null) {
        // Apply filters to the position data
        final filteredPosition = _applyFilters(
          tagId,
          x.toDouble(),
          y.toDouble(),
          z?.toDouble(),
          timestamp != null ? DateTime.parse(timestamp) : DateTime.now(),
        );

        // Update filtered positions map
        _filteredPositions[tagId] = filteredPosition;
      }
    }
  }

  /// Apply Kalman and Median filters to position data
  FilteredPosition _applyFilters(
    String tagId,
    double x,
    double y,
    double? z,
    DateTime timestamp,
  ) {
    // Get previous filtered position
    final previous = _filteredPositions[tagId];

    // Apply Kalman filter
    final kalmanX = _kalmanFilter(previous?.kalmanX ?? x, x, tagId, 'x');
    final kalmanY = _kalmanFilter(previous?.kalmanY ?? y, y, tagId, 'y');
    final kalmanZ = z != null
        ? _kalmanFilter(previous?.kalmanZ ?? z, z, tagId, 'z')
        : previous?.kalmanZ;

    // Apply Median filter (using a sliding window of 5 samples)
    final medianX = _medianFilter(tagId, 'x', kalmanX);
    final medianY = _medianFilter(tagId, 'y', kalmanY);
    final medianZ = kalmanZ != null ? _medianFilter(tagId, 'z', kalmanZ) : null;

    return FilteredPosition(
      rawX: x,
      rawY: y,
      rawZ: z,
      kalmanX: kalmanX,
      kalmanY: kalmanY,
      kalmanZ: kalmanZ,
      medianX: medianX,
      medianY: medianY,
      medianZ: medianZ,
      timestamp: timestamp,
    );
  }

  /// Kalman filter implementation
  double _kalmanFilter(
    double previousEstimate,
    double measurement,
    String tagId,
    String axis,
  ) {
    // Get stored filter state
    final key = '$tagId-$axis';
    final prevState = _kalmanStates[key] ?? KalmanState(0, 1);

    // Prediction step
    final predictedEstimate = previousEstimate;
    final predictedError = prevState.error + kalmanQ;

    // Update step
    final kalmanGain = predictedError / (predictedError + kalmanR);
    final estimate =
        predictedEstimate + kalmanGain * (measurement - predictedEstimate);
    final error = (1 - kalmanGain) * predictedError;

    // Store updated state
    _kalmanStates[key] = KalmanState(estimate, error);

    return estimate;
  }

  // Kalman filter states for each tag-axis combination
  final Map<String, KalmanState> _kalmanStates = {};

  // Median filter windows for each tag-axis combination
  final Map<String, List<double>> _medianWindows = {};

  /// Median filter implementation
  double _medianFilter(String tagId, String axis, double value) {
    final key = '$tagId-$axis';
    final window = _medianWindows.putIfAbsent(key, () => []);

    // Add new value to window
    window.add(value);

    // Maintain window size
    if (window.length > 5) {
      window.removeAt(0);
    }

    // Calculate median
    final sorted = List<double>.from(window)..sort();
    if (sorted.length.isOdd) {
      return sorted[sorted.length ~/ 2];
    } else {
      final mid = sorted.length ~/ 2;
      return (sorted[mid - 1] + sorted[mid]) / 2;
    }
  }

  /// Get filtered position for a tag
  FilteredPosition? getFilteredPosition(String tagId) {
    return _filteredPositions[tagId];
  }

  /// Get all filtered positions
  Map<String, FilteredPosition> getAllFilteredPositions() {
    return Map.from(_filteredPositions);
  }

  /// Clear filtered positions for a tag
  void clearFilteredPosition(String tagId) {
    _filteredPositions.remove(tagId);
    _clearFilterStates(tagId);
  }

  /// Clear all filter states for a tag
  void _clearFilterStates(String tagId) {
    _kalmanStates.removeWhere((key, _) => key.startsWith(tagId));
    _medianWindows.removeWhere((key, _) => key.startsWith(tagId));
  }
}

/// Filtered Position Data
class FilteredPosition {
  final double rawX;
  final double rawY;
  final double? rawZ;
  final double kalmanX;
  final double kalmanY;
  final double? kalmanZ;
  final double medianX;
  final double medianY;
  final double? medianZ;
  final DateTime timestamp;

  FilteredPosition({
    required this.rawX,
    required this.rawY,
    this.rawZ,
    required this.kalmanX,
    required this.kalmanY,
    this.kalmanZ,
    required this.medianX,
    required this.medianY,
    this.medianZ,
    required this.timestamp,
  });

  /// Get best estimate (using median-filtered values)
  (double, double, double?) get bestEstimate => (medianX, medianY, medianZ);
}

/// Kalman Filter State
class KalmanState {
  final double estimate;
  final double error;

  KalmanState(this.estimate, this.error);
}
