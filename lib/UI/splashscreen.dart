import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';

class SplashScreen extends StatelessWidget {
  final bool isAuth;
  SplashScreen({Key key, this.isAuth = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ControlledAnimation(
                duration: Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.elasticInOut,
                builder: (context, animation) {
                  return Transform.scale(
                    scale: animation,
                    child: Text(
                      isAuth == false ? 'Le News' : 'Authenticating',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
            SizedBox(
              height: 100.0,
            ),
            SpinKitChasingDots(
              color: Colors.black,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
