// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationSettingsImpl(
  isEnabled: json['isEnabled'] as bool? ?? true,
  hour: (json['hour'] as num?)?.toInt() ?? 9,
  minute: (json['minute'] as num?)?.toInt() ?? 0,
  message: json['message'] as String? ?? 'トピックが届いています',
);

Map<String, dynamic> _$$NotificationSettingsImplToJson(
  _$NotificationSettingsImpl instance,
) => <String, dynamic>{
  'isEnabled': instance.isEnabled,
  'hour': instance.hour,
  'minute': instance.minute,
  'message': instance.message,
};
