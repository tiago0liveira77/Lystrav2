import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/purchase_record_repository.dart';
import 'package:lystra/domain/models/purchase_record.dart';

enum HistoryViewState { initial, loading, loaded, error }

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({
    required PurchaseRecordRepository recordRepository,
    required AuthRepository authRepository,
  })  : _recordRepository = recordRepository,
        _authRepository = authRepository;

  final PurchaseRecordRepository _recordRepository;
  final AuthRepository _authRepository;

  List<PurchaseRecord> _records = [];
  List<PurchaseRecord> get records => List.unmodifiable(_records);

  HistoryViewState _state = HistoryViewState.initial;
  HistoryViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? get _uid => _authRepository.currentUser?.uid;

  static const _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  String monthLabel(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  // Ordered list of month keys (most recent first)
  List<String> get monthKeys {
    final seen = <String>{};
    return _records
        .map((r) => monthLabel(r.completedAt))
        .where(seen.add)
        .toList();
  }

  List<PurchaseRecord> recordsForMonth(String monthKey) =>
      _records.where((r) => monthLabel(r.completedAt) == monthKey).toList();

  Future<void> loadRecords() async {
    final uid = _uid;
    if (uid == null) return;
    _setState(HistoryViewState.loading);
    try {
      _records = await _recordRepository.getRecords(uid);
      _setState(HistoryViewState.loaded);
    } catch (_) {
      _errorMessage = 'Erro ao carregar histórico.';
      _setState(HistoryViewState.error);
    }
  }

  void _setState(HistoryViewState s) {
    _state = s;
    notifyListeners();
  }
}
