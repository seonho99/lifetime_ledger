// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChangePasswordState {

 String get currentPassword; String get newPassword; String get confirmNewPassword; bool get isLoading; bool get obscureCurrentPassword; bool get obscureNewPassword; bool get obscureConfirmPassword; String? get errorMessage; String? get successMessage; String? get currentPasswordError; String? get newPasswordError; String? get confirmPasswordError;
/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordStateCopyWith<ChangePasswordState> get copyWith => _$ChangePasswordStateCopyWithImpl<ChangePasswordState>(this as ChangePasswordState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordState&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmNewPassword, confirmNewPassword) || other.confirmNewPassword == confirmNewPassword)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.obscureCurrentPassword, obscureCurrentPassword) || other.obscureCurrentPassword == obscureCurrentPassword)&&(identical(other.obscureNewPassword, obscureNewPassword) || other.obscureNewPassword == obscureNewPassword)&&(identical(other.obscureConfirmPassword, obscureConfirmPassword) || other.obscureConfirmPassword == obscureConfirmPassword)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage)&&(identical(other.currentPasswordError, currentPasswordError) || other.currentPasswordError == currentPasswordError)&&(identical(other.newPasswordError, newPasswordError) || other.newPasswordError == newPasswordError)&&(identical(other.confirmPasswordError, confirmPasswordError) || other.confirmPasswordError == confirmPasswordError));
}


@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword,confirmNewPassword,isLoading,obscureCurrentPassword,obscureNewPassword,obscureConfirmPassword,errorMessage,successMessage,currentPasswordError,newPasswordError,confirmPasswordError);

@override
String toString() {
  return 'ChangePasswordState(currentPassword: $currentPassword, newPassword: $newPassword, confirmNewPassword: $confirmNewPassword, isLoading: $isLoading, obscureCurrentPassword: $obscureCurrentPassword, obscureNewPassword: $obscureNewPassword, obscureConfirmPassword: $obscureConfirmPassword, errorMessage: $errorMessage, successMessage: $successMessage, currentPasswordError: $currentPasswordError, newPasswordError: $newPasswordError, confirmPasswordError: $confirmPasswordError)';
}


}

/// @nodoc
abstract mixin class $ChangePasswordStateCopyWith<$Res>  {
  factory $ChangePasswordStateCopyWith(ChangePasswordState value, $Res Function(ChangePasswordState) _then) = _$ChangePasswordStateCopyWithImpl;
@useResult
$Res call({
 String currentPassword, String newPassword, String confirmNewPassword, bool isLoading, bool obscureCurrentPassword, bool obscureNewPassword, bool obscureConfirmPassword, String? errorMessage, String? successMessage, String? currentPasswordError, String? newPasswordError, String? confirmPasswordError
});




}
/// @nodoc
class _$ChangePasswordStateCopyWithImpl<$Res>
    implements $ChangePasswordStateCopyWith<$Res> {
  _$ChangePasswordStateCopyWithImpl(this._self, this._then);

  final ChangePasswordState _self;
  final $Res Function(ChangePasswordState) _then;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = null,Object? newPassword = null,Object? confirmNewPassword = null,Object? isLoading = null,Object? obscureCurrentPassword = null,Object? obscureNewPassword = null,Object? obscureConfirmPassword = null,Object? errorMessage = freezed,Object? successMessage = freezed,Object? currentPasswordError = freezed,Object? newPasswordError = freezed,Object? confirmPasswordError = freezed,}) {
  return _then(ChangePasswordState(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmNewPassword: null == confirmNewPassword ? _self.confirmNewPassword : confirmNewPassword // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,obscureCurrentPassword: null == obscureCurrentPassword ? _self.obscureCurrentPassword : obscureCurrentPassword // ignore: cast_nullable_to_non_nullable
as bool,obscureNewPassword: null == obscureNewPassword ? _self.obscureNewPassword : obscureNewPassword // ignore: cast_nullable_to_non_nullable
as bool,obscureConfirmPassword: null == obscureConfirmPassword ? _self.obscureConfirmPassword : obscureConfirmPassword // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,currentPasswordError: freezed == currentPasswordError ? _self.currentPasswordError : currentPasswordError // ignore: cast_nullable_to_non_nullable
as String?,newPasswordError: freezed == newPasswordError ? _self.newPasswordError : newPasswordError // ignore: cast_nullable_to_non_nullable
as String?,confirmPasswordError: freezed == confirmPasswordError ? _self.confirmPasswordError : confirmPasswordError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


// dart format on
