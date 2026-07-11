import 'package:freezed_annotation/freezed_annotation.dart';

part 'household.freezed.dart';

@freezed
abstract class Household with _$Household {
  const factory Household({
    required String id,
    required String name,
    required String ownerId,
    required String inviteCode,
    @Default([]) List<String> memberIds,
  }) = _Household;
}
