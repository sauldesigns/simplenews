import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/UI/article_card.dart';
import 'package:simple_news/UI/tag_menu.dart';
import 'package:simple_news/models/news.dart';
import 'package:simple_news/models/tags.dart';
import 'package:simple_news/services/news_api.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  final Firestore db = Firestore.instance;

  final PageController ctrl = PageController(viewportFraction: 0.8);
  final TextEditingController txtCtrl = TextEditingController();

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var newsApi = Provider.of<NewsApi>(context);
    var tagsList = Provider.of<List<Tag>>(context);
    List<News> _newsList = newsApi.getArticles();
    return Scaffold(
      body: PageView.builder(
        controller: ctrl,
        itemCount: _newsList == null ? 1 : _newsList.length + 1,
        itemBuilder: (context, int currentIdx) {
          if (currentIdx == 0) {
            return TagMenu(
              listTags: tagsList,
            );
          } else if (_newsList.length >= currentIdx) {
            bool active = currentIdx == currentPage;
            return ArticleCard(
              active: active,
              article: _newsList[currentIdx - 1],
              ctrl: ctrl,
            );
          }
          return Container();
        },
      ),
    );
  }
}
