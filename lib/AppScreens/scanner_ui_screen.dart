import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanUpiQrScreen extends StatelessWidget {
  final Function(String upiId) onUpiDetected;

  ScanUpiQrScreen({super.key, required this.onUpiDetected});

  final MobileScannerController mobileScannerController =
      MobileScannerController(
    autoZoom: true,
    formats: [BarcodeFormat.qrCode],
    torchEnabled: true,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan UPI QR"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => mobileScannerController.toggleTorch(),
          )
        ],
      ),
      body: MobileScanner(
        controller: mobileScannerController,
        onDetect: (BarcodeCapture capture) {
          if (capture.barcodes.isEmpty) return;

          final Barcode barcode = capture.barcodes.first;
          final String? rawValue = barcode.rawValue;

          if (rawValue == null) return;

          if (rawValue.startsWith("upi://pay")) {
            final Uri uri = Uri.parse(rawValue);
            final String? upiId = uri.queryParameters['pa'];

            if (upiId != null && upiId.isNotEmpty) {
              mobileScannerController.stop();
              Get.back();
              onUpiDetected(upiId);
            } else {
              Get.snackbar(
                "Invalid QR",
                "UPI ID not found",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          } else {
            Get.snackbar(
              "Invalid QR",
              "Not a valid UPI QR code",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }
}
