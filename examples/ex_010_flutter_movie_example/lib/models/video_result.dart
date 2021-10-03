import 'dart:convert';

class VideoResult {
  final String id;
  final String title;
  VideoResult({
    required this.id,
    required this.title,
  });

  VideoResult copyWith({
    String? id,
    String? title,
  }) {
    return VideoResult(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory VideoResult.fromMap(Map<String, dynamic> map) {
    return VideoResult(
      id: map['id'],
      title: map['title'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoResult.fromJson(String source) =>
      VideoResult.fromMap(json.decode(source));
}
