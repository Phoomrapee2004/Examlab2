import 'package:freezed_annotation/freezed_annotation.dart';

part 'tool_model.freezed.dart';
part 'tool_model.g.dart';

@freezed
class ToolModel with _$ToolModel {
  const factory ToolModel({
    required int id,
    required String name,
    required double price,
  }) = _ToolModel;

  factory ToolModel.fromJson(Map<String, dynamic> json) => _$ToolModelFromJson(json);
}