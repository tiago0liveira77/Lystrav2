import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/services/list_templates_data.dart';
import 'package:lystra/domain/models/category.dart';
import 'package:lystra/domain/models/item.dart';

class ListTemplateService {
  ListTemplateService({
    required CategoryRepository categoryRepository,
    required ItemRepository itemRepository,
    required ListEntryRepository entryRepository,
  })  : _categoryRepo = categoryRepository,
        _itemRepo = itemRepository,
        _entryRepo = entryRepository;

  final CategoryRepository _categoryRepo;
  final ItemRepository _itemRepo;
  final ListEntryRepository _entryRepo;

  /// Creates categories and items from a template (skipping existing ones by
  /// name), then adds all items as entries to [listId].
  /// Returns the number of NEW items added to the user's catalog.
  Future<int> applyTemplate(
      String uid, String listId, ListTemplate template) async {
    final existingItems = await _itemRepo.getItems(uid);
    final existingCats = await _categoryRepo.getCategories(uid);

    final itemByName = <String, Item>{
      for (final i in existingItems) i.name.toLowerCase(): i,
    };
    final catByName = <String, Category>{
      for (final c in existingCats) c.name.toLowerCase(): c,
    };

    var newItemCount = 0;

    for (final templateCat in template.categories) {
      final catKey = templateCat.name.toLowerCase();
      Category category;
      if (catByName.containsKey(catKey)) {
        category = catByName[catKey]!;
      } else {
        category = await _categoryRepo.createCategory(
            uid, templateCat.name, templateCat.colorHex);
        catByName[catKey] = category;
      }

      for (final templateItem in templateCat.items) {
        final itemKey = templateItem.name.toLowerCase();
        Item item;
        if (itemByName.containsKey(itemKey)) {
          item = itemByName[itemKey]!;
        } else {
          item = await _itemRepo.createItem(
            uid,
            templateItem.name,
            category.id,
            unit: templateItem.unit,
            emoji: templateItem.emoji,
          );
          itemByName[itemKey] = item;
          newItemCount++;
        }

        try {
          await _entryRepo.addEntry(uid, listId, item.id);
        } catch (_) {
          // Entry already exists in list — continue
        }
      }
    }

    return newItemCount;
  }
}
