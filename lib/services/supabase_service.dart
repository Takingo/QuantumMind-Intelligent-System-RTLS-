import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

/// Supabase Service - Core database and realtime functionality
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;
  
  SupabaseService._();
  
  /// Get singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  
  /// Get Supabase client
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }
  
  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;
  }
  
  /// Check if initialized
  bool get isInitialized => _client != null;
  
  // ========== Database Operations ==========
  
  /// Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    try {
      final response = await client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch data from $table: $e');
    }
  }
  
  /// Get record by ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    try {
      final response = await client
          .from(table)
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch record from $table: $e');
    }
  }
  
  /// Get records with filter
  Future<List<Map<String, dynamic>>> getWhere(
    String table,
    String column,
    dynamic value,
  ) async {
    try {
      final response = await client
          .from(table)
          .select()
          .eq(column, value);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch filtered data from $table: $e');
    }
  }
  
  /// Insert record
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(table)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to insert data into $table: $e');
    }
  }
  
  /// Update record
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to update data in $table: $e');
    }
  }
  
  /// Delete record
  Future<void> delete(String table, String id) async {
    try {
      await client
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete data from $table: $e');
    }
  }
  
  // ========== Realtime Subscriptions ==========
  
  /// Subscribe to table changes
  RealtimeChannel subscribeToTable(
    String table,
    void Function(PostgresChangePayload event) callback,
  ) {
    final channel = client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: callback,
        )
        .subscribe();
    
    return channel;
  }
  
  /// Subscribe to specific channel
  RealtimeChannel subscribeToChannel(
    String channelName,
    void Function(dynamic payload) callback,
  ) {
    final channel = client
        .channel(channelName)
        .onBroadcast(
          event: channelName,
          callback: (payload) => callback(payload),
        )
        .subscribe();
    
    return channel;
  }
  
  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
  
  // ========== Storage Operations ==========
  
  /// Upload file
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> fileBytes,
  ) async {
    try {
      await client.storage
          .from(bucket)
          .uploadBinary(path, Uint8List.fromList(fileBytes));
      
      final publicUrl = client.storage
          .from(bucket)
          .getPublicUrl(path);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  /// Download file
  Future<List<int>> downloadFile(String bucket, String path) async {
    try {
      final response = await client.storage
          .from(bucket)
          .download(path);
      
      return response;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }
  
  /// Delete file
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await client.storage
          .from(bucket)
          .remove([path]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
  
  // ========== RPC Functions ==========
  
  /// Call remote procedure
  Future<dynamic> callFunction(
    String functionName,
    Map<String, dynamic>? params,
  ) async {
    try {
      final response = await client.rpc(
        functionName,
        params: params,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to call function $functionName: $e');
    }
  }
}
