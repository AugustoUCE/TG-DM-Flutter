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

  ValueNotifier<List<User>> users = ValueNotifier<List<User>>([
    User(
      id: 1,
        firstName: 'Emil',
        lastName:
            '651682a417b65991d6d0b7e55bf6eb1a67ea35e74295c075dada8c67e6695e4402011f3ed3dfc4e503ed7843177a9c9d34cd22722eacba94d45334d0ad7d3a9c'),
    User(
        id: 2,
        firstName: 'Kevin',
        lastName:
            '4a8d708913dbf3745c9769f9a5c1b3a65b68a3ad390f8019a4c6298b328b6adcbdba54be92d591fad42f63cd643b99f80e5c53ceb43c58eb57ded7847ca9f9eb'),
    User(
        id: 3,
        firstName: 'Jhon',
        lastName:
            'f04ab399ef59f5d7fe15e67d95020101c10ab976fa033cddfbecbb88ce10710e3fa5c231eef5c4440362011d6bb2bbdaf7032ba20d220684e7d22d8202d8085e'),
    User(
        id: 4,
        firstName: 'Augusto',
        lastName:
            '89be58831b2778569e2327034092572ddfd10ef89860fb4492939920bd44e509fb35efd0b0eafa3925fae8a1bc430288f9c20546c5f3dbf5d82db2aac99d8591'),
  ]);

  // Método para autenticar usando nombre y apellido
  // Future<bool>
  bool authenticate(String firstName, String lastName) {
    // Encriptar el apellido ingresado para comparación
    // final encryptedInputLastName = _encryptLastName(lastName);

        final encryptedLastName =
        sha512.convert(utf8.encode(lastName)).toString();
    // printUsers(); // Verificacion del usuario con el nombre y el apellido encriptado
    // print(encryptedInputLastName);

    return users.value.any((user) =>
        user.firstName == firstName && user.lastName == encryptedLastName);
  }

  // Future<bool> authenticate(String firstName, String lastName) async {
  //   try {
  //     // Encriptar el apellido ingresado
  //     final encryptedLastName =
  //     sha512.convert(utf8.encode(lastName)).toString();
  //
  //     // Obtener todos los usuarios
  //     List<User> users = await _databaseController.getUsers();
  //
  //     // Verificar las credenciales
  //     for (User user in users) {
  //       print('Comparando con usuario: ${user.toJson()}');
  //       if (user.firstName == firstName && user.lastName == encryptedLastName) {
  //         print('Inicio de sesión exitoso');
  //         return true;
  //       }
  //     }
  //     print('Credenciales incorrectas');
  //     return false;
  //   } catch (e) {
  //     print('Error al iniciar sesión: $e');
  //     return false;
  //   }
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
      return await Permission.manageExternalStorage.request().isGranted;
    }
    return status.isGranted;
  }

  //un guardado general de los datos users
  Future<void> saveData() async {
    await saveJsonToFile();
    await saveDB();
  } 
}