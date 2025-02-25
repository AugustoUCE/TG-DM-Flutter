import 'package:flutter/material.dart';
import 'package:persistencia/controllers/database_controller.dart';
import 'package:persistencia/controllers/login_controller.dart';
import 'package:persistencia/controllers/vehicle_controller.dart';
import 'package:persistencia/views/login_screen.dart';
import 'dart:io';
import 'vehicle_list/widgets/error_dialog.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  late DatabaseController dbController;

  @override
  void initState() {
    super.initState();
    dbController = DatabaseController();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await dbController.connect();
    } on SocketException {
      _showErrorDialog("No tienes conexión a internet, inténtalo más tarde");
    } catch (e) {
      _showErrorDialog("Algo ha salido mal, vuelve a intentarlo más tarde");
    }

    await dbController.createTables();
    await LoginController().checkPermissions();
    await LoginController().loadJsonFromFile();
    await VehicleController().loadVehiclesFromFile();

    // Navegar a la pantalla principal después de la inicialización
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Pantalla de carga mientras se inicializa
      ),
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehículos App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
