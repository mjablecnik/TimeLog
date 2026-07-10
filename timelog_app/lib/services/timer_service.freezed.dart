// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerState {
  TimerStatus get status => throw _privateConstructorUsedError;
  int get totalSeconds => throw _privateConstructorUsedError;
  int get secondsLeft => throw _privateConstructorUsedError;
  DateTime? get sessionStart => throw _privateConstructorUsedError;
  DateTime? get endAt => throw _privateConstructorUsedError;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
    TimerState value,
    $Res Function(TimerState) then,
  ) = _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call({
    TimerStatus status,
    int totalSeconds,
    int secondsLeft,
    DateTime? sessionStart,
    DateTime? endAt,
  });
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? totalSeconds = null,
    Object? secondsLeft = null,
    Object? sessionStart = freezed,
    Object? endAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TimerStatus,
            totalSeconds: null == totalSeconds
                ? _value.totalSeconds
                : totalSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            secondsLeft: null == secondsLeft
                ? _value.secondsLeft
                : secondsLeft // ignore: cast_nullable_to_non_nullable
                      as int,
            sessionStart: freezed == sessionStart
                ? _value.sessionStart
                : sessionStart // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endAt: freezed == endAt
                ? _value.endAt
                : endAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
    _$TimerStateImpl value,
    $Res Function(_$TimerStateImpl) then,
  ) = __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TimerStatus status,
    int totalSeconds,
    int secondsLeft,
    DateTime? sessionStart,
    DateTime? endAt,
  });
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
    _$TimerStateImpl _value,
    $Res Function(_$TimerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? totalSeconds = null,
    Object? secondsLeft = null,
    Object? sessionStart = freezed,
    Object? endAt = freezed,
  }) {
    return _then(
      _$TimerStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TimerStatus,
        totalSeconds: null == totalSeconds
            ? _value.totalSeconds
            : totalSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        secondsLeft: null == secondsLeft
            ? _value.secondsLeft
            : secondsLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        sessionStart: freezed == sessionStart
            ? _value.sessionStart
            : sessionStart // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endAt: freezed == endAt
            ? _value.endAt
            : endAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$TimerStateImpl implements _TimerState {
  const _$TimerStateImpl({
    required this.status,
    required this.totalSeconds,
    required this.secondsLeft,
    this.sessionStart,
    this.endAt,
  });

  @override
  final TimerStatus status;
  @override
  final int totalSeconds;
  @override
  final int secondsLeft;
  @override
  final DateTime? sessionStart;
  @override
  final DateTime? endAt;

  @override
  String toString() {
    return 'TimerState(status: $status, totalSeconds: $totalSeconds, secondsLeft: $secondsLeft, sessionStart: $sessionStart, endAt: $endAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalSeconds, totalSeconds) ||
                other.totalSeconds == totalSeconds) &&
            (identical(other.secondsLeft, secondsLeft) ||
                other.secondsLeft == secondsLeft) &&
            (identical(other.sessionStart, sessionStart) ||
                other.sessionStart == sessionStart) &&
            (identical(other.endAt, endAt) || other.endAt == endAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    totalSeconds,
    secondsLeft,
    sessionStart,
    endAt,
  );

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState implements TimerState {
  const factory _TimerState({
    required final TimerStatus status,
    required final int totalSeconds,
    required final int secondsLeft,
    final DateTime? sessionStart,
    final DateTime? endAt,
  }) = _$TimerStateImpl;

  @override
  TimerStatus get status;
  @override
  int get totalSeconds;
  @override
  int get secondsLeft;
  @override
  DateTime? get sessionStart;
  @override
  DateTime? get endAt;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
