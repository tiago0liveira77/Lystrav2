import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lystra/domain/models/list_entry.dart';

part 'list_entry_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ListEntryModel {
  const ListEntryModel({
    required this.id,
    required this.listId,
    required this.itemId,
    this.quantity = 1.0,
    this.isChecked = false,
    required this.addedAt,
    this.checkedAt,
    this.addedById,
  });

  final String id;
  final String listId;
  final String itemId;
  final double quantity;
  final bool isChecked;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime addedAt;
  @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
  final DateTime? checkedAt;
  final String? addedById;

  factory ListEntryModel.fromJson(Map<String, dynamic> json) =>
      _$ListEntryModelFromJson(json);

  factory ListEntryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ListEntryModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => _$ListEntryModelToJson(this);

  Map<String, dynamic> toFirestore() => toJson()..remove('id');

  ListEntry toDomain() => ListEntry(
        id: id,
        listId: listId,
        itemId: itemId,
        quantity: quantity,
        isChecked: isChecked,
        addedAt: addedAt,
        checkedAt: checkedAt,
        addedById: addedById,
      );

  factory ListEntryModel.fromDomain(ListEntry entry) => ListEntryModel(
        id: entry.id,
        listId: entry.listId,
        itemId: entry.itemId,
        quantity: entry.quantity,
        isChecked: entry.isChecked,
        addedAt: entry.addedAt,
        checkedAt: entry.checkedAt,
        addedById: entry.addedById,
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
