import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistencia/controllers/database_controller.dart';

import '../models/User.dart';

class LoginController {
  LoginController._singleton();

  static final LoginController _mismaInstancia = LoginController._singleton();
  static final DatabaseController _databaseController = DatabaseController();

  factory LoginController() => _mismaInstancia;

  ValueNotifier<List<User>> users = ValueNotifier<List<User>>([]);

  Future<void> agregarNuevosUsuarios() async {
    List<User> usersAWS = await _databaseController.getUsers();
    final newUsers = usersAWS.where((user) =>
    !users.value.any((existingUser) => existingUser.id == user.id)
    ).toList();
    if (newUsers.isNotEmpty) {
      users.value.addAll(newUsers);
      // print('---------------------NADIE NUEVO---------------------');
    }
  }

  // funcion para autenticar usando nombre y apellido
  Future<bool> authenticate(String firstName, String lastName) async {
    // Encriptar el apellido ingresado para comparative
    // final encryptedInputLastName = _encryptPassword(lastName);

    agregarNuevosUsuarios();

    final encryptedLastName = sha512.convert(utf8.encode(lastName)).toString();

    return users.value.any((user) =>
    user.firstName == firstName && user.lastName == encryptedLastName);
  }

  // Future<bool> authenticate(String firstName, String lastName) async {
  //   // Encriptar el apellido ingresado
  //   final encryptedLastName = sha512.convert(utf8.encode(lastName)).toString();
  //
  //   // Obtener todos los usuarios
  //   List<User> users = await _databaseController.getUsers();
  //   users.forEach((e) => print(e.firstName + '\n' + e.lastName));
  //   // printUsers(); // Verificacion del usuario con el nombre y el apellido encriptado
  //   print(encryptedLastName);
  //   print(encryptedLastName);
  //   print(encryptedLastName);
  //   print(encryptedLastName);
  //   // Verificar las credenciales
  //   return users.any((user) =>
  //       user.firstName == firstName && user.lastName == encryptedLastName);
  //   // for (User user in users) {
  //   //   print('Comparando con usuario: ${user.toJson()}');
  //   //   if (user.firstName == firstName && user.lastName == encryptedLastName) {
  //   //     print('Inicio de sesión exitoso');
  //   //     return true;
  //   //   }
  //   // }
  //   // print('Credenciales incorrectas');
  //   // return false;
  // }

  //ver si se modifica la lista
  void printUsers() {
    for (var user in users.value) {
      print(
          'Nombre: ${user.firstName}, Apellido (encriptado): ${user.lastName}');
    }
  }

  // PARA JSON

  Future<void> saveJsonToFile() async {
    String jsonString =
    jsonEncode(users.value.map((user) => user.toJson()).toList());
    if (Platform.isAndroid) {
      if (await checkPermissions()) {
        try {
          // ruta en general de donde se guardara el archivo
          final directory = Directory('/storage/emulated/0/Download');
          final file = File('${directory.path}/users.json');
          await file.writeAsString(jsonString);
          print('Archivo guardado en: ${file.path}');
        } catch (e) {
          print('Error al guardar el archivo: $e');
        }
      } else {
        print('Permiso de almacenamiento denegado');
      }
    } else if (Platform.isWindows) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final file = File('$path/users.json');
        await file.writeAsString(jsonString);
        print('Archivo guardado en: $path/users.json');
      } catch (e) {
        print('Error al guardar el archivo: $e');
      }
    } else {
      print('Plataforma no soportada');
    }
  }

  Future<void> loadDB() async {
    // final fetchedUsers = await _databaseController.getUsers();
    // for (var fusr in fetchedUsers) {
    //   users.value.add(fusr);
    // }

    final List<User> fetchedUsers = (await _databaseController.getUsers());
    //DB
    users.value = fetchedUsers;

    // users = fetchedUsers;
  }

  Future<void> saveDB() async {
    final existingUsers = await _databaseController.getUsers();
    for (var user in users.value) {
      if (!existingUsers.any((u) => u.firstName == user.firstName)) {
        await _databaseController.insertUser(user);
      }
    }
  }

  Future<void> loadJsonFromFile() async {
    try {
      if (Platform.isAndroid || Platform.isWindows) {
        final directory = Platform.isAndroid
            ? Directory('/storage/emulated/0/Download')
            : await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/users.json');

        if (await file.exists()) {
          final jsonString = await file.readAsString();
          final List<dynamic> jsonList = jsonDecode(jsonString);
          users.value.clear();
          users.value
              .addAll(jsonList.map((json) => User.fromJson(json)).toList());

          print('Datos cargados exitosamente desde el archivo.');
        } else {
          print('El archivo no existe, se usará la lista predeterminada.');
        }
      } else {
        print('Plataforma no soportada para leer datos.');
      }
    } catch (e) {
      print('Error al cargar los datos: $e');
    }
  }

  //necesario para pedir permisooos
  Future<bool> checkPermissions() async {
    final status = await Permission.storage.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      return await Permission.manageExternalStorage
          .request()
          .isGranted;
    }
    return status.isGranted;
  }

  //un guardado general de los datos users
  Future<void> saveData() async {
    await saveJsonToFile();
    await saveDB();
  }
}
