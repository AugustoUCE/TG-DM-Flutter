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

  // func para autenticar usando nombre y apellido
  Future<bool> authenticate(String firstName, String lastName) async {
    // Obtener usuarios de la base de datos
    final List<User> fetchedUsers = await DatabaseController().getUsers();
    // print("Fetched Users: $fetchedUsers"); // Depuración

    // Encriptar el apellido ingresado
    final encryptedLastName = sha512.convert(utf8.encode(lastName)).toString();
    print("Encrypted LastName: $encryptedLastName"); // Depuración

    // Verificar si hay coincidencias
    final isAuthenticated = fetchedUsers.any((user) {
      final isFirstNameMatch = user.firstName.toLowerCase() == firstName.toLowerCase();
      final isLastNameMatch = user.lastName == encryptedLastName;
      return isFirstNameMatch && isLastNameMatch;
    });

    print("Authentication Result: $isAuthenticated"); // Depuración
    return isAuthenticated;
  }
  // Future<bool> authenticate(String firstName, String lastName) async {
  //   // Encriptar el apellido ingresado para comparación
  //   // final encryptedInputLastName = _encryptLastName(lastName);
  //   final List<User> fetchedUsers = await DatabaseController().getUsers();
  //   final encryptedLastName = sha512.convert(utf8.encode(lastName)).toString();
  //   // printUsers(); // Verificacion del usuario con el nombre y el apellido encriptado
  //   // print(encryptedInputLastName);
  //   _mismaInstancia.users.value.forEach((u)=>print(u.firstName));
  //
  //   return fetchedUsers.any((user) =>
  //       user.firstName == firstName && user.lastName == encryptedLastName);
  // }
/////////////////////////////////////////////////////////////////


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

    final List<User> fetchedUsers = await DatabaseController().getUsers();

// Convertir users.value a un Set temporal para evitar duplicados
    final Set<User> uniqueUsers = users.value.toSet();

// Agregar usuarios de fetchedUsers al Set
    uniqueUsers.addAll(fetchedUsers);

// Actualizar users.value con los usuarios únicos
    LoginController().users.value.clear();
    LoginController().users.value.addAll(uniqueUsers) ;
    //DB
    print(LoginController().users.value);
    fetchedUsers.forEach((user) => print(user.firstName + user.lastName));

    // LoginController().printUsers();

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
