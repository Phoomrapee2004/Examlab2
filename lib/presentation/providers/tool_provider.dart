import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/tool_entity.dart';
import '../../core/di/injection.dart';

final toolProvider = StateNotifierProvider<ToolNotifier, List<ToolEntity>>((ref) {
  final box = sl<Box<ToolEntity>>();
  return ToolNotifier(box);
});

final searchQueryProvider = StateProvider<String>((ref) => "");

// 💡 1. Provider สำหรับหมวดหมู่สินค้า
final selectedCategoryProvider = StateProvider<String>((ref) => "ทั้งหมด");

// 💡 2. Provider สำหรับ "ราคาช่าง" (เปิด = ลด 10%)
final isMechanicPriceProvider = StateProvider<bool>((ref) => false);

// 💡 3. Provider ระบบตะกร้า POS (เก็บ Key สินค้า และ จำนวนที่หยิบ)
class CartNotifier extends StateNotifier<Map<dynamic, int>> {
  CartNotifier() : super({});
  void addToCart(dynamic toolKey) => state = { ...state, toolKey: (state[toolKey] ?? 0) + 1 };
  void clearCart() => state = {};
}
final cartProvider = StateNotifierProvider<CartNotifier, Map<dynamic, int>>((ref) => CartNotifier());

// 💡 อัปเดตระบบค้นหาให้กรองทั้ง ชื่อ, บาร์โค้ด และ หมวดหมู่
final filteredToolsProvider = Provider<List<ToolEntity>>((ref) {
  final allTools = ref.watch(toolProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return allTools.where((t) {
    final matchSearch = t.name.toLowerCase().contains(query) || 
                        t.description.toLowerCase().contains(query) ||
                        (t.barcode != null && t.barcode!.toLowerCase().contains(query));
    final matchCategory = category == "ทั้งหมด" || t.category == category;
    return matchSearch && matchCategory;
  }).toList();
});

class ToolNotifier extends StateNotifier<List<ToolEntity>> {
  final Box<ToolEntity> _box;
  ToolNotifier(this._box) : super(_box.values.toList());

  void addTool(ToolEntity tool) async {
    await _box.add(tool);
    state = _box.values.toList();
  }
  void deleteTool(int index) async {
    await _box.deleteAt(index);
    state = _box.values.toList();
  }
  void updateTool(dynamic key, ToolEntity updatedTool) async {
    await _box.put(key, updatedTool);
    state = _box.values.toList();
  }
}