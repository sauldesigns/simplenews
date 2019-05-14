import 'package:flutter/material.dart';

import './pages/root.dart';
import './services/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final PageController ctrl = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RootPage(
        auth: new Auth(),
      ),
      // scrollDirection: Axis.vertical,
    );
  }
}
