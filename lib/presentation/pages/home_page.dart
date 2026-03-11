// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../core/routes/app_router.dart';
import '../providers/tool_provider.dart';
import '../../core/di/injection.dart';
import '../../data/services/ai_assistant_service.dart';
import '../../data/models/tool_entity.dart';
import '../../main.dart'; // 💡 นำเข้า themeModeProvider จาก main.dart

// ==========================================
// 1. หน้าต่าง Groq AI ผู้ช่วยอัจฉริยะ
// ==========================================
class GroqChatDialog extends StatefulWidget {
  const GroqChatDialog({super.key});
  @override
  State<GroqChatDialog> createState() => _GroqChatDialogState();
}

class _GroqChatDialogState extends State<GroqChatDialog> {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  String aiResponse = "";

  Future<void> handleSend() async {
    if (searchController.text.isEmpty) return;
    setState(() { isLoading = true; aiResponse = ""; });
    try {
      final response = await sl<AIAssistantService>().getToolRecommendation(searchController.text);
      setState(() { isLoading = false; aiResponse = response; });
    } catch (e) { setState(() { isLoading = false; aiResponse = "เกิดข้อผิดพลาด: $e"; }); }
  }

  @override
  Widget build(BuildContext context) {
    // เช็คว่าตอนนี้เป็นโหมดมืดหรือไม่
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [const Icon(Icons.bolt, color: Colors.blueAccent, size: 32), const SizedBox(width: 10), Text('Groq ผู้ช่วยร้านช่าง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))]),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onSubmitted: (_) => handleSend(), 
              decoration: InputDecoration(
                hintText: 'ถามปัญหาช่าง...', 
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                filled: true, fillColor: isDark ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[400]!)), 
                suffixIcon: isLoading ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(icon: const Icon(Icons.send, color: Colors.blueAccent), onPressed: handleSend)
              )
            ),
            if (aiResponse.isNotEmpty) ...[
              const SizedBox(height: 20), 
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16), 
                decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.blue[50], borderRadius: BorderRadius.circular(16)), 
                child: Text(aiResponse, style: TextStyle(fontSize: 16, height: 1.5, color: isDark ? Colors.grey[200] : Colors.black87))
              )
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. หน้าต่างระบบชำระเงิน (Cart & Checkout)
// ==========================================
class CartDialog extends ConsumerWidget {
  const CartDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final allTools = ref.watch(toolProvider);
    final isMechanicPrice = ref.watch(isMechanicPriceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cartItems = cart.entries.map((entry) {
      final tool = allTools.firstWhere((t) => t.key == entry.key);
      return {'tool': tool, 'quantity': entry.value};
    }).toList();

    double totalPrice = 0;
    for (var item in cartItems) {
      final tool = item['tool'] as ToolEntity;
      final qty = item['quantity'] as int;
      final price = isMechanicPrice ? tool.price * 0.9 : tool.price;
      totalPrice += price * qty;
    }

    void processCheckout() {
      for (var item in cartItems) {
        final tool = item['tool'] as ToolEntity;
        final qtyToDeduct = item['quantity'] as int;
        final newQuantity = (tool.quantity - qtyToDeduct) < 0 ? 0 : (tool.quantity - qtyToDeduct);
        final updatedTool = ToolEntity(name: tool.name, description: tool.description, price: tool.price, imageBytes: tool.imageBytes, barcode: tool.barcode, category: tool.category, quantity: newQuantity);
        ref.read(toolProvider.notifier).updateTool(tool.key, updatedTool);
      }
      ref.read(cartProvider.notifier).clearCart();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ชำระเงินเรียบร้อย ตัดสต๊อกแล้ว!'), backgroundColor: Colors.green));
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ตะกร้าสินค้า POS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              TextButton.icon(onPressed: () { ref.read(cartProvider.notifier).clearCart(); Navigator.pop(context); }, icon: const Icon(Icons.delete_sweep, color: Colors.red), label: const Text('ล้างตะกร้า', style: TextStyle(color: Colors.red)))
            ],
          ),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          Expanded(
            child: cartItems.isEmpty
                ? Center(child: Text('ยังไม่มีสินค้าในตะกร้า', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[500] : Colors.grey)))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final tool = cartItems[index]['tool'] as ToolEntity;
                      final qty = cartItems[index]['quantity'] as int;
                      final price = isMechanicPrice ? tool.price * 0.9 : tool.price;
                      return ListTile(
                        title: Text(tool.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        subtitle: Text('${price.toStringAsFixed(0)} ฿ x $qty', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                        trailing: Text('${(price * qty).toStringAsFixed(0)} ฿', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      );
                    },
                  ),
          ),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ยอดชำระรวม', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              Text('฿${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, color: Colors.blueAccent, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: cartItems.isEmpty ? null : processCheckout,
              icon: const Icon(Icons.payments, color: Colors.white),
              label: const Text('ชำระเงิน และ ตัดสต๊อก', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 3. หน้า HomePage หลัก
// ==========================================
@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  final List<String> categories = const ['ทั้งหมด', 'ทั่วไป', 'เครื่องมือไฟฟ้า', 'อุปกรณ์ประปา', 'สีและเคมีภัณฑ์'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(filteredToolsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isMechanicPrice = ref.watch(isMechanicPriceProvider);
    final cartCount = ref.watch(cartProvider).values.fold(0, (sum, item) => sum + item);
    
    // 💡 ดึงสถานะ Theme ปัจจุบัน
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark 
              ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)], begin: Alignment.topLeft, end: Alignment.bottomRight) 
              : const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
          )
        ),
        title: const Text('ToolMaster Pro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          // 💡 ปุ่มสลับโหมด Dark Mode / Light Mode
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.yellowAccent),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          // ปุ่มตะกร้า
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart, color: Colors.white), onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const CartDialog())),
              if (cartCount > 0)
                Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))
            ],
          ),
          // ปุ่ม AI
          IconButton(icon: const Icon(Icons.bolt, color: Colors.white), onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const GroqChatDialog())),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                        decoration: InputDecoration(
                          hintText: 'ค้นหาชื่อ หรือ บาร์โค้ด...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.blueAccent),
                            onPressed: () async {
                              var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()));
                              if (res is String && res != '-1') ref.read(searchQueryProvider.notifier).state = res; 
                            },
                          ),
                          filled: true, fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Text('ราคาช่าง', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        Switch(value: isMechanicPrice, onChanged: (val) => ref.read(isMechanicPriceProvider.notifier).state = val, activeColor: Colors.blueAccent),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.black87), fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedColor: Colors.blueAccent,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = cat,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: tools.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[600]), const SizedBox(height: 16), Text('ไม่พบสินค้าในหมวดหมู่นี้', style: TextStyle(fontSize: 18, color: Colors.grey[500]))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tools.length,
                    itemBuilder: (context, index) {
                      final tool = tools[index];
                      final outOfStock = tool.quantity == 0;
                      final isLowStock = tool.quantity > 0 && tool.quantity <= 5;
                      final displayPrice = isMechanicPrice ? tool.price * 0.9 : tool.price;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isLowStock ? Colors.orange.withOpacity(0.5) : Colors.transparent, width: 2)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.router.push(ToolDetailRoute(tool: tool)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'tool-image-${tool.name}',
                                  child: Container(
                                    width: 70, height: 70,
                                    decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.blue[50], borderRadius: BorderRadius.circular(12), image: tool.imageBytes != null ? DecorationImage(image: MemoryImage(tool.imageBytes!), fit: BoxFit.cover) : null),
                                    child: tool.imageBytes == null ? const Icon(Icons.build, color: Colors.blueAccent) : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tool.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                                            child: Text(tool.category, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.black54)),
                                          ),
                                          const SizedBox(width: 8),
                                          if (outOfStock) const Text('หมด!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))
                                          else if (isLowStock) Text('เหลือ ${tool.quantity} ชิ้น', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))
                                          else Text('คลัง: ${tool.quantity}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('฿${displayPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, color: isMechanicPrice ? Colors.redAccent : Colors.green, fontWeight: FontWeight.w800)),
                                    if (isMechanicPrice) Text('จาก ฿${tool.price}', style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                                    const SizedBox(height: 4),
                                    IconButton(
                                      icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                      onPressed: outOfStock ? null : () {
                                        ref.read(cartProvider.notifier).addToCart(tool.key);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่ม ${tool.name} ลงตะกร้าแล้ว!'), duration: const Duration(seconds: 1)));
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.router.push(const AddToolRoute()),
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มสินค้า', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}