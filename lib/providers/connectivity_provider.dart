import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _monitorConnectivity();
    _checkInitialConnection();
  }

  void _monitorConnectivity() {
    _connectivity.onConnectivityChanged.listen((dynamic connectivityResult) {
      final isConnected = _parseConnectivityResult(connectivityResult);
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        debugPrint('Connection status changed: $_isConnected');
        notifyListeners(); // Powiadamiaj UI o zmianie stanu
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _isConnected = _parseConnectivityResult(connectivityResult);
    debugPrint('Initial connection status: $_isConnected');
    notifyListeners(); // Powiadamiaj UI o początkowym stanie
  }

  bool _parseConnectivityResult(dynamic result) {
    if (result is List<ConnectivityResult>) {
      // Obsługa listy ConnectivityResult
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);
    } else if (result is ConnectivityResult) {
      // Obsługa pojedynczego ConnectivityResult
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
    }
    return false;
  }
}
