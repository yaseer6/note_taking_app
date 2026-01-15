class Note {
  final String id;
  String title;
  String content;
  List<String> tags;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
  });

  Note copyWith({
    String? title,
    String? content,
    List<String>? tags,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
