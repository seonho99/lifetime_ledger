// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpState {

 String get email; String get password; String get confirmPassword; String get displayName; bool get isLoading; bool get obscurePassword; bool get agreeToTerms; String? get errorMessage; String? get successMessage;
/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpStateCopyWith<SignUpState> get copyWith => _$SignUpStateCopyWithImpl<SignUpState>(this as SignUpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.obscurePassword, obscurePassword) || other.obscurePassword == obscurePassword)&&(identical(other.agreeToTerms, agreeToTerms) || other.agreeToTerms == agreeToTerms)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,confirmPassword,displayName,isLoading,obscurePassword,agreeToTerms,errorMessage,successMessage);

@override
String toString() {
  return 'SignUpState(email: $email, password: $password, confirmPassword: $confirmPassword, displayName: $displayName, isLoading: $isLoading, obscurePassword: $obscurePassword, agreeToTerms: $agreeToTerms, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $SignUpStateCopyWith<$Res>  {
  factory $SignUpStateCopyWith(SignUpState value, $Res Function(SignUpState) _then) = _$SignUpStateCopyWithImpl;
@useResult
$Res call({
 String email, String password, String confirmPassword, String displayName, bool isLoading, bool obscurePassword, bool agreeToTerms, String? errorMessage, String? successMessage
});




}
/// @nodoc
class _$SignUpStateCopyWithImpl<$Res>
    implements $SignUpStateCopyWith<$Res> {
  _$SignUpStateCopyWithImpl(this._self, this._then);

  final SignUpState _self;
  final $Res Function(SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? confirmPassword = null,Object? displayName = null,Object? isLoading = null,Object? obscurePassword = null,Object? agreeToTerms = null,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(SignUpState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,obscurePassword: null == obscurePassword ? _self.obscurePassword : obscurePassword // ignore: cast_nullable_to_non_nullable
as bool,agreeToTerms: null == agreeToTerms ? _self.agreeToTerms : agreeToTerms // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


// dart format on
