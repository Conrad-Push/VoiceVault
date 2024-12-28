import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';

class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    if (!isConnected) {
      return Container(
        color: Colors.red,
        padding: const EdgeInsets.all(8),
        child: const Center(
          child: Text(
            'Brak połczenia z siecią',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
