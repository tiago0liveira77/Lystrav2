import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lystra/domain/models/shopping_list.dart';

part 'shopping_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingListModel {
  const ShoppingListModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.memberIds = const [],
    required this.createdAt,
    this.updatedAt,
    this.isArchived = false,
    this.householdId,
  });

  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
  final DateTime? updatedAt;
  final bool isArchived;
  final String? householdId;

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListModelFromJson(json);

  factory ShoppingListModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShoppingListModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => _$ShoppingListModelToJson(this);

  Map<String, dynamic> toFirestore() => toJson()..remove('id');

  ShoppingList toDomain() => ShoppingList(
        id: id,
        name: name,
        ownerId: ownerId,
        memberIds: memberIds,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isArchived: isArchived,
        householdId: householdId,
      );

  factory ShoppingListModel.fromDomain(ShoppingList list) => ShoppingListModel(
        id: list.id,
        name: list.name,
        ownerId: list.ownerId,
        memberIds: list.memberIds,
        createdAt: list.createdAt,
        updatedAt: list.updatedAt,
        isArchived: list.isArchived,
        householdId: list.householdId,
      );

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static dynamic _dateTimeToJson(DateTime dt) => Timestamp.fromDate(dt);

  static DateTime? _nullableDateTimeFromJson(dynamic value) {
    if (value == null) return null;
    return _dateTimeFromJson(value);
  }

  static dynamic _nullableDateTimeToJson(DateTime? dt) =>
      dt == null ? null : Timestamp.fromDate(dt);
}
