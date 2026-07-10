import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lystra/domain/models/item.dart';

part 'item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ItemModel {
  const ItemModel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.unit = 'un',
    this.ownerId,
  });

  final String id;
  final String name;
  final String categoryId;
  final String unit;
  final String? ownerId;

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  factory ItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ItemModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);

  Map<String, dynamic> toFirestore() => toJson()..remove('id');

  Item toDomain() => Item(
        id: id,
        name: name,
        categoryId: categoryId,
        unit: unit,
        ownerId: ownerId,
      );

  factory ItemModel.fromDomain(Item item) => ItemModel(
        id: item.id,
        name: item.name,
        categoryId: item.categoryId,
        unit: item.unit,
        ownerId: item.ownerId,
      );
}
