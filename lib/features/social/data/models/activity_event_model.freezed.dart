// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityEventModel {

 String get eventId; SocialUserModel get user; String get activityType; SocialMediaModel get media; Map<String, dynamic> get metadata; DateTime get createdAt;
/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityEventModelCopyWith<ActivityEventModel> get copyWith => _$ActivityEventModelCopyWithImpl<ActivityEventModel>(this as ActivityEventModel, _$identity);

  /// Serializes this ActivityEventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityEventModel&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.user, user) || other.user == user)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.media, media) || other.media == media)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,user,activityType,media,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'ActivityEventModel(eventId: $eventId, user: $user, activityType: $activityType, media: $media, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ActivityEventModelCopyWith<$Res>  {
  factory $ActivityEventModelCopyWith(ActivityEventModel value, $Res Function(ActivityEventModel) _then) = _$ActivityEventModelCopyWithImpl;
@useResult
$Res call({
 String eventId, SocialUserModel user, String activityType, SocialMediaModel media, Map<String, dynamic> metadata, DateTime createdAt
});


$SocialUserModelCopyWith<$Res> get user;$SocialMediaModelCopyWith<$Res> get media;

}
/// @nodoc
class _$ActivityEventModelCopyWithImpl<$Res>
    implements $ActivityEventModelCopyWith<$Res> {
  _$ActivityEventModelCopyWithImpl(this._self, this._then);

  final ActivityEventModel _self;
  final $Res Function(ActivityEventModel) _then;

/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? user = null,Object? activityType = null,Object? media = null,Object? metadata = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as SocialUserModel,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as SocialMediaModel,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialUserModelCopyWith<$Res> get user {
  
  return $SocialUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMediaModelCopyWith<$Res> get media {
  
  return $SocialMediaModelCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}


/// Adds pattern-matching-related methods to [ActivityEventModel].
extension ActivityEventModelPatterns on ActivityEventModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityEventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityEventModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityEventModel value)  $default,){
final _that = this;
switch (_that) {
case _ActivityEventModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityEventModel value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityEventModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  SocialUserModel user,  String activityType,  SocialMediaModel media,  Map<String, dynamic> metadata,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityEventModel() when $default != null:
return $default(_that.eventId,_that.user,_that.activityType,_that.media,_that.metadata,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  SocialUserModel user,  String activityType,  SocialMediaModel media,  Map<String, dynamic> metadata,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ActivityEventModel():
return $default(_that.eventId,_that.user,_that.activityType,_that.media,_that.metadata,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  SocialUserModel user,  String activityType,  SocialMediaModel media,  Map<String, dynamic> metadata,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ActivityEventModel() when $default != null:
return $default(_that.eventId,_that.user,_that.activityType,_that.media,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityEventModel implements ActivityEventModel {
  const _ActivityEventModel({required this.eventId, required this.user, required this.activityType, required this.media, final  Map<String, dynamic> metadata = const <String, dynamic>{}, required this.createdAt}): _metadata = metadata;
  factory _ActivityEventModel.fromJson(Map<String, dynamic> json) => _$ActivityEventModelFromJson(json);

@override final  String eventId;
@override final  SocialUserModel user;
@override final  String activityType;
@override final  SocialMediaModel media;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override final  DateTime createdAt;

/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityEventModelCopyWith<_ActivityEventModel> get copyWith => __$ActivityEventModelCopyWithImpl<_ActivityEventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityEventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityEventModel&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.user, user) || other.user == user)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.media, media) || other.media == media)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,user,activityType,media,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'ActivityEventModel(eventId: $eventId, user: $user, activityType: $activityType, media: $media, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ActivityEventModelCopyWith<$Res> implements $ActivityEventModelCopyWith<$Res> {
  factory _$ActivityEventModelCopyWith(_ActivityEventModel value, $Res Function(_ActivityEventModel) _then) = __$ActivityEventModelCopyWithImpl;
@override @useResult
$Res call({
 String eventId, SocialUserModel user, String activityType, SocialMediaModel media, Map<String, dynamic> metadata, DateTime createdAt
});


@override $SocialUserModelCopyWith<$Res> get user;@override $SocialMediaModelCopyWith<$Res> get media;

}
/// @nodoc
class __$ActivityEventModelCopyWithImpl<$Res>
    implements _$ActivityEventModelCopyWith<$Res> {
  __$ActivityEventModelCopyWithImpl(this._self, this._then);

  final _ActivityEventModel _self;
  final $Res Function(_ActivityEventModel) _then;

/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? user = null,Object? activityType = null,Object? media = null,Object? metadata = null,Object? createdAt = null,}) {
  return _then(_ActivityEventModel(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as SocialUserModel,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as SocialMediaModel,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialUserModelCopyWith<$Res> get user {
  
  return $SocialUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of ActivityEventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMediaModelCopyWith<$Res> get media {
  
  return $SocialMediaModelCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}

// dart format on
