import 'package:auto_size_text/auto_size_text.dart';
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
  final VoidCallback onLongPress;
  TagButton(
      {Key key,
      this.title,
      this.active = false,
      this.tag,
      this.tagColor = Colors.white,
      this.onTap,
      this.onLongPress,
      this.activeTagColor = Colors.green})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NewsApi newsApi = Provider.of<NewsApi>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
            color: active == false ? tagColor : activeTagColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 1), blurRadius: 2),
            ]),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              children: <Widget>[
                AutoSizeText(
                  '#' + title,
                  style: TextStyle(
                      color: active == false ? Colors.black : Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(),
                ),
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
