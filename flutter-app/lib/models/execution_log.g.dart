// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExecutionLog _$ExecutionLogFromJson(Map<String, dynamic> json) => ExecutionLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      serverId: json['server_id'] as String,
      prompt: json['prompt'] as String,
      proposedCommand: json['proposed_command'] as String,
      approved: json['approved'] as bool,
      output: json['output'] as String?,
      riskLevel: json['risk_level'] as String,
      executedAt: DateTime.parse(json['executed_at'] as String),
    );

Map<String, dynamic> _$ExecutionLogToJson(ExecutionLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'server_id': instance.serverId,
      'prompt': instance.prompt,
      'proposed_command': instance.proposedCommand,
      'approved': instance.approved,
      'output': instance.output,
      'risk_level': instance.riskLevel,
      'executed_at': instance.executedAt.toIso8601String(),
    };
