import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'CoolRoundedButton.dart';
import 'Validators.dart';
import 'ConnectingWidget.dart';
import 'HomePage.dart';
import 'FirebaseWrapper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum LoginPageState { login, register }

enum StatusState { idle, pending, failed, success }

class _LoginPageState extends State<LoginPage> {
  //Tracks whether we are at 'Log In' or 'Create an Account'
  LoginPageState loginPageState = LoginPageState.login;

  //Tracks the user progress
  StatusState registerState = StatusState.idle;
  StatusState loginState = StatusState.idle;

  //This key will let us reference the form
  final _formKey = GlobalKey<FormState>();

  //These controllers handle text field inputs and events
  //They also have a 'text' property to get the current String input
  TextEditingController emailController,
      passwordController,
      confirmPasswordController;

  String _email;
  String _password;

  @override
  void initState() {
    super.initState();

    emailController = new TextEditingController();
    passwordController = new TextEditingController();
    confirmPasswordController = new TextEditingController();
  }

  void _attemptLogin() async {
    var loginResult = await FirebaseWrapper().signIn(_email, _password);
    if (loginResult != null) {
      print('Finished logging in');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(userId: loginResult)));
    } else {
      print('Failed to login');
      setState(() {
        loginState = StatusState.failed;
      });
    }
  }

  void _attemptAccountCreation() async {
    var creationResult =
        await FirebaseWrapper().createAccount(_email, _password);
    if (creationResult) {
      print('Finished creating new user');
      setState(() {
        registerState = StatusState.success;
      });
    } else {
      print('Failed to create new user');
      setState(() {
        registerState = StatusState.failed;
      });
    }
  }

  void _removeWhitespaceFromTextFields() {
    void _remove(TextEditingController controller) {
      if (controller.text != null) {
        controller.text = controller.text.trim();
      }
    }

    _remove(emailController);
    _remove(passwordController);
    _remove(confirmPasswordController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              loginPageState == LoginPageState.login
                  ? 'Log In'
                  : 'Create an Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          child: AnimatedContainer(
              height: _animatedContainerHeight(),
              width: 380,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(24),
//                  boxShadow: [BoxShadow(blurRadius: 20)]
              ),
              duration: Duration(milliseconds: 300),
              child: registerState == StatusState.success
                  ? _accountCreatedBody()
                  : Scrollbar(
                      child: SingleChildScrollView(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Container(
                                  child: Form(
                                      key: _formKey, child: _formBody())))),
                    )),
        ));
  }

  Widget _accountCreatedBody() {
    TextStyle subStyle = TextStyle(color: Colors.white, fontSize: 18);
    TextStyle mainStyle = TextStyle(
        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500);

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Account for', style: subStyle),
            Text(_email, style: mainStyle),
            Text('created!', style: subStyle),
            _togglePageButton('Log in')
          ],
        ));
  }

  Widget _formBody() {
    if (loginPageState == LoginPageState.login) {
      //If we are at 'Log In'
      var pending = loginState == StatusState.pending;
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _loginColumnElement(0),
          _loginColumnElement(1),
          pending ? _pendingWidget() : Center(child: _loginButton()),
          _failureNotice(),
          pending ? Container() : Center(child: _orSpacer()),
          pending
              ? Container()
              : Center(child: _togglePageButton('Create an account'))
        ],
      );
    } else {
      //If we are at 'Create an Account'
      var pending = registerState == StatusState.pending;
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _loginColumnElement(0),
          _loginColumnElement(1),
          _loginColumnElement(2),
          pending ? _pendingWidget() : Center(child: _createAccountButton()),
          _failureNotice(),
          pending ? Container() : Center(child: _orSpacer()),
          pending
              ? Container()
              : Center(
                  child: _togglePageButton('I already have an account'),
                )
        ],
      );
    }
  }

  Widget _pendingWidget() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: ConnectingWidget(color: Colors.white));
  }

  Widget _loginColumnElement(int index) {
    TextStyle textFieldLabelStyle =
        TextStyle(fontSize: 18, color: Colors.white);
    TextStyle textFieldInputStyle = TextStyle(fontSize: 16);

    //These will be set dynamically for our text fields
    String label;
    TextFormField textField;
    Function validator;
    TextEditingController controller;
    Function onSaved;

    //Set here based on index
    switch (index) {
      case 0:
        label = 'Email:';
        validator = emailValidator;
        controller = emailController;
        onSaved = (val) {
          _email = val;
        };
        break;
      case 1:
        label = 'Password:';
        validator = passwordValidator;
        controller = passwordController;
        onSaved = (val) {
          _password = val;
        };
        break;
      case 2:
        label = 'Confirm:';
        validator = (str) {
          //First use default password validator
          var defaultValidatorResult = passwordValidator(str);
          if (defaultValidatorResult != null) {
            return defaultValidatorResult;
          }
          //Then check that the 2 passwords match
          if (str != passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        };
        controller = confirmPasswordController;
        onSaved = (val) {};
        break;
      default:
        break;
    }

    OutlineInputBorder _border(Color color) {
      return OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: color, width: 3));
    }

    textField = new TextFormField(
      style: textFieldInputStyle,
      maxLines: 1,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: _border(Colors.white),
          focusedBorder: _border(Colors.lightBlue),
          errorBorder: _border(Colors.red),
          focusedErrorBorder: _border(Colors.red)),
      controller: controller,
      obscureText: index != 0,
      keyboardType: index == 0
          ? TextInputType.emailAddress
          : TextInputType.visiblePassword,
      validator: validator,
      onSaved: onSaved,
      onTap: () {
        if (index == 0) {
          setState(() {
            registerState = StatusState.idle;
            loginState = StatusState.idle;
          });
        }
      },
    );

    return Container(
        height: 66,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: textFieldLabelStyle),
            Container(height: 56, width: 220, child: textField)
          ],
        ));
  }

  Widget _loginButton() {
    return CoolRoundedButton(
      child: Text(
        'Log in',
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
      color: Colors.white,
      onPressed: () {
        print('Logging in');
        _removeWhitespaceFromTextFields();
        if (_formKey.currentState.validate()) {
          //Fields valid, attempt to log in
          _formKey.currentState.save();
          setState(() {
            loginState = StatusState.pending;
          });
          _attemptLogin();
        } else {
          print('Failed to validate fields');
        }
      },
    );
  }

  Widget _failureNotice() {
    //Returns an empty container if there is no failure
    var login = loginPageState == LoginPageState.login;
    if (login && loginState != StatusState.failed ||
        !login && registerState != StatusState.failed) {
      return Container();
    }
    return Padding(
        padding: EdgeInsets.only(top: 4, bottom: 8),
        child: Text(
          login
              ? 'No account with that email and password'
              : 'There is already an account with that email',
          style: TextStyle(
              fontSize: 16, color: Colors.red, fontWeight: FontWeight.w500),
        ));
  }

  Widget _orSpacer() {
    return Padding(
        padding: EdgeInsets.only(bottom: 2, top: 4),
        child: Text(
          'or',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ));
  }

  Widget _togglePageButton(String title) {
    return CoolRoundedButton(
      child: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
      color: Colors.white,
      onPressed: () {
        //When we switch between Login and Register, we should reset everything
        setState(() {
          if (_formKey != null && _formKey.currentState != null) {
            _formKey.currentState.reset();
          }
          emailController.text = '';
          passwordController.text = '';
          confirmPasswordController.text = '';
          loginState = StatusState.idle;
          registerState = StatusState.idle;
          if (loginPageState == LoginPageState.login) {
            loginPageState = LoginPageState.register;
          } else {
            loginPageState = LoginPageState.login;
          }
        });
      },
    );
  }

  Widget _createAccountButton() {
    return CoolRoundedButton(
      child: Text(
        'Register',
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
      color: Colors.white,
      onPressed: () {
        _removeWhitespaceFromTextFields();
        if (_formKey.currentState.validate()) {
          //Registration info is valid!
          //Let's create the account
          _formKey.currentState.save();
          setState(() {
            registerState = StatusState.pending;
          });
          print('Attempting to register a new account: $_email:$_password');
          if (kIsWeb) {
            //FirebaseAuth not available for web
          } else {
            _attemptAccountCreation();
          }
        } else {
          print('Failed to validate fields');
        }
      },
    );
  }

  double _animatedContainerHeight() {
    if (loginPageState == LoginPageState.login) {
      //Login
      switch (loginState) {
        case StatusState.idle:
          return 290;
        case StatusState.failed:
          return 320;
          break;
        default:
          return 260;
          break;
      }
    } else {
      //Register
      switch (registerState) {
        case StatusState.idle:
          return 360;
          break;
        case StatusState.failed:
          return 390;
          break;
        case StatusState.pending:
          return 330;
          break;
        default:
          return 200;
          break;
      }
    }
  }
}
