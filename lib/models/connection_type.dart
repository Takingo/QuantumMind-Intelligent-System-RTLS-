/// Connection type for RTLS nodes
enum ConnectionType {
  ethernet('🌐'), // Ethernet connection
  wifi('📶'); // WiFi connection

  final String icon;

  const ConnectionType(this.icon);
}
