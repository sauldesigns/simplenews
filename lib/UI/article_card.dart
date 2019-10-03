import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/models/news.dart';
import 'package:simple_news/services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleCard extends StatefulWidget {
  ArticleCard(
      {Key key, this.active, this.article, this.isBookmark = false, this.ctrl})
      : super(key: key);
  final bool active;
  final News article;
  final bool isBookmark;
  final PageController ctrl;
  _ArticleCardState createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  final _db = DatabaseService();

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double blur = widget.active ? 30 : 0;
    final double offset = widget.active ? 10 : 0;
    final double top = widget.active ? 80 : 200;
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(widget.article.articleImage),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black87,
                blurRadius: blur,
                offset: Offset(offset, offset))
          ]),
      child: InkWell(
        onTap: () {
          _launchUrl(widget.article.url);
        },
        onLongPress: () {
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            margin: EdgeInsets.all(8.0),
            borderRadius: 10,
            duration: Duration(seconds: 3),
            message: widget.isBookmark == true
                ? 'Article is already a bookmark'
                : 'Added to bookmarks',
            icon: Icon(
              widget.isBookmark == true ? Icons.error : Icons.bookmark,
              color: Colors.red,
            ),
          )..show(context);
          if (!widget.isBookmark) {
            _db.addBookmark(user.uid, widget.article);
          }
        },
        onDoubleTap: () {
          widget.ctrl.animateToPage(0,
              duration: Duration(milliseconds: 2500),
              curve: Curves.easeOutQuint);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(000, 000, 000, 0.65),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 150, left: 10, right: 10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: top,
                ),
                Text(widget.article.title,
                    style: TextStyle(fontSize: 30, color: Colors.white)),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  widget.article.description,
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
