class Folder {
  final String id;
  final String name;
  final int iconCode;
  final List<String> noteIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Folder({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.noteIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'noteIds': noteIds.map((e) => e.toString()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Folder copyWith({
    String? name,
    int? iconCode,
    List<String>? noteIds,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      noteIds: noteIds ?? this.noteIds,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      iconCode: json['iconCode'],
      noteIds: List<String>.from(json['noteIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

}