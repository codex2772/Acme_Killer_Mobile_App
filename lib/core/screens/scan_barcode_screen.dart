import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';

class ScanBarcodeScreen extends StatelessWidget {
  const ScanBarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final String? code = barcodeCapture.barcodes.first.rawValue;

          if (code != null) {
            Get.back(result: code);
          }
        },
      ),
    );
  }
}
