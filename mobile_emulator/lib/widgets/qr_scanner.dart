import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_config.dart';

class QRScanner extends StatefulWidget {
  final Function(AppConfig) onAppConfigScanned;

  const QRScanner({
    Key? key,
    required this.onAppConfigScanned,
  }) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool hasPermission = false;
  late MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        try {
          final url = barcode.rawValue!;
          
          // Check if it's a preview URL
          if (url.startsWith('miniblocks://app')) {
            final appConfig = AppConfig.fromJson(
              Map<String, dynamic>.from(
                Uri.parse(url).queryParameters,
              ),
            );
            widget.onAppConfigScanned(appConfig);
            break;
          }
          // Check if it's an APK URL
          else if (url.toLowerCase().endsWith('.apk')) {
            final appConfig = AppConfig.fromApkUrl(url);
            widget.onAppConfigScanned(appConfig);
            break;
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid QR code format. Expected preview URL or APK download URL'),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error processing QR code'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Camera permission is required to scan QR codes',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPermission,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              'Scan QR code to connect to app or download APK',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }
} 