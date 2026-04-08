// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerProfile _$ServerProfileFromJson(Map<String, dynamic> json) =>
    ServerProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      host: json['host'] as String,
      port: (json['port'] as num).toInt(),
      username: json['username'] as String,
      authType: $enumDecode(_$AuthTypeEnumMap, json['auth_type']),
      projectPath: json['project_path'] as String,
      lastConnected: json['last_connected'] == null
          ? null
          : DateTime.parse(json['last_connected'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ServerProfileToJson(ServerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'display_name': instance.displayName,
      'host': instance.host,
      'port': instance.port,
      'username': instance.username,
      'auth_type': _$AuthTypeEnumMap[instance.authType]!,
      'project_path': instance.projectPath,
      'last_connected': instance.lastConnected?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$AuthTypeEnumMap = {
  AuthType.password: 'password',
  AuthType.key: 'key',
};
