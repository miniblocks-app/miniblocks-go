import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_service.dart';
import '../models/app_config.dart';
import '../widgets/qr_scanner.dart';
import 'app_view_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionService>(
      builder: (context, connectionService, child) {
        if (connectionService.currentApp != null) {
          return AppViewScreen(
            appConfig: connectionService.currentApp!,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mobile Emulator'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Implement settings
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: connectionService.isConnected
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      connectionService.isConnected
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: connectionService.isConnected
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectionService.isConnected
                          ? 'Connected to WiFi'
                          : 'Not connected to WiFi',
                      style: TextStyle(
                        color: connectionService.isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: QRScanner(
                  onAppConfigScanned: (appConfig) {
                    connectionService.connectToApp(appConfig);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 