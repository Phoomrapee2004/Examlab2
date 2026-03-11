import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/tool_entity.dart';
import '../../data/services/ai_assistant_service.dart';
import '../../data/services/barcode_scanner_service.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // 1. Key-Value Storage (SharedPreferences)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // 2. Network (Dio)
  sl.registerLazySingleton(() => Dio());

  // 3. Offline Database (Hive)
  await Hive.initFlutter(); // เริ่มต้น Hive บน Mobile/Web
  
  // ตรวจสอบก่อน Register เพื่อป้องกัน Error กรณีมีการเรียกซ้ำ
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ToolEntityAdapter());
  }
  
  // *** สำคัญ: ชื่อ Box ต้องตรงกับที่เรียกใน Service ***
  final toolBox = await Hive.openBox<ToolEntity>('tools_box'); 
  sl.registerSingleton<Box<ToolEntity>>(toolBox);

  // 4. Register Services
  sl.registerLazySingleton<AIAssistantService>(() => AIAssistantService());
  sl.registerLazySingleton(() => BarcodeScannerService());
}