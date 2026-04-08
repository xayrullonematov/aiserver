import 'package:json_annotation/json_annotation.dart';

part 'ai_response.g.dart';

@JsonSerializable()
class FileEdit {
  final String path;
  @JsonKey(name: 'old_content')
  final String? oldContent;
  @JsonKey(name: 'new_content')
  final String newContent;
  final String? description;

  FileEdit({
    required this.path,
    this.oldContent,
    required this.newContent,
    this.description,
  });

  factory FileEdit.fromJson(Map<String, dynamic> json) => _$FileEditFromJson(json);
  Map<String, dynamic> toJson() => _$FileEditToJson(this);
}

@JsonSerializable()
class ProposedCommand {
  final String command;
  final String description;
  @JsonKey(name: 'risk_level')
  final String riskLevel;

  ProposedCommand({
    required this.command,
    required this.description,
    required this.riskLevel,
  });

  factory ProposedCommand.fromJson(Map<String, dynamic> json) => _$ProposedCommandFromJson(json);
  Map<String, dynamic> toJson() => _$ProposedCommandToJson(this);
}

@JsonSerializable()
class AIResponse {
  final String id;
  final String summary;
  final String? evidence;
  @JsonKey(name: 'proposed_commands')
  final List<ProposedCommand> proposedCommands;
  @JsonKey(name: 'file_edits')
  final List<FileEdit> fileEdits;
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  @JsonKey(name: 'needs_approval')
  final bool needsApproval;

  AIResponse({
    required this.id,
    required this.summary,
    this.evidence,
    required this.proposedCommands,
    required this.fileEdits,
    required this.riskLevel,
    required this.needsApproval,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) => _$AIResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AIResponseToJson(this);
}
