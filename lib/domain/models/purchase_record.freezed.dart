// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PurchaseRecord {
  String get id => throw _privateConstructorUsedError;
  String get listId => throw _privateConstructorUsedError;
  String get listName => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  List<PurchaseRecordEntry> get entries => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseRecordCopyWith<PurchaseRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseRecordCopyWith<$Res> {
  factory $PurchaseRecordCopyWith(
          PurchaseRecord value, $Res Function(PurchaseRecord) then) =
      _$PurchaseRecordCopyWithImpl<$Res, PurchaseRecord>;
  @useResult
  $Res call(
      {String id,
      String listId,
      String listName,
      DateTime completedAt,
      String ownerId,
      List<PurchaseRecordEntry> entries});
}

/// @nodoc
class _$PurchaseRecordCopyWithImpl<$Res, $Val extends PurchaseRecord>
    implements $PurchaseRecordCopyWith<$Res> {
  _$PurchaseRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listId = null,
    Object? listName = null,
    Object? completedAt = null,
    Object? ownerId = null,
    Object? entries = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      listId: null == listId
          ? _value.listId
          : listId // ignore: cast_nullable_to_non_nullable
              as String,
      listName: null == listName
          ? _value.listName
          : listName // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<PurchaseRecordEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseRecordImplCopyWith<$Res>
    implements $PurchaseRecordCopyWith<$Res> {
  factory _$$PurchaseRecordImplCopyWith(_$PurchaseRecordImpl value,
          $Res Function(_$PurchaseRecordImpl) then) =
      __$$PurchaseRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String listId,
      String listName,
      DateTime completedAt,
      String ownerId,
      List<PurchaseRecordEntry> entries});
}

/// @nodoc
class __$$PurchaseRecordImplCopyWithImpl<$Res>
    extends _$PurchaseRecordCopyWithImpl<$Res, _$PurchaseRecordImpl>
    implements _$$PurchaseRecordImplCopyWith<$Res> {
  __$$PurchaseRecordImplCopyWithImpl(
      _$PurchaseRecordImpl _value, $Res Function(_$PurchaseRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listId = null,
    Object? listName = null,
    Object? completedAt = null,
    Object? ownerId = null,
    Object? entries = null,
  }) {
    return _then(_$PurchaseRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      listId: null == listId
          ? _value.listId
          : listId // ignore: cast_nullable_to_non_nullable
              as String,
      listName: null == listName
          ? _value.listName
          : listName // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<PurchaseRecordEntry>,
    ));
  }
}

/// @nodoc

class _$PurchaseRecordImpl implements _PurchaseRecord {
  const _$PurchaseRecordImpl(
      {required this.id,
      required this.listId,
      required this.listName,
      required this.completedAt,
      required this.ownerId,
      final List<PurchaseRecordEntry> entries = const []})
      : _entries = entries;

  @override
  final String id;
  @override
  final String listId;
  @override
  final String listName;
  @override
  final DateTime completedAt;
  @override
  final String ownerId;
  final List<PurchaseRecordEntry> _entries;
  @override
  @JsonKey()
  List<PurchaseRecordEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  String toString() {
    return 'PurchaseRecord(id: $id, listId: $listId, listName: $listName, completedAt: $completedAt, ownerId: $ownerId, entries: $entries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.listId, listId) || other.listId == listId) &&
            (identical(other.listName, listName) ||
                other.listName == listName) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            const DeepCollectionEquality().equals(other._entries, _entries));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, listId, listName,
      completedAt, ownerId, const DeepCollectionEquality().hash(_entries));

  /// Create a copy of PurchaseRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseRecordImplCopyWith<_$PurchaseRecordImpl> get copyWith =>
      __$$PurchaseRecordImplCopyWithImpl<_$PurchaseRecordImpl>(
          this, _$identity);
}

abstract class _PurchaseRecord implements PurchaseRecord {
  const factory _PurchaseRecord(
      {required final String id,
      required final String listId,
      required final String listName,
      required final DateTime completedAt,
      required final String ownerId,
      final List<PurchaseRecordEntry> entries}) = _$PurchaseRecordImpl;

  @override
  String get id;
  @override
  String get listId;
  @override
  String get listName;
  @override
  DateTime get completedAt;
  @override
  String get ownerId;
  @override
  List<PurchaseRecordEntry> get entries;

  /// Create a copy of PurchaseRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseRecordImplCopyWith<_$PurchaseRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PurchaseRecordEntry {
  String get itemId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseRecordEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseRecordEntryCopyWith<PurchaseRecordEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseRecordEntryCopyWith<$Res> {
  factory $PurchaseRecordEntryCopyWith(
          PurchaseRecordEntry value, $Res Function(PurchaseRecordEntry) then) =
      _$PurchaseRecordEntryCopyWithImpl<$Res, PurchaseRecordEntry>;
  @useResult
  $Res call({String itemId, String itemName, String unit, double quantity});
}

/// @nodoc
class _$PurchaseRecordEntryCopyWithImpl<$Res, $Val extends PurchaseRecordEntry>
    implements $PurchaseRecordEntryCopyWith<$Res> {
  _$PurchaseRecordEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseRecordEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? itemName = null,
    Object? unit = null,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseRecordEntryImplCopyWith<$Res>
    implements $PurchaseRecordEntryCopyWith<$Res> {
  factory _$$PurchaseRecordEntryImplCopyWith(_$PurchaseRecordEntryImpl value,
          $Res Function(_$PurchaseRecordEntryImpl) then) =
      __$$PurchaseRecordEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String itemId, String itemName, String unit, double quantity});
}

/// @nodoc
class __$$PurchaseRecordEntryImplCopyWithImpl<$Res>
    extends _$PurchaseRecordEntryCopyWithImpl<$Res, _$PurchaseRecordEntryImpl>
    implements _$$PurchaseRecordEntryImplCopyWith<$Res> {
  __$$PurchaseRecordEntryImplCopyWithImpl(_$PurchaseRecordEntryImpl _value,
      $Res Function(_$PurchaseRecordEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseRecordEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? itemName = null,
    Object? unit = null,
    Object? quantity = null,
  }) {
    return _then(_$PurchaseRecordEntryImpl(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$PurchaseRecordEntryImpl implements _PurchaseRecordEntry {
  const _$PurchaseRecordEntryImpl(
      {required this.itemId,
      required this.itemName,
      required this.unit,
      this.quantity = 1.0});

  @override
  final String itemId;
  @override
  final String itemName;
  @override
  final String unit;
  @override
  @JsonKey()
  final double quantity;

  @override
  String toString() {
    return 'PurchaseRecordEntry(itemId: $itemId, itemName: $itemName, unit: $unit, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseRecordEntryImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, itemId, itemName, unit, quantity);

  /// Create a copy of PurchaseRecordEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseRecordEntryImplCopyWith<_$PurchaseRecordEntryImpl> get copyWith =>
      __$$PurchaseRecordEntryImplCopyWithImpl<_$PurchaseRecordEntryImpl>(
          this, _$identity);
}

abstract class _PurchaseRecordEntry implements PurchaseRecordEntry {
  const factory _PurchaseRecordEntry(
      {required final String itemId,
      required final String itemName,
      required final String unit,
      final double quantity}) = _$PurchaseRecordEntryImpl;

  @override
  String get itemId;
  @override
  String get itemName;
  @override
  String get unit;
  @override
  double get quantity;

  /// Create a copy of PurchaseRecordEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseRecordEntryImplCopyWith<_$PurchaseRecordEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
