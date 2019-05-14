import 'package:flutter/material.dart';
import '../pages/auth.dart';
import '../services/auth.dart';
import '../UI/mainSlider.dart';
import 'package:flutter/foundation.dart' as foundation;

bool get isIOS => foundation.defaultTargetPlatform == TargetPlatform.iOS;

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus = user?.uid == null
            ? AuthStatus.NOT_LOGGED_IN
            : user.isEmailVerified
                ? AuthStatus.LOGGED_IN
                : AuthStatus.NOT_LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        // isVerified = user.isEmailVerified;
        // if (user.isEmailVerified) {
        authStatus = AuthStatus.LOGGED_IN;
        // } else {
        //   authStatus = AuthStatus.NOT_LOGGED_IN;

        //   if (user.uid.toString() != null && user.isEmailVerified == false) {
        //     showDialog(
        //         context: context,
        //         builder: (context) {
        //           return AlertDialog(
        //             title: Text('Verify your account'),
        //             content: Text(
        //                 'This account e-mail has not been verified please check e-mail, or spam folder to verify account.'),
        //             actions: <Widget>[
        //               FlatButton(
        //                 child: Text('Re-send'),
        //                 onPressed: () {
        //                   widget.auth.sendEmailVerification().then((_) {
        //                     widget.auth.signOut();
        //                   });

        //                   Navigator.of(context).pop();
        //                 },
        //               ),
        //               FlatButton(
        //                 child: Text('Dismiss'),
        //                 onPressed: () {
        //                   widget.auth.signOut();
        //                   Navigator.of(context).pop();
        //                 },
        //               ),
        //             ],
        //           );
        //         });
        //   }
        // }
      });
    });
  }

  void _onSignedOut() {
    // setState(() {

    widget.auth.signOut();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => RootPage(
                auth: new Auth(),
              ),
        ),
        (_) => false);
    // });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new Scaffold(
            body: FirestoreSlideshow(
              userId: _userId,
              auth: widget.auth,
              onSignedOut: _onSignedOut,
            ),
          );
        } else
          return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
