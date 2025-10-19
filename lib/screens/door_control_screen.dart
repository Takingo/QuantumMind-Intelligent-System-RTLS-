import 'package:flutter/material.dart';
import '../theme/theme_config.dart';
import '../widgets/header_bar.dart';
import '../widgets/quantum_background.dart';
import '../widgets/dashboard_card.dart';
import '../models/door_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/http_service.dart';
import '../utils/helpers.dart';

class DoorControlScreen extends StatefulWidget {
  const DoorControlScreen({Key? key}) : super(key: key);
  
  @override
  State<DoorControlScreen> createState() => _DoorControlScreenState();
}

class _DoorControlScreenState extends State<DoorControlScreen> {
  final _authService = AuthService();
  final _httpService = HttpService.instance;
  UserModel? _currentUser;
  List<DoorModel> _doors = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final user = await _authService.getCurrentUserData();
    setState(() {
      _currentUser = user;
      _doors = [
        DoorModel(
          id: '1',
          name: 'Main Entrance',
          threshold: 1.5,
          relayPin: 4,
          status: 'closed',
          location: 'Building A',
          createdAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QuantumBackground(
        child: Column(
          children: [
            HeaderBar(user: _currentUser),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Center(child: Text('Door Control - Coming Soon')),
            ),
          ],
        ),
      ),
    );
  }
}
