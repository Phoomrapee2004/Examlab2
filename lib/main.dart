import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection.dart' as di; 
import 'core/routes/app_router.dart';

// 💡 1. สร้าง Provider สำหรับจัดการ Theme (ค่าเริ่มต้นเป็นโหมดสว่าง)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    print("Warning: Could not load .env file: $e");
  }

  await di.initDI(); 

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// 💡 2. เปลี่ยนเป็น ConsumerWidget เพื่อให้คอยฟังการเปลี่ยนสีได้
class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // 💡 ย้าย AppRouter มาไว้ตรงนี้ เพื่อไม่ให้แอปสร้างแผนที่ใหม่ทุกครั้งที่สลับโหมดมืด
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 3. ดึงสถานะ Theme ปัจจุบัน (โหมดมืด หรือ โหมดสว่าง)
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ToolMaster Pro',
      
      // 💡 4. สั่งให้แอปเปลี่ยนหน้าตาตาม Provider
      themeMode: themeMode, 
      
      // ☀️ 5. ตั้งค่าสีสำหรับ "โหมดสว่าง" (Light Mode)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      
      // 🌙 6. ตั้งค่าสีสำหรับ "โหมดมืด" (Dark Mode)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212), // สีพื้นหลังโทนเข้มดูพรีเมียม
        cardColor: const Color(0xFF1E1E1E), // สีการ์ดในโหมดมืด
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),
      ),
      
      routerConfig: _appRouter.config(),
    );
  }  
}