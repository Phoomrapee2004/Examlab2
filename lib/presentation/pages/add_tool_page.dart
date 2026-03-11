// lib/presentation/pages/add_tool_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../providers/tool_provider.dart';
import '../../data/models/tool_entity.dart';

@RoutePage()
class AddToolPage extends ConsumerStatefulWidget {
  const AddToolPage({super.key});

  @override
  ConsumerState<AddToolPage> createState() => _AddToolPageState();
}

class _AddToolPageState extends ConsumerState<AddToolPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController(text: '0'); // เพิ่มช่องใส่จำนวน
  
  Uint8List? _selectedImage;
  
  // 💡 กำหนดตัวแปรหมวดหมู่
  String _selectedCategory = 'ทั่วไป';
  final List<String> _categories = ['ทั่วไป', 'เครื่องมือไฟฟ้า', 'อุปกรณ์ประปา', 'สีและเคมีภัณฑ์'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  void _saveTool() {
    if (_formKey.currentState!.validate()) {
      final newTool = ToolEntity(
        barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descController.text.isEmpty ? 'ไม่มีรายละเอียด' : _descController.text,
        imageBytes: _selectedImage,
        quantity: int.parse(_quantityController.text), // 💡 บันทึกจำนวน
        category: _selectedCategory,                   // 💡 บันทึกหมวดหมู่
      );
      ref.read(toolProvider.notifier).addTool(newTool);
      context.router.pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('เพิ่มอุปกรณ์ใหม่', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.memory(_selectedImage!, fit: BoxFit.cover))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, size: 50, color: Colors.blue[300]),
                              const SizedBox(height: 12),
                              const Text('อัปโหลดรูปภาพสินค้า', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('ข้อมูลทั่วไป', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'รหัสบาร์โค้ด',
                        prefixIcon: const Icon(Icons.qr_code),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 55, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(16)),
                    child: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                      onPressed: () async {
                        var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()));
                        if (res is String && res != '-1') setState(() => _barcodeController.text = res);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'ชื่ออุปกรณ์', prefixIcon: const Icon(Icons.handyman), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Colors.grey[50]),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกชื่ออุปกรณ์' : null,
              ),
              const SizedBox(height: 16),
              
              // 💡 เพิ่ม Dropdown เลือกหมวดหมู่
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'หมวดหมู่สินค้า', prefixIcon: const Icon(Icons.category), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Colors.grey[50]),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'ราคา (บาท)', prefixIcon: const Icon(Icons.attach_money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Colors.grey[50]),
                      validator: (val) => val!.isEmpty ? 'กรุณากรอกราคา' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'จำนวนเริ่มต้น', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Colors.grey[50]),
                      validator: (val) => val!.isEmpty ? 'ระบุ' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descController, maxLines: 3,
                decoration: InputDecoration(labelText: 'รายละเอียดสินค้า', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Colors.grey[50]),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2),
                  onPressed: _saveTool,
                  child: const Text('บันทึกข้อมูลสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}