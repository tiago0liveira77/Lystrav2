import 'package:flutter_test/flutter_test.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/domain/models/app_user.dart';
import 'package:lystra/domain/models/shopping_list.dart';
import 'package:lystra/ui/features/lists/view_models/lists_view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'lists_view_model_test.mocks.dart';

@GenerateMocks([ShoppingListRepository, AuthRepository, ListEntryRepository])
void main() {
  late MockShoppingListRepository mockListRepo;
  late MockAuthRepository mockAuthRepo;
  late MockListEntryRepository mockEntryRepo;
  late ListsViewModel vm;

  const uid = 'user-1';
  final fakeUser = AppUser(uid: uid, email: 'test@test.com');

  setUp(() {
    mockListRepo = MockShoppingListRepository();
    mockAuthRepo = MockAuthRepository();
    mockEntryRepo = MockListEntryRepository();
    when(mockAuthRepo.currentUser).thenReturn(fakeUser);
    when(mockEntryRepo.getEntries(uid, any)).thenAnswer((_) async => []);
    vm = ListsViewModel(
      listRepository: mockListRepo,
      authRepository: mockAuthRepo,
      entryRepository: mockEntryRepo,
    );
  });

  tearDown(() => vm.dispose());

  test('initial state is initial', () {
    expect(vm.state, ViewState.initial);
    expect(vm.lists, isEmpty);
  });

  test('loadLists transitions to loaded with results', () async {
    final lists = [
      ShoppingList(id: '1', name: 'Lidl', ownerId: uid, createdAt: DateTime.now()),
    ];
    when(mockListRepo.getLists(uid)).thenAnswer((_) async => lists);

    await vm.loadLists();

    expect(vm.state, ViewState.loaded);
    expect(vm.lists.length, 1);
    expect(vm.lists.first.name, 'Lidl');
  });

  test('loadLists transitions to error on exception', () async {
    when(mockListRepo.getLists(uid)).thenThrow(Exception('network error'));

    await vm.loadLists();

    expect(vm.state, ViewState.error);
    expect(vm.errorMessage, isNotNull);
  });

  test('createList adds list to the top', () async {
    when(mockListRepo.getLists(uid)).thenAnswer((_) async => []);
    await vm.loadLists();

    final newList = ShoppingList(
        id: '2', name: 'Continente', ownerId: uid, createdAt: DateTime.now());
    when(mockListRepo.createList(uid, 'Continente'))
        .thenAnswer((_) async => newList);

    await vm.createList('Continente');

    expect(vm.lists.first.name, 'Continente');
  });

  test('deleteList removes list from state', () async {
    final list = ShoppingList(
        id: '1', name: 'Lidl', ownerId: uid, createdAt: DateTime.now());
    when(mockListRepo.getLists(uid)).thenAnswer((_) async => [list]);
    await vm.loadLists();

    when(mockListRepo.deleteList(uid, '1')).thenAnswer((_) async {});
    await vm.deleteList('1');

    expect(vm.lists, isEmpty);
  });
}
