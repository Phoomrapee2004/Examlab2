// lib/presentation/pages/edit_tool_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/tool_provider.dart';
import '../../data/models/tool_entity.dart';

@RoutePage()
class EditToolPage extends ConsumerStatefulWidget {
  final ToolEntity tool;
  const EditToolPage({super.key, required this.tool});

  @override
  ConsumerState<EditToolPage> createState() => _EditToolPageState();
}

class _EditToolPageState extends ConsumerState<EditToolPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _barcodeController;
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tool.name);
    _priceController = TextEditingController(text: widget.tool.price.toString());
    _descController = TextEditingController(text: widget.tool.description);
    _barcodeController = TextEditingController(text: widget.tool.barcode ?? '');
    _selectedImage = widget.tool.imageBytes;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _selectedImage = bytes);
    }
  }

  void _updateTool() {
    if (_formKey.currentState!.validate()) {
      final updatedTool = ToolEntity(
        barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descController.text,
        imageBytes: _selectedImage,
        quantity: widget.tool.quantity, // 💡 แก้บั๊ก: ต้องส่ง quantity เดิมกลับไป ไม่งั้นของเหลือ 0 ทันที
      );
      
      ref.read(toolProvider.notifier).updateTool(widget.tool.key, updatedTool);
      context.router.popUntilRoot(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลสินค้า', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50], 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2)
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.memory(_selectedImage!, fit: BoxFit.cover))
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.blueAccent), SizedBox(height: 8), Text('แตะเพื่อเปลี่ยนรูปภาพ', style: TextStyle(color: Colors.blueAccent))]),
                ),
              ),
              const SizedBox(height: 30),
              
              const Text('ข้อมูลสินค้า', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _barcodeController, 
                decoration: InputDecoration(labelText: 'บาร์โค้ด', prefixIcon: const Icon(Icons.qr_code), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController, 
                decoration: InputDecoration(labelText: 'ชื่ออุปกรณ์', prefixIcon: const Icon(Icons.handyman), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
                validator: (val) => val!.isEmpty ? 'กรุณากรอกชื่อ' : null
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController, 
                decoration: InputDecoration(labelText: 'ราคา (บาท)', prefixIcon: const Icon(Icons.attach_money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
                keyboardType: TextInputType.number
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController, 
                decoration: InputDecoration(labelText: 'รายละเอียด', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
                maxLines: 4
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity, 
                height: 55, 
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _updateTool, 
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('บันทึกการแก้ไข', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                )
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}