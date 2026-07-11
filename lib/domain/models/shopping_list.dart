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
    // Non-null → household list at households/{householdId}/lists
    // Null → personal list at users/{uid}/lists
    String? householdId,
  }) = _ShoppingList;
}
