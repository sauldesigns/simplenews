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
      child: InkWell(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: active == false ? this.tagColor : this.activeTagColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  offset: Offset(0, 3),
                  color: Colors.grey,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text(
                  '#' + title,
                  style: TextStyle(
                      color: active == false ? Colors.black : Colors.white),
                ),
                Expanded(child: Container()),
                active == false
                    ? Container()
                    : newsApi.isFetching == true
                        ? SpinKitChasingDots(
                            color: Colors.white,
                            size: 15,
                          )
                        : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
