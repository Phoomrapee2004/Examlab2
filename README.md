# toolmaster_pro

A new Flutter project.

## Getting Started
run app flutter run -d chrome --web-port 8080 --web-browser-flag "--disable-web-security"
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 🛠️ ToolMaster Pro

แอปพลิเคชันระบบจัดการคลังสินค้าและจุดขาย (POS) สำหรับร้านฮาร์ดแวร์และอุปกรณ์ช่าง ครบจบในแอปเดียว พร้อมระบบผู้ช่วย AI อัจฉริยะที่ช่วยแนะนำอุปกรณ์ช่างให้ลูกค้าได้อย่างรวดเร็ว

## ✨ ฟีเจอร์หลัก (Key Features)
* 📦 **ระบบจัดการสต๊อกออฟไลน์:** เพิ่ม ลบ แก้ไข สินค้าและจำนวนสต๊อกได้รวดเร็ว (ทำงานแบบ Offline-first)
* 🛒 **ระบบ POS และตะกร้าสินค้า:** กดหยิบสินค้าลงตะกร้า คำนวณยอดรวม ตัดสต๊อกอัตโนมัติ พร้อมรองรับ "ราคาช่าง" (ส่วนลด 10%)
* 🤖 **Groq AI Assistant:** ผู้ช่วยช่างอัจฉริยะ (Powered by LLaMA 3.1) ให้คำปรึกษาและแนะนำเครื่องมือช่าง
* 📷 **สแกนบาร์โค้ด:** ค้นหาหรือเพิ่มสินค้าเข้าระบบอย่างรวดเร็วด้วยกล้องมือถือ
* 🏷️ **หมวดหมู่สินค้า:** ระบบคัดกรองสินค้าตามประเภท (ไฟฟ้า, ประปา, สี ฯลฯ)
* 🌙 **Dark Mode:** รองรับโหมดมืดเพื่อถนอมสายตาและประหยัดแบตเตอรี่

---

 🏗️ โครงสร้างสถาปัตยกรรม (Architecture)

โปรเจกต์นี้ใช้สถาปัตยกรรมแบบ **Layered Architecture** ร่วมกับการจัดการสถานะ (State Management) แบบ Reactive

📂 โครงสร้างโฟลเดอร์ (Folder Structure)
```text
lib/
 ├── core/              # การตั้งค่าหลักของระบบ (Core Configuration)
 │    ├── di/           # Dependency Injection (GetIt)
 │    └── routes/       # ระบบนำทาง (AutoRoute)
 ├── data/              # จัดการข้อมูลและการเชื่อมต่อภายนอก (Data Layer)
 │    ├── models/       # โครงสร้างข้อมูล (Hive Objects เช่น ToolEntity)
 │    └── services/     # เชื่อมต่อ API (เช่น AIAssistantService / Dio)
 ├── presentation/      # ส่วนแสดงผลและ UI (Presentation Layer)
 │    ├── pages/        # หน้าจอต่างๆ (Home, AddTool, EditTool, Detail)
 │    └── providers/    # จัดการ State และ Business Logic (Riverpod)
 └── main.dart          # จุดเริ่มต้นการทำงานของแอปพลิเคชัน
