import 'package:json_annotation/json_annotation.dart';

part 'server.g.dart';

enum AuthType { password, key }

@JsonSerializable()
class ServerProfile {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'display_name')
  final String displayName;
  final String host;
  final int port;
  final String username;
  @JsonKey(name: 'auth_type')
  final AuthType authType;
  @JsonKey(name: 'project_path')
  final String projectPath;
  @JsonKey(name: 'last_connected')
  final DateTime? lastConnected;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ServerProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.host,
    required this.port,
    required this.username,
    required this.authType,
    required this.projectPath,
    this.lastConnected,
    required this.createdAt,
  });

  factory ServerProfile.fromJson(Map<String, dynamic> json) => _$ServerProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ServerProfileToJson(this);
}
