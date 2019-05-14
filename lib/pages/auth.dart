import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity/connectivity.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();
  FirebaseStorage _storage = FirebaseStorage.instance;
  Firestore db = Firestore.instance;
  String _email;
  String _password;
  String _name;
  String _username;
  String _errorMessage;
  bool isAvatar = false;

  File _image;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);

          await uploadPic(userId);
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 &&
            userId != null &&
            _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.message;
          } else
            _errorMessage = e.message;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Login'),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showAvatar() {
    return _formMode == FormMode.LOGIN
        ? Container()
        : InkWell(
            onTap: () async {
              var image =
                  await ImagePicker.pickImage(source: ImageSource.gallery);

              setState(() {
                if (image != null) {
                  _image = image;
                  isAvatar = true;
                }
              });
            },
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: isAvatar
                    ? FileImage(_image)
                    : AssetImage('assets/placeholder.png'),
              ),
            ),
          );
  }

  // void _showVerifyEmailSentDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // return object of type Dialog
  //       return AlertDialog(
  //         title: new Text("Verify your account"),
  //         content:
  //             new Text("Link to verify account has been sent to your email"),
  //         actions: <Widget>[
  //           new FlatButton(
  //             child: new Text("Dismiss"),
  //             onPressed: () {
  //               _changeFormToLogin();
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.only(right: 16.0, left: 16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            children: <Widget>[
              _showLogo(),
              _showAvatar(),
              _showNameInput(),
              _showUsernameInput(),
              // _showBioInput(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              SizedBox(
                height: 15,
              ),
              _showThirdButton(),
              SizedBox(
                height: 15,
              ),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 65.0, 0.0, 50.0),
        child: Center(
          child: Text(
            'Le News',
            style: TextStyle(
              fontFamily: 'Avenir',
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showNameInput() {
    return _formMode == FormMode.LOGIN
        ? Container()
        : Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
            child: new TextFormField(
              maxLines: 1,
              keyboardType: TextInputType.text,
              autofocus: false,
              decoration: new InputDecoration(
                  hintText: 'Name',
                  icon: new Icon(
                    Icons.person,
                    color: Colors.grey,
                  )),
              validator: (value) =>
                  value.isEmpty ? 'Name can\'t be empty' : null,
              onSaved: (value) => _name = value,
            ),
          );
  }

  // Widget _showBioInput() {
  //   return _formMode == FormMode.LOGIN
  //       ? Container()
  //       : Padding(
  //           padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
  //           child: new TextFormField(
  //             maxLines: 3,
  //             keyboardType: TextInputType.text,
  //             autofocus: false,
  //             decoration: new InputDecoration(
  //                 hintText: 'About',
  //                 icon: new Icon(
  //                   Icons.assignment,
  //                   color: Colors.grey,
  //                 )),
  //             validator: (value) =>
  //                 value.isEmpty ? null : null,
  //             onSaved: (value) => _bio = value,
  //           ),
  //         );
  // }

  Widget _showUsernameInput() {
    return _formMode == FormMode.LOGIN
        ? Container()
        : Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
            child: new TextFormField(
              maxLines: 1,
              keyboardType: TextInputType.text,
              autofocus: false,
              decoration: new InputDecoration(
                  hintText: 'Username',
                  icon: new Icon(
                    Icons.assignment,
                    color: Colors.grey,
                  )),
              validator: (value) =>
                  value.isEmpty ? 'Username can\'t be empty' : null,
              onSaved: (value) => _username = value,
            ),
          );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      padding: EdgeInsets.only(top: 30),
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showThirdButton() {
    return _formMode == FormMode.LOGIN
        ? new FlatButton(
            padding: EdgeInsets.only(top: 30),
            child: new Text('Forgot Password',
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Forgot Password?'),
                      content: TextField(
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Send'),
                          onPressed: () {
                            if (!_email.contains(' ') && _email.isNotEmpty) {
                              widget.auth.resetPassword(_email);
                            }
                            setState(() {
                              _email = '';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Dismiss'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
            })
        : Container();
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Create account',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }

  Future uploadPic(String uid) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (_image != null) {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        var imagePath = _image.path;
        String fileName = imagePath.split('/').last;

        //Create a reference to the location you want to upload to in firebase
        StorageReference reference =
            _storage.ref().child('users/$uid/images/$fileName');

        //Upload the file to firebase
        StorageUploadTask uploadTask = reference.putFile(_image);

        // Waits till the file is uploaded then stores the download url
        String location =
            await (await uploadTask.onComplete).ref.getDownloadURL();

        var now = DateTime.now();

        var data = {'image': location, 'uid': uid, 'createdAt': now};

        var data2 = {
          'uid': uid,
          'name': _name,
          'email': _email,
          'displayName': _username,
          'bio': '',
          'profile_pic': location,
        };

        db.collection('photo_content').add(data);
        db.collection('users').document(uid).setData(data2);
        db.collection('tags').add({'title': 'top', 'tag': 'top', 'uid': uid});
      } else {
        var data2 = {
          'uid': uid,
          'name': _name,
          'email': _email,
          'displayName': _username,
          'bio': '',
          'profile_pic':
              'http://icons.iconarchive.com/icons/papirus-team/papirus-status/256/avatar-default-icon.png',
        };
        db.collection('users').document(uid).setData(data2);
        db.collection('tags').add({'title': 'top', 'tag': 'top', 'uid': uid});
        return;
      }
      //returns the download url

    }
    return;
    //Get the file from the image picker and store it
  }
}
