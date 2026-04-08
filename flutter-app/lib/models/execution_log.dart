import 'package:json_annotation/json_annotation.dart';

part 'execution_log.g.dart';

@JsonSerializable()
class ExecutionLog {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'server_id')
  final String serverId;
  final String prompt;
  @JsonKey(name: 'proposed_command')
  final String proposedCommand;
  final bool approved;
  final String? output;
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  @JsonKey(name: 'executed_at')
  final DateTime executedAt;

  ExecutionLog({
    required this.id,
    required this.userId,
    required this.serverId,
    required this.prompt,
    required this.proposedCommand,
    required this.approved,
    this.output,
    required this.riskLevel,
    required this.executedAt,
  });

  factory ExecutionLog.fromJson(Map<String, dynamic> json) => _$ExecutionLogFromJson(json);
  Map<String, dynamic> toJson() => _$ExecutionLogToJson(this);
}
