import 'package:flutter_test/flutter_test.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/purchase_record_repository.dart';
import 'package:lystra/domain/models/app_user.dart';
import 'package:lystra/domain/models/purchase_record.dart';
import 'package:lystra/ui/features/history/view_models/history_view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'history_view_model_test.mocks.dart';

@GenerateMocks([PurchaseRecordRepository, AuthRepository])
void main() {
  late MockPurchaseRecordRepository mockRecordRepo;
  late MockAuthRepository mockAuthRepo;
  late HistoryViewModel vm;

  const uid = 'user-1';
  final fakeUser = AppUser(uid: uid, email: 'test@test.com');

  PurchaseRecord makeRecord(String id, DateTime date) => PurchaseRecord(
        id: id,
        listId: 'list-$id',
        listName: 'Lista $id',
        completedAt: date,
        ownerId: uid,
      );

  setUp(() {
    mockRecordRepo = MockPurchaseRecordRepository();
    mockAuthRepo = MockAuthRepository();
    when(mockAuthRepo.currentUser).thenReturn(fakeUser);
    vm = HistoryViewModel(
      recordRepository: mockRecordRepo,
      authRepository: mockAuthRepo,
    );
  });

  tearDown(() => vm.dispose());

  test('initial state is initial', () {
    expect(vm.state, HistoryViewState.initial);
    expect(vm.records, isEmpty);
  });

  test('loadRecords transitions to loaded', () async {
    final records = [
      makeRecord('1', DateTime(2026, 7, 10)),
      makeRecord('2', DateTime(2026, 7, 5)),
    ];
    when(mockRecordRepo.getRecords(uid)).thenAnswer((_) async => records);

    await vm.loadRecords();

    expect(vm.state, HistoryViewState.loaded);
    expect(vm.records.length, 2);
  });

  test('loadRecords transitions to error on exception', () async {
    when(mockRecordRepo.getRecords(uid)).thenThrow(Exception('error'));

    await vm.loadRecords();

    expect(vm.state, HistoryViewState.error);
    expect(vm.errorMessage, isNotNull);
  });

  test('monthKeys groups records correctly', () async {
    final records = [
      makeRecord('1', DateTime(2026, 7, 10)),
      makeRecord('2', DateTime(2026, 7, 5)),
      makeRecord('3', DateTime(2026, 6, 20)),
    ];
    when(mockRecordRepo.getRecords(uid)).thenAnswer((_) async => records);

    await vm.loadRecords();

    expect(vm.monthKeys.length, 2);
    expect(vm.monthKeys.first, 'Julho 2026');
    expect(vm.monthKeys.last, 'Junho 2026');
  });

  test('recordsForMonth returns only matching records', () async {
    final records = [
      makeRecord('1', DateTime(2026, 7, 10)),
      makeRecord('2', DateTime(2026, 6, 20)),
    ];
    when(mockRecordRepo.getRecords(uid)).thenAnswer((_) async => records);

    await vm.loadRecords();

    expect(vm.recordsForMonth('Julho 2026').length, 1);
    expect(vm.recordsForMonth('Junho 2026').length, 1);
    expect(vm.recordsForMonth('Maio 2026'), isEmpty);
  });
}
