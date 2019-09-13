import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/models/tags.dart';
import 'package:simple_news/services/news_api.dart';

class TagButton extends StatelessWidget {
  final bool active;
  final Tag tag;
  final Color activeTagColor;
  final Color tagColor;
  final String title;
  final VoidCallback onTap;
  TagButton(
      {Key key,
      this.title,
      this.active = false,
      this.tag,
      this.tagColor = Colors.white,
      this.onTap,
      this.activeTagColor = Colors.green})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NewsApi newsApi = Provider.of<NewsApi>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: FlatButton(
        onPressed: onTap,
        color: active == false ? tagColor : activeTagColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
            title: Text(
              '#' + title,
              style: TextStyle(
                  color: active == false ? Colors.black : Colors.white),
            ),
            trailing: active == false
                ? Container()
                : newsApi.isFetching == true
                    ? SpinKitChasingDots(
                        color: Colors.white,
                        size: 15,
                      )
                    : Container()),
      ),
    );
  }
}
