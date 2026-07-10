// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListEntryModel _$ListEntryModelFromJson(Map<String, dynamic> json) =>
    ListEntryModel(
      id: json['id'] as String,
      listId: json['listId'] as String,
      itemId: json['itemId'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      isChecked: json['isChecked'] as bool? ?? false,
      addedAt: ListEntryModel._dateTimeFromJson(json['addedAt']),
      checkedAt: ListEntryModel._nullableDateTimeFromJson(json['checkedAt']),
      addedById: json['addedById'] as String?,
    );

Map<String, dynamic> _$ListEntryModelToJson(ListEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listId': instance.listId,
      'itemId': instance.itemId,
      'quantity': instance.quantity,
      'isChecked': instance.isChecked,
      'addedAt': ListEntryModel._dateTimeToJson(instance.addedAt),
      'checkedAt': ListEntryModel._nullableDateTimeToJson(instance.checkedAt),
      'addedById': instance.addedById,
    };
