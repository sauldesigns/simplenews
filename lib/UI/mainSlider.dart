import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';

class FirestoreSlideshow extends StatefulWidget {
  FirestoreSlideshow({Key key, this.userId, this.auth, this.onSignedOut})
      : super(key: key);
  final String userId;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  createState() => FirestoreSlideshowState();
}

class FirestoreSlideshowState extends State<FirestoreSlideshow> {
  final Firestore db = Firestore.instance;

  final PageController ctrl = PageController(viewportFraction: 0.8);
  final TextEditingController txtCtrl = TextEditingController();

  bool deleteItem = false;
  List newSlides;
  List listTags;
  String activeTag = 'top';
  String url = '';
  int currentPage = 0;
  var tagData;
  int numTags;

  @override
  void initState() {
    super.initState();
    listTags = [];
    newSlides = [];
    _queryDb();
    tagData = Firestore.instance
        .collection('tags')
        .where('uid', isEqualTo: widget.userId)
        .orderBy('tag', descending: false);

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
    return PageView.builder(
      controller: ctrl,
      itemCount: newSlides.isEmpty == true ? 1 : newSlides.length + 1,
      itemBuilder: (context, int currentIdx) {
        if (currentIdx == 0) {
          return _buildTagPage();
        } else if (newSlides.length >= currentIdx) {
          bool active = currentIdx == currentPage;

          return _buildStoryPage(newSlides[currentIdx - 1], active);
        }
      },
    );
  }

  // Query Firestore
  Future _queryDb({String tag = 'top', bool bookmark = false}) async {
    if (tag == 'top') {
      var response = await http.get(
          Uri.encodeFull(
              'https://newsapi.org/v2/top-headlines?country=us&pageSize=100'),
          headers: {
            'Accept': 'application/json',
            'X-Api-Key': '7b9fb000e2244968b0f05ce6dd04c9d2'
          });
      var localData = json.decode(response.body);

      newSlides = localData['articles'];

      setState(() {
        activeTag = tag;
      });
    } else if (bookmark == true) {
      print('bookmark');
    } else {
      var response = await http.get(
          Uri.encodeFull(
              'https://newsapi.org/v2/everything?q=' + tag + '&pageSize=100'),
          headers: {
            'Accept': 'application/json',
            'X-Api-Key': '7b9fb000e2244968b0f05ce6dd04c9d2'
          });
      var localData = jsonDecode(response.body);

      newSlides = localData['articles'];
      setState(() {
        activeTag = tag;
      });
    }
  }

  
  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 15,
          ),
          Text('Bookmark added'),
        ],
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _buildStoryPage(Map data, bool active) {
    final double blur = active ? 30 : 0;
    final double offset = active ? 10 : 0;
    final double top = active ? 80 : 200;

    return AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOutQuint,
        margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage((data['urlToImage'] == null ||
                      data['urlToImage'] == '' ||
                      !data['urlToImage'].toString().contains('http'))
                  ? 'https://firebasestorage.googleapis.com/v0/b/ifunny-66ef2.appspot.com/o/bg_placeholder.jpeg?alt=media&token=1f6da019-f9ed-4635-a040-33b8a0f80d25'
                  : data['urlToImage']),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black87,
                  blurRadius: blur,
                  offset: Offset(offset, offset))
            ]),
        child: InkWell(
            onTap: () {
              _launchUrl(data['url']);
            },
            onLongPress: () {
              var newDat = data;
              newDat['uid'] = widget.userId;

              db.collection('bookmarks').add(newDat);
              setState(() {
                _displaySnackBar(context);
              });
            },
            onDoubleTap: () {
              this.ctrl.animateToPage(0,
                  duration: Duration(milliseconds: 3000),
                  curve: Curves.easeOutQuint);
            },
            child: AnimatedContainer(
                duration: Duration(milliseconds: 1000),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(000, 000, 000, 0.65),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      SizedBox(
                        height: top,
                      ),
                      Text(data['title'],
                          style: TextStyle(fontSize: 30, color: Colors.white)),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        (data['description'] == null ||
                                data['description'] == '')
                            ? 'no description'
                            : data['description'],
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ]))))));
  }

  void _handleSubmit(String value) {
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
                    Firestore.instance.collection('tags').add(
                        {'tag': value, 'title': temp, 'uid': widget.userId});
                    txtCtrl.clear();
                    _queryDb(tag: value);
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

  _buildTagPage() {
    return Container(
      margin: EdgeInsets.only(top: 100.0, left: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Your News',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                child: Text('Bookmarks'),
                onPressed: () {
                  _queryDb(tag: 'bookmark', bookmark: true);
                },
              ),
              FlatButton(
                child: Text('Sign Out'),
                onPressed: () {
                  widget.onSignedOut();
                },
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
              width: 200.0,
              child: TextField(
                decoration: InputDecoration(
                    labelText: 'Add a tag',
                    contentPadding: EdgeInsets.only(
                      bottom: 0.0,
                    )),
                onSubmitted: _handleSubmit,
                controller: txtCtrl,
              )),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Container(
            width: 230.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                deleteItem == true
                    ? Text('Tap to delete')
                    : Text('FILTER', style: TextStyle(color: Colors.black26)),
                FlatButton(
                  child: deleteItem == false ? Text('Edit') : Text('Done'),
                  onPressed: () {
                    setState(() {
                      deleteItem = !deleteItem;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
              child: Container(
                  width: 200.0,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: tagData.snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Center(
                                child: CircularProgressIndicator());
                          default:
                            return ListView.builder(
                                padding:
                                    EdgeInsets.only(top: 10.0, bottom: 30.0),
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  Color color = snapshot
                                              .data.documents[index]['tag']
                                              .toString() ==
                                          activeTag
                                      ? Colors.purple
                                      : Colors.white;
                                  Color color2 = snapshot
                                              .data.documents[index]['tag']
                                              .toString() ==
                                          activeTag
                                      ? Colors.white
                                      : Colors.black;

                                  return FlatButton(
                                      color: color,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            deleteItem == true
                                                ? Icon(Icons.delete)
                                                : SizedBox(
                                                    width: 0,
                                                  ),
                                            deleteItem == true
                                                ? SizedBox(
                                                    width: 10.0,
                                                  )
                                                : SizedBox(
                                                    width: 0,
                                                  ),
                                            Text(
                                              '#' +
                                                  snapshot.data
                                                      .documents[index]['title']
                                                      .toString(),
                                              style: TextStyle(color: color2),
                                            ),
                                          ]),
                                      onPressed: () {
                                        if (deleteItem == true) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Delete Tag'),
                                                  content: Text(
                                                      'Are you sure you want to delete the tag #' +
                                                          snapshot.data
                                                                  .documents[
                                                              index]['title'] +
                                                          '?'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text('Delete'),
                                                      onPressed: () {
                                                        Firestore.instance
                                                            .collection('tags')
                                                            .document(snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .documentID)
                                                            .delete();
                                                        if (activeTag ==
                                                            snapshot.data
                                                                    .documents[
                                                                index]['title']) {
                                                          _queryDb(tag: 'top');
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        } else {
                                          _queryDb(
                                              tag: snapshot
                                                  .data.documents[index]['tag']
                                                  .toString());
                                        }
                                      });
                                });
                        }
                      })))
        ],
      ),
    );
  }
}
