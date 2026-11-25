import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    this.id,
    required this.title,
    required this.description,
    required this.releasedAt,
    required this.techStack,
    required this.projectUrl,
    this.projectImageUrl = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String releasedAt;
  @JsonKey(defaultValue: '')
  final String techStack;
  @JsonKey(defaultValue: '')
  final String projectUrl;
  @JsonKey(defaultValue: '', readValue: _readImageUrl)
  final String projectImageUrl;

  static Object? _readImageUrl(Map<dynamic, dynamic> json, String key) =>
      json[key] ?? json['thumbnail'];

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
