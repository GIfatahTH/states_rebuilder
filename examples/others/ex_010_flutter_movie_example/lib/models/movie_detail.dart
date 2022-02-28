import 'dart:convert';

import 'video_result.dart';

class MovieDetail {
  final String id;
  final String title;
  final String description;
  final List<VideoResult> relatedMovies;
  MovieDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.relatedMovies,
  });

  MovieDetail copyWith({
    String? id,
    String? title,
    String? description,
    List<VideoResult>? relatedMovies,
  }) {
    return MovieDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      relatedMovies: relatedMovies ?? this.relatedMovies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'relatedMovies': relatedMovies.map((x) => x.toMap()).toList(),
    };
  }

  factory MovieDetail.fromMap(Map<String, dynamic> map) {
    return MovieDetail(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      relatedMovies: List<VideoResult>.from(
          map['relatedMovies']?.map((x) => VideoResult.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory MovieDetail.fromJson(String source) =>
      MovieDetail.fromMap(json.decode(source));
}
