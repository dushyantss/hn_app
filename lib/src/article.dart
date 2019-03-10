import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'dart:convert';

import 'package:hn_app/src/serializers.dart';

part 'article.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
  /// The item's unique id.
  int get id;

  /// The type of item. One of "job", "story", "comment", "poll", or "pollopt".
  String get type;

  /// The username of the item's author.
  String get by;

  /// Creation date of the item, in Unix Time.
  int get time;

  //----------------------nullable----------------------//

  /// The comment, story or poll text. HTML.
  @nullable
  String get text;

  /// true if the item is deleted.
  @nullable
  bool get deleted;

  /// true if the item is dead.
  @nullable
  bool get dead;

  /// The comment's parent: either another comment or the relevant story.
  @nullable
  int get parent;

  /// The pollopt's associated poll.
  @nullable
  int get poll;

  /// The ids of the item's comments, in ranked display order.
  @nullable
  BuiltList<int> get kids;

  /// The URL of the story.
  @nullable
  String get url;

  /// The story's score, or the votes for a pollopt.
  @nullable
  int get score;

  /// The title of the story, poll or job.
  @nullable
  String get title;

  /// A list of related pollopts, in display order.
  @nullable
  BuiltList<int> get parts;

  ///	In the case of stories or polls, the total comment count.
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
