// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingListModel _$ShoppingListModelFromJson(Map<String, dynamic> json) =>
    ShoppingListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: ShoppingListModel._dateTimeFromJson(json['createdAt']),
      updatedAt: ShoppingListModel._nullableDateTimeFromJson(json['updatedAt']),
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$ShoppingListModelToJson(ShoppingListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'memberIds': instance.memberIds,
      'createdAt': ShoppingListModel._dateTimeToJson(instance.createdAt),
      'updatedAt':
          ShoppingListModel._nullableDateTimeToJson(instance.updatedAt),
      'isArchived': instance.isArchived,
    };
