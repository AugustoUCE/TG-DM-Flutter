import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:persistencia/controllers/database_controller.dart';
import 'package:persistencia/controllers/login_controller.dart';
import 'package:persistencia/controllers/vehicle_controller.dart';
import 'package:persistencia/services/life_cycle_manager.dart';
import 'package:persistencia/views/init_screen.dart';
import 'package:persistencia/views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    LifecycleManager(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: InitScreen(), // Pantalla de inicialización
      ),
    ),
  );
}

