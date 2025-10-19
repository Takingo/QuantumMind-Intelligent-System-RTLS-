/// Application Constants
class AppConstants {
  // ========== App Info ==========
  static const String appName = 'QuantumMind RTLS';
  static const String appVersion = '1.0.0';
  static const String companyName = 'QuantumMind Innovation';
  
  // ========== Supabase Configuration ==========
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // ========== Realtime Channels ==========
  static const String channelLivePosition = 'live_position';
  static const String channelDoorStatus = 'door_status';
  static const String channelSensorUpdates = 'sensor_updates';
  
  // ========== Database Tables ==========
  static const String tableUsers = 'users';
  static const String tableUwbTags = 'uwb_tags';
  static const String tableDevices = 'devices';
  static const String tableDoors = 'doors';
  static const String tableRtlsNodes = 'rtls_nodes';
  static const String tableSensorData = 'sensor_data';
  static const String tableLogs = 'logs';
  
  // ========== User Roles ==========
  static const String roleAdmin = 'Admin';
  static const String roleUser = 'User';
  static const String roleViewer = 'Viewer';
  
  // ========== MQTT Configuration ==========
  static const String mqttBroker = 'localhost'; // Replace with your MQTT broker
  static const int mqttPort = 1883;
  static const String mqttTopicDoorControl = 'quantummind/door/control';
  static const String mqttTopicSensorData = 'quantummind/sensor/data';
  static const String mqttTopicRtlsPosition = 'quantummind/rtls/position';
  
  // ========== HTTP Endpoints (for ESP32) ==========
  static const String espBaseUrl = 'http://192.168.1.100'; // Replace with ESP32 IP
  static const String endpointDoorOpen = '/door/open';
  static const String endpointDoorClose = '/door/close';
  static const String endpointDoorStatus = '/door/status';
  static const String endpointConfig = '/config';
  
  // ========== Security ==========
  static const String encryptionAlgorithm = 'AES-256';
  static const int tokenLength = 32;
  
  // ========== UI Configuration ==========
  static const int chartUpdateIntervalMs = 2000;
  static const int mapUpdateIntervalMs = 500;
  static const int sensorUpdateIntervalMs = 5000;
  
  // ========== Door Configuration ==========
  static const double defaultDoorThreshold = 1.5; // meters
  static const int defaultDoorOpenDuration = 3000; // milliseconds
  static const double minThreshold = 0.5;
  static const double maxThreshold = 5.0;
  
  // ========== RTLS Configuration ==========
  static const double factoryFloorWidth = 100.0; // meters
  static const double factoryFloorHeight = 80.0; // meters
  static const int maxTagHistory = 50; // number of position points to keep
  
  // ========== Sensor Thresholds ==========
  static const double tempMin = 15.0; // Celsius
  static const double tempMax = 30.0;
  static const double humidityMin = 30.0; // Percentage
  static const double humidityMax = 70.0;
  static const double airQualityGood = 50.0; // AQI
  static const double airQualityModerate = 100.0;
  
  // ========== Languages ==========
  static const String langEnglish = 'en';
  static const String langGerman = 'de';
  static const String langTurkish = 'tr';
  
  // ========== Storage Keys ==========
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  
  // ========== Animation Durations ==========
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // ========== API Timeouts ==========
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration mqttTimeout = Duration(seconds: 10);
  
  // ========== Pagination ==========
  static const int logsPerPage = 50;
  static const int tagsPerPage = 20;
  static const int usersPerPage = 20;
  
  // ========== File Paths ==========
  static const String logoPath = 'assets/logo/quantummind_logo.png';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
  static const String loadingAnimationPath = 'assets/animations/loading.json';
  
  // ========== Chart Colors ==========
  static const List<String> chartColors = [
    '#007AFF', // Quantum Blue
    '#00FFC6', // Energy Green
    '#9D4EDD', // Neon Purple
    '#FF006E', // Neon Pink
    '#00D9FF', // Neon Blue
    '#F59E0B', // Warning
    '#10B981', // Success
    '#EF4444', // Error
  ];
  
  // ========== Error Messages ==========
  static const String errorNetworkConnection = 'Network connection failed';
  static const String errorAuthentication = 'Authentication failed';
  static const String errorPermissionDenied = 'Permission denied';
  static const String errorInvalidCredentials = 'Invalid credentials';
  static const String errorServerError = 'Server error occurred';
  static const String errorTimeout = 'Request timeout';
  
  // ========== Success Messages ==========
  static const String successLogin = 'Login successful';
  static const String successLogout = 'Logged out successfully';
  static const String successDoorOpen = 'Door opened successfully';
  static const String successDoorClose = 'Door closed successfully';
  static const String successBackup = 'Backup created successfully';
  static const String successRestore = 'Data restored successfully';
}
