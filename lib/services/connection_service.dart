import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/app_config.dart';

class ConnectionService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;
  AppConfig? _currentApp;
  StreamSubscription? _connectionSubscription;

  bool get isConnected => _isConnected;
  AppConfig? get currentApp => _currentApp;

  ConnectionService() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();

      _connectionSubscription = _connectivity.onConnectivityChanged.listen(
        (result) {
          _isConnected = result != ConnectivityResult.none;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  Future<void> connectToApp(AppConfig app) async {
    _currentApp = app;
    notifyListeners();
  }

  void disconnectFromApp() {
    _currentApp = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
} 