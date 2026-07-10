import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_entry.freezed.dart';

@freezed
abstract class ListEntry with _$ListEntry {
  const factory ListEntry({
    required String id,
    required String listId,
    required String itemId,
    @Default(1.0) double quantity,
    @Default(false) bool isChecked,
    required DateTime addedAt,
    DateTime? checkedAt,
    String? addedById,
  }) = _ListEntry;
}
