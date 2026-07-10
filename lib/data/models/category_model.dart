import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lystra/domain/models/category.dart';

part 'category_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorHex,
    this.iconCode,
  });

  final String id;
  final String name;
  final String colorHex;
  final String? iconCode;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CategoryModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Map<String, dynamic> toFirestore() => toJson()..remove('id');

  Category toDomain() => Category(
        id: id,
        name: name,
        colorHex: colorHex,
        iconCode: iconCode,
      );

  factory CategoryModel.fromDomain(Category c) => CategoryModel(
        id: c.id,
        name: c.name,
        colorHex: c.colorHex,
        iconCode: c.iconCode,
      );
}
