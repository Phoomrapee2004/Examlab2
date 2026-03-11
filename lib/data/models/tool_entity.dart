import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'tool_entity.g.dart';

@HiveType(typeId: 0)
class ToolEntity extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String description;
  
  @HiveField(2)
  final double price;
  
  @HiveField(3)
  final Uint8List? imageBytes;

  @HiveField(4)
  final String? barcode;

  @HiveField(5, defaultValue: 0)
  int quantity; 

  // 💡 เพิ่มระบบหมวดหมู่สินค้า
  @HiveField(6, defaultValue: 'ทั่วไป')
  final String category;

  ToolEntity({
    required this.name,
    required this.description,
    required this.price,
    this.imageBytes,
    this.barcode,
    this.quantity = 0,
    this.category = 'ทั่วไป', // ค่าเริ่มต้น
  });
}