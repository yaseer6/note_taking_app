class Folder {
  final String id;
  String name;
  final int iconCode;
  List<String> noteIds;
  final DateTime createdAt;
  DateTime updatedAt;

  Folder({
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


  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      iconCode: json['iconCode'],
      noteIds: (json['noteIds'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

}