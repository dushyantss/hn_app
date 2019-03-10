import 'package:built_collection/built_collection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hn_app/src/article.dart';
import 'package:hn_app/src/hn_bloc.dart';

void main() {
  final hnBloc = HackerNewsBloc();
  runApp(MyApp(bloc: hnBloc));
}

class MyApp extends StatelessWidget {
  final HackerNewsBloc bloc;

  MyApp({Key key, @required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hacker News',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(
        title: 'Flutter Hacker News',
        bloc: bloc,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final HackerNewsBloc bloc;

  MyHomePage({Key key, this.title, this.bloc}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: LoadingInfo(
          isLoading: widget.bloc.isLoading,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            title: Text('Top Stories'),
            icon: Icon(Icons.vertical_align_top),
          ),
          BottomNavigationBarItem(
            title: Text('New Stories'),
            icon: Icon(Icons.new_releases),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          widget.bloc.updateTopic(index == 0 ? Topic.top : Topic.latest);
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: RefreshIndicator(
        onRefresh: widget.bloc.refresh,
        child: StreamBuilder<BuiltList<Article>>(
            initialData: null,
            stream: widget.bloc.articles,
            builder: (_, snapshot) {
              if (snapshot.data == null) {
                return _buildLoader();
              } else if (snapshot.hasError) {
                return Center(child: const Text("Error Occured"));
              }
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, i) {
                  return _buildItem(snapshot.data[i]);
                },
              );
            }),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildItem(Article article) {
    return Padding(
      key: Key('${article.id}'),
      padding: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text(article.title ?? '', style: TextStyle(fontSize: 24.0)),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("By ${article.by}"),
              IconButton(
                icon: const Icon(Icons.launch),
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

class LoadingInfo extends StatefulWidget {
  final Stream<bool> isLoading;

  LoadingInfo({Key key, @required this.isLoading}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoadingInfoState();
}

class LoadingInfoState extends State<LoadingInfo>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  void _startAnimation() {
    _controller
        .forward()
        .then((_) => _controller.reverse())
        .then((_) => _startAnimation());
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.isLoading,
      initialData: false,
      builder: (_, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          _startAnimation();
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(curve: Curves.easeIn, parent: _controller)),
            child: const Icon(FontAwesomeIcons.hackerNews),
          );
        }
        _controller.reset();
        return const Padding(
          padding: const EdgeInsets.all(4.0),
        );
      },
    );
  }
}
