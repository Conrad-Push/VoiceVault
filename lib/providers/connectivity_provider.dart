import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  String _connectionType = 'No connection';

  bool get isConnected => _isConnected;
  String get connectionType => _connectionType;

  ConnectivityProvider() {
    _monitorConnectivity();
    _checkInitialConnection();
  }

  void _monitorConnectivity() {
    _connectivity.onConnectivityChanged.listen((dynamic connectivityResult) {
      final isConnected = _parseConnectivityResult(connectivityResult);
      final connectionType = _getConnectionType(connectivityResult);

      if (_isConnected != isConnected || _connectionType != connectionType) {
        _isConnected = isConnected;
        _connectionType = connectionType;

        notifyListeners();
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _isConnected = _parseConnectivityResult(connectivityResult);
    _connectionType = _getConnectionType(connectivityResult);

    notifyListeners();
  }

  bool _parseConnectivityResult(dynamic result) {
    if (result is List<ConnectivityResult>) {
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);
    } else if (result is ConnectivityResult) {
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
    }
    return false;
  }

  String _getConnectionType(dynamic result) {
    if (result is List<ConnectivityResult>) {
      if (result.contains(ConnectivityResult.wifi)) {
        return 'Wi-Fi';
      } else if (result.contains(ConnectivityResult.mobile)) {
        return 'Mobile';
      } else {
        return 'No connection';
      }
    } else if (result is ConnectivityResult) {
      if (result == ConnectivityResult.wifi) {
        return 'Wi-Fi';
      } else if (result == ConnectivityResult.mobile) {
        return 'Mobile';
      } else {
        return 'No connection';
      }
    }

    return 'Unknown';
  }
}
