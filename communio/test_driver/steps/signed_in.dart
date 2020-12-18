import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';

class IsSignedIn extends Given1WithWorld<String, FlutterWorld>{
  @override
  Future<void> executeStep(String input1) async {
    //if(driver.find.byValueKey(input1) == null)
      //fail("No one is signed in!");
  }

  @override
  RegExp get pattern => RegExp(r"The user {string} that is signed in");
}