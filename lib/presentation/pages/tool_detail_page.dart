// lib/presentation/pages/tool_detail_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tool_entity.dart';
import '../../core/routes/app_router.dart';
import '../providers/tool_provider.dart';

@RoutePage()
class ToolDetailPage extends ConsumerStatefulWidget {
  final ToolEntity tool;
  const ToolDetailPage({super.key, required this.tool});

  @override
  ConsumerState<ToolDetailPage> createState() => _ToolDetailPageState();
}

class _ToolDetailPageState extends ConsumerState<ToolDetailPage> {
  late int currentQuantity;
  bool isStockChanged = false; // ตัวแปรเช็คว่ามีการปรับเปลี่ยนตัวเลขหรือยัง

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.tool.quantity; 
  }

  // ฟังก์ชันแค่ปรับตัวเลขบนหน้าจอ (ยังไม่เซฟ)
  void _changeStock(int newQuantity) {
    if (newQuantity < 0) return; 
    
    setState(() {
      currentQuantity = newQuantity;
      // เช็คว่าเลขปัจจุบัน ตรงกับเลขในฐานข้อมูลไหม ถ้าไม่ตรงแปลว่ามีการเปลี่ยนแปลง
      isStockChanged = currentQuantity != widget.tool.quantity;
    });
  }

  // ฟังก์ชันกดบันทึกลงฐานข้อมูล
  void _saveStock() {
    final updatedTool = ToolEntity(
      name: widget.tool.name,
      description: widget.tool.description,
      price: widget.tool.price,
      imageBytes: widget.tool.imageBytes,
      barcode: widget.tool.barcode,
      quantity: currentQuantity, // อัปเดตจำนวนใหม่
    );

    ref.read(toolProvider.notifier).updateTool(widget.tool.key, updatedTool);
    
    setState(() {
      isStockChanged = false; // รีเซ็ตสถานะปุ่ม
    });

    // โชว์ข้อความแจ้งเตือนสวยๆ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('อัปเดตจำนวนสต๊อกเรียบร้อยแล้ว!'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = currentQuantity <= 5;
    final double totalValue = currentQuantity * widget.tool.price; // คำนวณมูลค่ารวม

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.blueAccent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.tool.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Hero(
                tag: 'tool-image-${widget.tool.name}',
                child: widget.tool.imageBytes != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(widget.tool.imageBytes!, fit: BoxFit.cover),
                          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Colors.black54, Colors.transparent]))),
                        ],
                      )
                    : Container(color: Colors.blueGrey, child: const Center(child: Icon(Icons.handyman, size: 100, color: Colors.white54))),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // โซนแสดงบาร์โค้ด (ถ้ามี)
                  if (widget.tool.barcode != null && widget.tool.barcode!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_2, size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text('บาร์โค้ด: ${widget.tool.barcode}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: currentQuantity == 0 ? Colors.red[50] : (isLowStock ? Colors.orange[50] : Colors.blue[50]), 
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          currentQuantity == 0 ? 'สินค้าหมด' : (isLowStock ? 'สินค้าใกล้หมด' : 'พร้อมจำหน่าย'), 
                          style: TextStyle(
                            color: currentQuantity == 0 ? Colors.redAccent : (isLowStock ? Colors.orange[800] : Colors.blueAccent), 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      Text('฿${widget.tool.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  
                  const Divider(height: 30),
                  
                  // 📦 โซนจัดการสต๊อกสินค้า (ปรับปรุงใหม่)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('จำนวนในคลัง', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: currentQuantity > 0 ? () => _changeStock(currentQuantity - 1) : null,
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.redAccent,
                                  iconSize: 32,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('$currentQuantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  onPressed: () => _changeStock(currentQuantity + 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.green,
                                  iconSize: 32,
                                ),
                              ],
                            )
                          ],
                        ),
                        // ปุ่มบันทึก จะแสดงก็ต่อเมื่อมีการบวก/ลบเลข
                        if (isStockChanged) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _saveStock,
                              icon: const Icon(Icons.save),
                              label: const Text('บันทึกการเปลี่ยนแปลงสต๊อก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // แสดงมูลค่ารวม
                  Text('มูลค่าสินค้ารวมในคลัง: ฿${totalValue.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold)),

                  const SizedBox(height: 30),
                  const Text('รายละเอียดสินค้า', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text(widget.tool.description, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black54)),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      label: const Text('แก้ไขข้อมูลสินค้า', style: TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      onPressed: () {
                         context.router.push(EditToolRoute(tool: widget.tool));
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}