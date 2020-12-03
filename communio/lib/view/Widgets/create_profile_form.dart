import 'dart:convert';
import 'dart:io';
import 'package:communio/redux/actions.dart';

import 'package:communio/model/app_state.dart';
import 'package:communio/view/Widgets/image_upload.dart';
import 'package:communio/view/Widgets/insert_email_field.dart';
import 'package:communio/view/Widgets/insert_name_field.dart';
import 'package:communio/view/Widgets/insert_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

class CreateProfileForm extends StatefulWidget {
  @override
  CreateProfileFormState createState() {
    return CreateProfileFormState();
  }
}

class CreateProfileFormState extends State<CreateProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreedToTOS = false;

  final List interests = new List();
  final List programmingLanguages = new List();
  final List skills = new List();

  final nameController = TextEditingController();
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
              InsertNameField(nameController),
              InsertEmailField(emailController),
              InsertPasswordField(passwordController),
              buildTOSCheckbox(),
              buildSubmitButton(),
            ]));
  }

  buildTOSCheckbox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: GestureDetector(
          onTap: () => _setAgreedToTOS(!_agreedToTOS),
          child: Row(
            children: <Widget>[
              Checkbox(value: _agreedToTOS, onChanged: _setAgreedToTOS),
              Flexible(
                  child: const Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: TextStyle(fontSize: 12),
              ))
            ],
          )),
    );
  }

  submit() {
    if (!_agreedWithTerms()) {
      Toast.show('You must accept the TOS!', context);
      return;
    }


    if (_formKey.currentState.validate() && _agreedWithTerms()) {
      Toast.show('Processing Data', context, duration: 3);
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      if(name.length < 6){
        Toast.show('Name must have at least 6 characters!', context, duration: 5);
        return;
      } else
      if(password.length < 8){
        Toast.show('Password must have at least 8 characters!', context, duration: 5);
        return;
      }
      print("""
      Name: $name,
      Email: $email,
      Test Password: $password,
      Interests: $interests,
      Programming Languages: $programmingLanguages
      Skills: $skills""");
      var req = json.encode({
        "email": email,
        "fullname": name,
        "password": password,
      });

      this.addPerson(context, req).then((response) {
        if (response['status'] != 200) {
          Toast.show(response['msg'], context, duration: 10);
          return;
        }

        getUser(context, email).then((value) {
            StoreProvider.of<AppState>(context).dispatch(UpdateUser(value));
            Navigator.of(context).pushNamed('/Homepage');
        });

      });
      final testPassword = passwordController.text.trim();
    }
  }

  Widget buildSubmitButton() {
    final width = MediaQuery.of(context).size.width * 0.5;
    final height = MediaQuery.of(context).size.width * 0.15;

    return Padding(
        padding: EdgeInsets.only(bottom: 10),
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
                    'Sign Up',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .apply(fontSizeDelta: -5),
                  ),
                ))));
  }

  Future<String> getUser(BuildContext context, String email) async {
    final store = StoreProvider.of<AppState>(context);
    final response = await http.get('${store.state.content['profile']}');
    var map = json.decode(utf8.decode(response.bodyBytes));
    var id;
    for (var item in map) {
      if (item['email'] == email) {
        id = item['_id'];
        break;
      }
    }
    return id;
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

  bool _agreedWithTerms() {
    return _agreedToTOS;
  }

  void _setAgreedToTOS(bool value) {
    setState(() {
      _agreedToTOS = value;
    });
  }
}
