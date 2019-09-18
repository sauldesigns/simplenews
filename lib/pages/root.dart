import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_news/UI/splashscreen.dart';
import 'package:simple_news/enums/auth.dart';
import 'package:simple_news/models/tags.dart';
import 'package:simple_news/models/user.dart';
import 'package:simple_news/pages/home.dart';
import 'package:simple_news/screens/login.dart';
import 'package:simple_news/services/database_service.dart';
import 'package:simple_news/services/user_repo.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key}) : super(key: key);

  _RootPageState createState() => _RootPageState();
}

// this helps define the state the app should be in depending if
// user was previously logged in, if no user is logged in, or if
// user is being authenthicated.
class _RootPageState extends State<RootPage> {
  Firestore db = Firestore.instance;
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    /* 
      If mobile then user viewport of 0.8
      if tablet then use viewpoert of 0.5
    */

    var shortestSide = MediaQuery.of(context).size.shortestSide;
    var useMobileLayout = shortestSide < 600;
    var _user = Provider.of<FirebaseUser>(context);
    var user = Provider.of<UserRepository>(context);
    switch (user.status) {
      case Status.Uninitialized:
        return SplashScreen();
      case Status.Unauthenticated:
        return LoginPage();
      case Status.Authenticating:
        return SplashScreen(
          isAuth: true,
        );
      case Status.Authenticated:
        return StreamProvider<User>.value(
          value: _db.streamUser(_user.uid),
          initialData: User.initialData(),
          child: StreamProvider<List<Tag>>.value(
            value: _db.streamTags(_user.uid),
            child: HomePage(useMobile: useMobileLayout),
          ),
        );
      default:
        return SplashScreen();
    }
  }
}
