import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'src/article.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _ids = [
    19347443,
    19346321,
    19346985,
    19345739,
    19336236,
    19340234,
    19346295,
    19347597,
    19346342,
    19347041,
  ];

  Future<Article> _getArticle(int id) async {
    final response =
        await http.get('https://hacker-news.firebaseio.com/v0/item/$id.json');
    if (response.statusCode == 200) {
      return parseArticle(response.body);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            _ids.removeAt(0);
          });
        },
        child: ListView(
          children: _ids
              .map((i) => FutureBuilder<Article>(
                    future: _getArticle(i),
                    builder: _buildItem,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildItem(
      BuildContext context, AsyncSnapshot<Article> articleSnapshot) {
    if (articleSnapshot.connectionState != ConnectionState.done ||
        articleSnapshot.hasError) {
      return _buildLoader();
    }
    final article = articleSnapshot.data;
    if (article == null) {
      return _buildLoader();
    }
    return Padding(
      key: Key('${article.id}'),
      padding: EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text(article.title ?? '', style: TextStyle(fontSize: 24.0)),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("By ${article.by}"),
              IconButton(
                icon: Icon(Icons.launch),
                onPressed: () async {
                  if (await canLaunch(article.url)) {
                    launch(article.url);
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
