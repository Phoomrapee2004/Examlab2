import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerService {
  final BarcodeScanner _scanner = BarcodeScanner();

  Future<String?> scanImage(InputImage inputImage) async {
    final List<Barcode> barcodes = await _scanner.processImage(inputImage);
    if (barcodes.isNotEmpty) {
      return barcodes.first.rawValue; // คืนค่าบาร์โค้ดเพื่อไปค้นหาใน Isar DB
    }
    return null;
  }
}