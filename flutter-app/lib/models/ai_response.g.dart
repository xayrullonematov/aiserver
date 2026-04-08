// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileEdit _$FileEditFromJson(Map<String, dynamic> json) => FileEdit(
      path: json['path'] as String,
      oldContent: json['old_content'] as String?,
      newContent: json['new_content'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$FileEditToJson(FileEdit instance) => <String, dynamic>{
      'path': instance.path,
      'old_content': instance.oldContent,
      'new_content': instance.newContent,
      'description': instance.description,
    };

ProposedCommand _$ProposedCommandFromJson(Map<String, dynamic> json) =>
    ProposedCommand(
      command: json['command'] as String,
      description: json['description'] as String,
      riskLevel: json['risk_level'] as String,
    );

Map<String, dynamic> _$ProposedCommandToJson(ProposedCommand instance) =>
    <String, dynamic>{
      'command': instance.command,
      'description': instance.description,
      'risk_level': instance.riskLevel,
    };

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
      id: json['id'] as String,
      summary: json['summary'] as String,
      evidence: json['evidence'] as String?,
      proposedCommands: (json['proposed_commands'] as List<dynamic>)
          .map((e) => ProposedCommand.fromJson(e as Map<String, dynamic>))
          .toList(),
      fileEdits: (json['file_edits'] as List<dynamic>)
          .map((e) => FileEdit.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskLevel: json['risk_level'] as String,
      needsApproval: json['needs_approval'] as bool,
    );

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'evidence': instance.evidence,
      'proposed_commands': instance.proposedCommands,
      'file_edits': instance.fileEdits,
      'risk_level': instance.riskLevel,
      'needs_approval': instance.needsApproval,
    };
