import 'dart:convert';

import 'package:flutter_movie_example/models/video_result.dart';

class TvShowDetail {
  final String id;
  final String title;
  final String description;
  final List<VideoResult> relatedTvShow;
  TvShowDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.relatedTvShow,
  });

  TvShowDetail copyWith({
    String? id,
    String? title,
    String? description,
    List<VideoResult>? relatedTvShow,
  }) {
    return TvShowDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      relatedTvShow: relatedTvShow ?? this.relatedTvShow,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'relatedTvShow': relatedTvShow.map((x) => x.toMap()).toList(),
    };
  }

  factory TvShowDetail.fromMap(Map<String, dynamic> map) {
    return TvShowDetail(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      relatedTvShow: List<VideoResult>.from(
          map['relatedTvShow']?.map((x) => VideoResult.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory TvShowDetail.fromJson(String source) =>
      TvShowDetail.fromMap(json.decode(source));
}
