// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ListEntry {
  String get id => throw _privateConstructorUsedError;
  String get listId => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  bool get isChecked => throw _privateConstructorUsedError;
  DateTime get addedAt => throw _privateConstructorUsedError;
  DateTime? get checkedAt => throw _privateConstructorUsedError;
  String? get addedById => throw _privateConstructorUsedError;

  /// Create a copy of ListEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListEntryCopyWith<ListEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListEntryCopyWith<$Res> {
  factory $ListEntryCopyWith(ListEntry value, $Res Function(ListEntry) then) =
      _$ListEntryCopyWithImpl<$Res, ListEntry>;
  @useResult
  $Res call(
      {String id,
      String listId,
      String itemId,
      double quantity,
      bool isChecked,
      DateTime addedAt,
      DateTime? checkedAt,
      String? addedById});
}

/// @nodoc
class _$ListEntryCopyWithImpl<$Res, $Val extends ListEntry>
    implements $ListEntryCopyWith<$Res> {
  _$ListEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listId = null,
    Object? itemId = null,
    Object? quantity = null,
    Object? isChecked = null,
    Object? addedAt = null,
    Object? checkedAt = freezed,
    Object? addedById = freezed,
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
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      isChecked: null == isChecked
          ? _value.isChecked
          : isChecked // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkedAt: freezed == checkedAt
          ? _value.checkedAt
          : checkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      addedById: freezed == addedById
          ? _value.addedById
          : addedById // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListEntryImplCopyWith<$Res>
    implements $ListEntryCopyWith<$Res> {
  factory _$$ListEntryImplCopyWith(
          _$ListEntryImpl value, $Res Function(_$ListEntryImpl) then) =
      __$$ListEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String listId,
      String itemId,
      double quantity,
      bool isChecked,
      DateTime addedAt,
      DateTime? checkedAt,
      String? addedById});
}

/// @nodoc
class __$$ListEntryImplCopyWithImpl<$Res>
    extends _$ListEntryCopyWithImpl<$Res, _$ListEntryImpl>
    implements _$$ListEntryImplCopyWith<$Res> {
  __$$ListEntryImplCopyWithImpl(
      _$ListEntryImpl _value, $Res Function(_$ListEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listId = null,
    Object? itemId = null,
    Object? quantity = null,
    Object? isChecked = null,
    Object? addedAt = null,
    Object? checkedAt = freezed,
    Object? addedById = freezed,
  }) {
    return _then(_$ListEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      listId: null == listId
          ? _value.listId
          : listId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      isChecked: null == isChecked
          ? _value.isChecked
          : isChecked // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkedAt: freezed == checkedAt
          ? _value.checkedAt
          : checkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      addedById: freezed == addedById
          ? _value.addedById
          : addedById // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ListEntryImpl implements _ListEntry {
  const _$ListEntryImpl(
      {required this.id,
      required this.listId,
      required this.itemId,
      this.quantity = 1.0,
      this.isChecked = false,
      required this.addedAt,
      this.checkedAt,
      this.addedById});

  @override
  final String id;
  @override
  final String listId;
  @override
  final String itemId;
  @override
  @JsonKey()
  final double quantity;
  @override
  @JsonKey()
  final bool isChecked;
  @override
  final DateTime addedAt;
  @override
  final DateTime? checkedAt;
  @override
  final String? addedById;

  @override
  String toString() {
    return 'ListEntry(id: $id, listId: $listId, itemId: $itemId, quantity: $quantity, isChecked: $isChecked, addedAt: $addedAt, checkedAt: $checkedAt, addedById: $addedById)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.listId, listId) || other.listId == listId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.isChecked, isChecked) ||
                other.isChecked == isChecked) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt) &&
            (identical(other.checkedAt, checkedAt) ||
                other.checkedAt == checkedAt) &&
            (identical(other.addedById, addedById) ||
                other.addedById == addedById));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, listId, itemId, quantity,
      isChecked, addedAt, checkedAt, addedById);

  /// Create a copy of ListEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListEntryImplCopyWith<_$ListEntryImpl> get copyWith =>
      __$$ListEntryImplCopyWithImpl<_$ListEntryImpl>(this, _$identity);
}

abstract class _ListEntry implements ListEntry {
  const factory _ListEntry(
      {required final String id,
      required final String listId,
      required final String itemId,
      final double quantity,
      final bool isChecked,
      required final DateTime addedAt,
      final DateTime? checkedAt,
      final String? addedById}) = _$ListEntryImpl;

  @override
  String get id;
  @override
  String get listId;
  @override
  String get itemId;
  @override
  double get quantity;
  @override
  bool get isChecked;
  @override
  DateTime get addedAt;
  @override
  DateTime? get checkedAt;
  @override
  String? get addedById;

  /// Create a copy of ListEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListEntryImplCopyWith<_$ListEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
