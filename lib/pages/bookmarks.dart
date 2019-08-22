import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/UI/article_card.dart';
import 'package:simple_news/models/news.dart';

class BookmarksPage extends StatefulWidget {
  BookmarksPage({Key key}) : super(key: key);

  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  PageController ctrl = new PageController(viewportFraction: 0.8);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Set state when page changes
    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<News> _newsList = Provider.of<List<News>>(context);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text('Bookmarks', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: PageView.builder(
        controller: ctrl,
        itemCount: _newsList == null ? 1 : _newsList.length,
        itemBuilder: (context, int currentIdx) {
          if (_newsList == null) {
            return Center(
              child: Text('No bookmarks'),
            );
          } else if (_newsList.length >= currentIdx) {
            bool active = currentIdx == currentPage;
            return ArticleCard(
              active: active,
              isBookmark: true,
              article: _newsList[currentIdx],
              ctrl: ctrl,
            );
          }
          return Container();
        },
      ),
    );
  }
}
