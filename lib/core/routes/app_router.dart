import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:toolmaster_pro/data/models/tool_entity.dart';
import 'package:toolmaster_pro/presentation/pages/edit_tool_page.dart';
import 'package:toolmaster_pro/presentation/pages/home_page.dart';
import 'package:toolmaster_pro/presentation/pages/tool_detail_page.dart';
import 'package:toolmaster_pro/presentation/pages/add_tool_page.dart'; // <-- เพิ่มบรรทัดนี้ครับ

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: ToolDetailRoute.page),
    AutoRoute(page: AddToolRoute.page), 
    AutoRoute(page: EditToolRoute.page),
  ];
}