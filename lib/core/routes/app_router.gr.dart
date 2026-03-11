// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AddToolRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AddToolPage(),
      );
    },
    EditToolRoute.name: (routeData) {
      final args = routeData.argsAs<EditToolRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditToolPage(
          key: args.key,
          tool: args.tool,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    ToolDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ToolDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ToolDetailPage(
          key: args.key,
          tool: args.tool,
        ),
      );
    },
  };
}

/// generated route for
/// [AddToolPage]
class AddToolRoute extends PageRouteInfo<void> {
  const AddToolRoute({List<PageRouteInfo>? children})
      : super(
          AddToolRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddToolRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [EditToolPage]
class EditToolRoute extends PageRouteInfo<EditToolRouteArgs> {
  EditToolRoute({
    Key? key,
    required ToolEntity tool,
    List<PageRouteInfo>? children,
  }) : super(
          EditToolRoute.name,
          args: EditToolRouteArgs(
            key: key,
            tool: tool,
          ),
          initialChildren: children,
        );

  static const String name = 'EditToolRoute';

  static const PageInfo<EditToolRouteArgs> page =
      PageInfo<EditToolRouteArgs>(name);
}

class EditToolRouteArgs {
  const EditToolRouteArgs({
    this.key,
    required this.tool,
  });

  final Key? key;

  final ToolEntity tool;

  @override
  String toString() {
    return 'EditToolRouteArgs{key: $key, tool: $tool}';
  }
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ToolDetailPage]
class ToolDetailRoute extends PageRouteInfo<ToolDetailRouteArgs> {
  ToolDetailRoute({
    Key? key,
    required ToolEntity tool,
    List<PageRouteInfo>? children,
  }) : super(
          ToolDetailRoute.name,
          args: ToolDetailRouteArgs(
            key: key,
            tool: tool,
          ),
          initialChildren: children,
        );

  static const String name = 'ToolDetailRoute';

  static const PageInfo<ToolDetailRouteArgs> page =
      PageInfo<ToolDetailRouteArgs>(name);
}

class ToolDetailRouteArgs {
  const ToolDetailRouteArgs({
    this.key,
    required this.tool,
  });

  final Key? key;

  final ToolEntity tool;

  @override
  String toString() {
    return 'ToolDetailRouteArgs{key: $key, tool: $tool}';
  }
}
