import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'dart:convert';

import 'package:hn_app/src/serializers.dart';

part 'article.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
  int get id;
  String get type;
  String get by;
  int get time;

  @nullable
  bool get deleted;
  @nullable
  bool get dead;
  @nullable
  String get text;
  @nullable
  int get parent;
  @nullable
  int get poll;
  @nullable
  BuiltList<int> get kids;
  @nullable
  String get url;
  @nullable
  int get score;
  @nullable
  String get title;
  @nullable
  BuiltList<int> get parts;
  @nullable
  int get descendants;

  Article._();
  factory Article([updates(ArticleBuilder b)]) = _$Article;
  static Serializer<Article> get serializer => _$articleSerializer;
}

List<int> parseTopStories(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final listofIds = List<int>.from(parsed);
  return listofIds;
}

Article parseArticle(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final article =
      standardSerializers.deserializeWith(Article.serializer, parsed);
  return article;
}
