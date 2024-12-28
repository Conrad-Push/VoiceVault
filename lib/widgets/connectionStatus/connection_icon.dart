import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';

class ConnectionIcon extends StatelessWidget {
  const ConnectionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = context.watch<ConnectivityProvider>();

    IconData iconData;
    Color iconColor;

    switch (connectivityProvider.connectionType) {
      case 'Wi-Fi':
        iconData = Icons.wifi;
        iconColor = Colors.green;
        break;
      case 'Mobile':
        iconData = Icons.network_cell;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.wifi_off;
        iconColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
}
