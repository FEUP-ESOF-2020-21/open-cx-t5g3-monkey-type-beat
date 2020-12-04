import 'dart:convert';
import 'dart:io';
import 'package:communio/model/known_person.dart';
import 'package:communio/redux/actions.dart';

import 'package:communio/model/app_state.dart';
import 'package:communio/view/Widgets/image_upload.dart';
import 'package:communio/view/Widgets/insert_email_field.dart';
import 'package:communio/view/Widgets/insert_password_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

class LogInForm extends StatefulWidget {
  @override
  LogInFormState createState() {
    return LogInFormState();
  }
}

class LogInFormState extends State<LogInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: ImageUpload()),
              InsertEmailField(emailController),
              InsertPasswordField(passwordController),
              buildSubmitButton(),
            ]));
  }


  submit() {


    if (_formKey.currentState.validate()) {
      Toast.show('Processing Data', context, duration: 3);
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      if(password.length < 8){
        Toast.show('Password must have at least 8 characters!', context, duration: 5);
        return;
      }
      print("""
      Email: $email,
      Test Password: $password""");
      
      this.getUser(context, email, password).then((value) {
        if(value == null){
          Toast.show('Couldn\'t find user/password combination', context);
          return;
        }
        StoreProvider.of<AppState>(context).dispatch(UpdateUser(value.uuid));
        Navigator.of(context).pushNamed('/Homepage');
      });
    }
  }

  Widget buildSubmitButton() {
    final width = MediaQuery.of(context).size.width * 0.5;
    final height = MediaQuery.of(context).size.width * 0.15;

    return Padding(
        padding: EdgeInsets.only(bottom: 10, top: 30),
        child: Center(
            child: ButtonTheme(
                minWidth: width,
                height: height,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(height * 0.25)),
                  textColor: Theme.of(context).canvasColor,
                  onPressed: () {
                    submit();
                  },
                  child: Text(
                    'Log In',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .apply(fontSizeDelta: -5),
                  ),
                ))));
  }

  Future<KnownPerson> getUser(BuildContext context, String email, String password) async {
    final store = StoreProvider.of<AppState>(context);
    final response = await http.get('${store.state.content['profile']}');
    var map = json.decode(utf8.decode(response.bodyBytes));
    var user_id = null;
    for (var item in map) {
      if (item['email'] == email) {
        user_id = item['_id'];
        break;
      }
    }
    if(user_id == null) return null;
    final user = await http.get('${store.state.content['profile']}/profile/'+user_id);
    final map2 = json.decode(utf8.decode(user.bodyBytes));
    var u = KnownPerson.fromJson(map2);

    if(map2['password'] != password) return null;
    return u;
  }

  Future<Map<String,Object>> addPerson(BuildContext context, reg) async {
    final store = StoreProvider.of<AppState>(context);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var response = await http.post(store.state.content['profile'] + '/register',
        body: reg, headers: headers);
    print(utf8.decode(response.bodyBytes));
    print(response.statusCode);
    return {"status": response.statusCode, "msg": utf8.decode(response.bodyBytes)};
  }


}
