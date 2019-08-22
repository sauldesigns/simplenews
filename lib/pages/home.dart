import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/UI/article_card.dart';
import 'package:simple_news/UI/tag_menu.dart';
import 'package:simple_news/models/news.dart';
import 'package:simple_news/models/tags.dart';
import 'package:simple_news/models/user.dart';
import 'package:simple_news/services/database_service.dart';
import 'package:simple_news/services/news_api.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.useMobile = true}) : super(key: key);
  final bool useMobile;
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  final Firestore db = Firestore.instance;
  final _db = DatabaseService();
  PageController ctrl;
  final TextEditingController txtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    ctrl = PageController(viewportFraction: widget.useMobile == true ? 0.8 : 0.5);
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
    /* 
      Prevents user from being able to go in landscape mode
      when on this page.
    */

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    /* 
      This gets all provider data
      This also inits news articles.
    */
    var newsApi = Provider.of<NewsApi>(context);
    var tagsList = Provider.of<List<Tag>>(context);
    User user = Provider.of<User>(context);
    List<News> _newsList = newsApi.getArticles();


    return Scaffold(
      body: PageView.builder(
        controller: ctrl,
        itemCount: _newsList == null ? 1 : _newsList.length + 1,
        itemBuilder: (context, int currentIdx) {
          if (currentIdx == 0) {
            return StreamProvider<User>.value(
              value: _db.streamUser(user.uid),
              initialData: user,
              child: TagMenu(
                listTags: tagsList,
              ),
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
