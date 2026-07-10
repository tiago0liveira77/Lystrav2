import 'package:flutter_test/flutter_test.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/purchase_record_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/domain/models/app_user.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/list_entry.dart';
import 'package:lystra/domain/models/purchase_record.dart';
import 'package:lystra/domain/models/shopping_list.dart';
import 'package:lystra/ui/features/shopping/view_models/shopping_view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'shopping_view_model_test.mocks.dart';

@GenerateMocks([
  ListEntryRepository,
  ShoppingListRepository,
  ItemRepository,
  AuthRepository,
  PurchaseRecordRepository,
  CategoryRepository,
])
void main() {
  late MockListEntryRepository mockEntryRepo;
  late MockShoppingListRepository mockListRepo;
  late MockItemRepository mockItemRepo;
  late MockAuthRepository mockAuthRepo;
  late MockPurchaseRecordRepository mockRecordRepo;
  late MockCategoryRepository mockCategoryRepo;
  late ShoppingViewModel vm;

  const uid = 'user-1';
  const listId = 'list-1';
  final fakeUser = AppUser(uid: uid, email: 'test@test.com');
  final now = DateTime.now();

  final fakeList =
      ShoppingList(id: listId, name: 'Compras', ownerId: uid, createdAt: now);
  final fakeItem = Item(
      id: 'item-1', name: 'Leite', categoryId: 'dairy', unit: 'L', ownerId: uid);
  final fakeEntry = ListEntry(
      id: 'entry-1', listId: listId, itemId: 'item-1', addedAt: now);

  setUp(() {
    mockEntryRepo = MockListEntryRepository();
    mockListRepo = MockShoppingListRepository();
    mockItemRepo = MockItemRepository();
    mockAuthRepo = MockAuthRepository();
    mockRecordRepo = MockPurchaseRecordRepository();
    mockCategoryRepo = MockCategoryRepository();

    when(mockAuthRepo.currentUser).thenReturn(fakeUser);
    when(mockCategoryRepo.getCategories(uid)).thenAnswer((_) async => []);

    vm = ShoppingViewModel(
      listId: listId,
      entryRepository: mockEntryRepo,
      listRepository: mockListRepo,
      itemRepository: mockItemRepo,
      authRepository: mockAuthRepo,
      purchaseRecordRepository: mockRecordRepo,
      categoryRepository: mockCategoryRepo,
    );
  });

  tearDown(() => vm.dispose());

  test('initial state is loading=true', () {
    expect(vm.isLoading, isTrue);
    expect(vm.progress, 0.0);
  });

  test('load populates entries and items', () async {
    when(mockListRepo.getLists(uid)).thenAnswer((_) async => [fakeList]);
    when(mockEntryRepo.getEntries(uid, listId))
        .thenAnswer((_) async => [fakeEntry]);
    when(mockItemRepo.getItems(uid)).thenAnswer((_) async => [fakeItem]);

    await vm.load();

    expect(vm.isLoading, isFalse);
    expect(vm.uncheckedEntries.length, 1);
    expect(vm.checkedEntries, isEmpty);
    expect(vm.progress, 0.0);
  });

  test('toggleEntry performs optimistic update', () async {
    when(mockListRepo.getLists(uid)).thenAnswer((_) async => [fakeList]);
    when(mockEntryRepo.getEntries(uid, listId))
        .thenAnswer((_) async => [fakeEntry]);
    when(mockItemRepo.getItems(uid)).thenAnswer((_) async => [fakeItem]);
    when(mockEntryRepo.toggleEntry(uid, listId, 'entry-1'))
        .thenAnswer((_) async {});

    await vm.load();
    await vm.toggleEntry('entry-1');

    expect(vm.checkedEntries.length, 1);
    expect(vm.progress, 1.0);
    expect(vm.isComplete, isTrue);
  });

  test('finishShopping creates record and resets entries (list stays active)',
      () async {
    when(mockListRepo.getLists(uid)).thenAnswer((_) async => [fakeList]);
    final checkedEntry = fakeEntry.copyWith(isChecked: true, checkedAt: now);
    when(mockEntryRepo.getEntries(uid, listId))
        .thenAnswer((_) async => [checkedEntry]);
    when(mockItemRepo.getItems(uid)).thenAnswer((_) async => [fakeItem]);

    await vm.load();

    final savedRecord = PurchaseRecord(
      id: 'record-1',
      listId: listId,
      listName: 'Compras',
      completedAt: now,
      ownerId: uid,
    );
    when(mockRecordRepo.createRecord(uid, any))
        .thenAnswer((_) async => savedRecord);
    when(mockEntryRepo.resetEntries(uid, listId)).thenAnswer((_) async {});

    final success = await vm.finishShopping();

    expect(success, isTrue);
    verify(mockRecordRepo.createRecord(uid, any)).called(1);
    verify(mockEntryRepo.resetEntries(uid, listId)).called(1);
    // List is NOT archived
    verifyNever(mockListRepo.archiveList(any, any));
    // Entries are unchecked in local state
    expect(vm.checkedEntries, isEmpty);
  });
}
