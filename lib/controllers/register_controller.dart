import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:persistencia/controllers/database_controller.dart';
import 'package:persistencia/controllers/login_controller.dart';

import '../models/User.dart';

class RegisterController {
  final LoginController _loginController = LoginController();
  final DatabaseController _dbController = DatabaseController();
 

  Future<bool> registerUser( String firstName, String lastName) async {
    if ( firstName.isEmpty || lastName.isEmpty) {
      return false;
    }
    if (_loginController.users.value.any((user) => user.firstName == firstName)) {
      return false;
    }
    final encryptedLastName = sha512.convert(utf8.encode(lastName)).toString();
    final newUserId = await _dbController.generateId( 'user_id_seq');
    final newUser = User(
      id: newUserId,
      firstName: firstName,
      lastName: encryptedLastName,
       
    );
    _dbController.insertUser(newUser);
    _loginController.users.value.add(newUser);

    return true;
  }
}