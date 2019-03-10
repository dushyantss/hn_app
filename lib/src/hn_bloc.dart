library hn_bloc;

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'package:hn_app/src/article.dart';

enum Topic { top, latest }

class HackerNewsBloc {
  Topic _topic = Topic.top;
  // Streams
  final _articlesSubject = BehaviorSubject<BuiltList<Article>>();

  Stream<BuiltList<Article>> get articles => _articlesSubject.stream;

  // Caches
  BuiltList<Article> _topArticles;
  BuiltList<Article> _latestArticles;

  HackerNewsBloc() {
    refresh();
  }

  Future<void> refresh() async {
    final oldTopic = _topic;
    BuiltList articles;
    try {
      articles = await _getArticles(_topic);
      if (oldTopic == _topic) {
        if (oldTopic == Topic.top) {
          _topArticles = articles;
        } else {
          _latestArticles = articles;
        }
        _articlesSubject.add(articles);
      }
    } catch (error) {
      if (oldTopic == _topic) {
        _articlesSubject.addError(error);
      }
    }
  }

  updateTopic(Topic topic) {
    _topic = topic;
    _articlesSubject.add(topic == Topic.top ? _topArticles : _latestArticles);
    refresh();
  }
}

Future<BuiltList<Article>> _getArticles(Topic topic) async {
  final ids = await _getTopStoriesIds(topic);
  final futureArticles = ids.map((id) => _getArticle(id));
  final articles = await Future.wait(futureArticles);
  return BuiltList.of(articles);
}

Future<List<int>> _getTopStoriesIds(Topic topic) async {
  final endpoint = topic == Topic.top
      ? 'https://hacker-news.firebaseio.com/v0/topstories.json'
      : 'https://hacker-news.firebaseio.com/v0/newstories.json';

  final response = await http.get(endpoint);
  if (response.statusCode == 200) {
    return parseTopStories(response.body).sublist(0, 10);
  }
  throw Exception('Bad response');
}

Future<Article> _getArticle(int id) async {
  final response =
      await http.get('https://hacker-news.firebaseio.com/v0/item/$id.json');
  if (response.statusCode == 200) {
    return parseArticle(response.body);
  }
  throw Exception('Bad response');
}
