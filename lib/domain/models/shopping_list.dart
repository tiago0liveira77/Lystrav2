import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_list.freezed.dart';

@freezed
abstract class ShoppingList with _$ShoppingList {
  const factory ShoppingList({
    required String id,
    required String name,
    required String ownerId,
    @Default([]) List<String> memberIds,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isArchived,
  }) = _ShoppingList;
}
