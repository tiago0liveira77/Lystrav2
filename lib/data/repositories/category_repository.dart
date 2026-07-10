import 'package:lystra/data/models/category_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/category.dart';

class CategoryRepository {
  CategoryRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  List<Category>? _cache;

  String _path(String uid) => 'users/$uid/categories';

  Future<List<Category>> getCategories(String uid) async {
    if (_cache != null) return _cache!;
    final snapshot = await _firestore.getCollection(_path(uid));
    _cache = snapshot.docs
        .map((d) => CategoryModel.fromFirestore(d).toDomain())
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }

  Future<Category> createCategory(String uid, String name, String colorHex,
      {String? iconCode}) async {
    final ref = await _firestore.addDoc(_path(uid), {
      'name': name.trim(),
      'colorHex': colorHex,
      if (iconCode != null) 'iconCode': iconCode,
    });
    final category = Category(
      id: ref.id,
      name: name.trim(),
      colorHex: colorHex,
      iconCode: iconCode,
    );
    _cache?.add(category);
    return category;
  }

  Future<void> updateCategory(String uid, Category category) async {
    await _firestore.updateDoc(
      'users/$uid/categories/${category.id}',
      CategoryModel.fromDomain(category).toFirestore(),
    );
    _cache = _cache?.map((c) => c.id == category.id ? category : c).toList();
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    await _firestore.deleteDoc('users/$uid/categories/$categoryId');
    _cache?.removeWhere((c) => c.id == categoryId);
  }

  void invalidateCache() => _cache = null;
}
