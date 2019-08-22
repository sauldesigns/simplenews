import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/UI/tag_button.dart';
import 'package:simple_news/models/tags.dart';
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

  void _handleSubmit(String value, FirebaseUser userData) {
    String temp = value.toLowerCase().replaceAll(' ', '');
    if (temp.isNotEmpty) {
      value = value.toLowerCase().trim();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Add Tag'),
              content: Text('Are you sure you want to add the tag #$temp?'),
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
    return Text(title,
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500));
  }

  Widget _menuButtons(UserRepository userRepo) {
    return Row(
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: Text('Bookmarks'),
          onPressed: () {},
        ),
        SizedBox(
          width: 10,
        ),
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: Text('Sign Out'),
          onPressed: () {
            userRepo.signOut();
          },
        ),
      ],
    );
  }

  Widget _buildTags(NewsApi newsApi) {
    return Container(
      width: 200,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 20, left: 5),
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
                onTap: () {
                  newsApi.fetchData();
                  newsApi.setTagIndex(0);
                  setState(() {
                    currentTagIndex = newsApi.tagIndex;
                  });
                });
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
                onTap: () {
                  newsApi.fetchData(
                      query: 'everything?q=' + tag.tag + '&pageSize=100');
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
    currentTagIndex = newsApi.tagIndex;
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 100, bottom: 20),
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _title('Le News'),
          SizedBox(
            height: 10.0,
          ),
          _menuButtons(userRepo),
          SizedBox(
            height: 10.0,
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
          _buildTags(newsApi),
          // Expanded(
          //   child: Container(
          //     width: 200.0,
          //   ),
          // ),
        ],
      ),
    );
  }
}
