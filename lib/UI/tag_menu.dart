import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/UI/tag_button.dart';
import 'package:simple_news/models/news.dart';
import 'package:simple_news/models/tags.dart';
import 'package:simple_news/models/user.dart';
import 'package:simple_news/pages/bookmarks.dart';
import 'package:simple_news/services/database_service.dart';
import 'package:simple_news/services/news_api.dart';
import 'package:simple_news/services/user_repo.dart';

class TagMenu extends StatefulWidget {
  TagMenu({Key key, this.listTags}) : super(key: key);
  final List<Tag> listTags;

  _TagMenuState createState() => _TagMenuState();
}

class _TagMenuState extends State<TagMenu> {
  final TextEditingController txtCtrl = TextEditingController();
  bool deleteItem = false;
  bool active = false;
  int currentTagIndex = 0;
  final _db = DatabaseService();

  void _handleSubmit(String value, FirebaseUser userData) {
    String temp = value.toLowerCase().replaceAll(' ', '');
    if (temp.isNotEmpty) {
      value = value.toLowerCase().trim();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text('Add Tag'),
              content: Text(
                  'This tag will be searched as\n\n\'$value\'\n\nAdd the tag #$temp ?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Add'),
                  onPressed: () {
                    Firestore.instance
                        .collection('users')
                        .document(userData.uid)
                        .collection('tags')
                        .add(
                            {'tag': value, 'title': temp, 'uid': userData.uid});
                    txtCtrl.clear();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    txtCtrl.clear();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } else {
      txtCtrl.clear();
    }
  }

  Widget _title(String title) {
    return AutoSizeText(title,
        maxLines: 2,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300));
  }

  Widget _menuButtons(UserRepository userRepo, NewsApi newsApi, User user) {
    return Row(
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: Text('Bookmarks'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StreamProvider<User>.value(
                  value: _db.streamUser(user.uid),
                  initialData: user,
                  child: StreamProvider<List<News>>.value(
                    value: _db.streamBookmarks(user.uid),
                    child: BookmarksPage(),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(
          width: 10,
        ),
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: Text('Sign Out'),
          onPressed: () {
            newsApi.fetchData();
            newsApi.setTagIndex(0);
            userRepo.signOut();
          },
        ),
      ],
    );
  }

  Widget _buildTags(NewsApi newsApi, BuildContext context, String userId) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 20, left: 1, right: 80),
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: widget.listTags == null ? 1 : widget.listTags.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            if (currentTagIndex == 0) {
              active = true;
            } else {
              active = false;
            }
            return TagButton(
                active: active,
                title: 'top',
                activeTagColor: Colors.blue,
                onTap: () {
                  newsApi.fetchData();
                  newsApi.setTagIndex(0);
                  setState(() {
                    currentTagIndex = newsApi.tagIndex;
                  });
                });
          } else if (widget.listTags == null) {
            return CircularProgressIndicator();
          } else {
            Tag tag = widget.listTags[index - 1];
            if (index == currentTagIndex) {
              active = true;
            } else {
              active = false;
            }
            return TagButton(
                active: active,
                title: tag.title,
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Delete Tag'),
                          content:
                              Text('Are you sure you want to delete this tag?'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: () {
                                _db.deleteTag(userId, tag.id);
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      });
                },
                activeTagColor: Colors.blue,
                onTap: () {
                  newsApi.fetchData(
                      query: 'everything?q=' +
                          tag.tag +
                          '&language=en&sortBy=relevancy&pageSize=100');
                  newsApi.setTagIndex(index);
                  setState(() {
                    currentTagIndex = newsApi.tagIndex;
                  });
                });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserRepository userRepo = Provider.of<UserRepository>(context);
    FirebaseUser userData = Provider.of<FirebaseUser>(context);
    NewsApi newsApi = Provider.of<NewsApi>(context);
    User user = Provider.of<User>(context);
    currentTagIndex = newsApi.tagIndex;
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 100, bottom: 20),
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _title('${user.username}\'s\nNews'),
          SizedBox(
            height: 10.0,
          ),
          _menuButtons(userRepo, newsApi, user),
          SizedBox(
            height: 5.0,
          ),
          Container(
              width: 200.0,
              child: TextField(
                autocorrect: false,
                decoration: InputDecoration(
                    labelText: 'Add a tag',
                    contentPadding: EdgeInsets.only(
                      bottom: 0.0,
                    )),
                onSubmitted: (value) => _handleSubmit(value, userData),
                controller: txtCtrl,
              )),
          SizedBox(
            height: 25.0,
          ),
          Container(
            width: 230.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('FILTER', style: TextStyle(color: Colors.black38)),
              ],
            ),
          ),
          _buildTags(newsApi, context, user.uid), // Expanded(
          //   child: Container(
          //     width: 200.0,
          //   ),
          // ),
        ],
      ),
    );
  }
}
