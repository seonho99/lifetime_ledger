// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoryState {

 List<History> get histories; bool get isLoading; String? get errorMessage; int? get selectedMonth; int? get selectedYear; HistoryType? get filterType;
/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryStateCopyWith<HistoryState> get copyWith => _$HistoryStateCopyWithImpl<HistoryState>(this as HistoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryState&&const DeepCollectionEquality().equals(other.histories, histories)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.selectedMonth, selectedMonth) || other.selectedMonth == selectedMonth)&&(identical(other.selectedYear, selectedYear) || other.selectedYear == selectedYear)&&(identical(other.filterType, filterType) || other.filterType == filterType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(histories),isLoading,errorMessage,selectedMonth,selectedYear,filterType);

@override
String toString() {
  return 'HistoryState(histories: $histories, isLoading: $isLoading, errorMessage: $errorMessage, selectedMonth: $selectedMonth, selectedYear: $selectedYear, filterType: $filterType)';
}


}

/// @nodoc
abstract mixin class $HistoryStateCopyWith<$Res>  {
  factory $HistoryStateCopyWith(HistoryState value, $Res Function(HistoryState) _then) = _$HistoryStateCopyWithImpl;
@useResult
$Res call({
 List<History> histories, bool isLoading, String? errorMessage, int? selectedMonth, int? selectedYear, HistoryType? filterType
});




}
/// @nodoc
class _$HistoryStateCopyWithImpl<$Res>
    implements $HistoryStateCopyWith<$Res> {
  _$HistoryStateCopyWithImpl(this._self, this._then);

  final HistoryState _self;
  final $Res Function(HistoryState) _then;

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? histories = null,Object? isLoading = null,Object? errorMessage = freezed,Object? selectedMonth = freezed,Object? selectedYear = freezed,Object? filterType = freezed,}) {
  return _then(HistoryState(
histories: null == histories ? _self.histories : histories // ignore: cast_nullable_to_non_nullable
as List<History>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,selectedMonth: freezed == selectedMonth ? _self.selectedMonth : selectedMonth // ignore: cast_nullable_to_non_nullable
as int?,selectedYear: freezed == selectedYear ? _self.selectedYear : selectedYear // ignore: cast_nullable_to_non_nullable
as int?,filterType: freezed == filterType ? _self.filterType : filterType // ignore: cast_nullable_to_non_nullable
as HistoryType?,
  ));
}

}


// dart format on
