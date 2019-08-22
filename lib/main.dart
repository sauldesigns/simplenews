import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_news/enums/connectvity_status.dart';
import 'package:simple_news/screens/login.dart';
import 'package:simple_news/screens/signup.dart';
import 'package:simple_news/services/connectivity.dart';
import 'package:simple_news/services/news_api.dart';
import 'package:simple_news/services/user_repo.dart';

import './pages/root.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(
            value: FirebaseAuth.instance.onAuthStateChanged),
        StreamProvider<ConnectivityStatus>.controller(
          builder: (context) =>
              ConnectivityService().connectionStatusController,
        ),
        ChangeNotifierProvider<UserRepository>(
          builder: (_) => UserRepository.instance(),
        ),
        ChangeNotifierProvider<NewsApi>(
          builder: (_) => new NewsApi(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Le News',
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => RootPage(),
          'login': (context) => LoginPage(),
          'signup': (context) => SignUpPage(),
        },
        // scrollDirection: Axis.vertical,
      ),
    );
  }
}
