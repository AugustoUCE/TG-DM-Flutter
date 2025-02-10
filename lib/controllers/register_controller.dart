import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:persistencia/controllers/database_controller.dart';
import 'package:persistencia/controllers/login_controller.dart';

import '../models/User.dart';

class RegisterController {
  final LoginController _loginController = LoginController();
  final DatabaseController _dbController = DatabaseController();
 
  String _encryptPassword(String lastName) {
    final bytes = utf8.encode(lastName);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  bool registerUser( String firstName, String lastName) {
    if (firstName.isEmpty || lastName.isEmpty) {
      return false;
    }
    if (_loginController.users.value.any((user) => user.firstName == firstName)) {
      return false;
    }
    final encryptedLastName = _encryptPassword(lastName);
    final newUser = User(
      id: _dbController.generateId(),
      firstName: firstName,
      lastName: encryptedLastName,
       
    );
    _dbController.insertUser(newUser);
    _loginController.users.value.add(newUser);

    return true;
  }
}