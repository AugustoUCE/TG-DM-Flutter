import 'package:flutter/material.dart';
import 'package:persistencia/controllers/database_controller.dart';
import 'package:persistencia/models/User.dart';

class UserTableScreen extends StatefulWidget {
  @override
  UserTableScreenState createState() => UserTableScreenState();
}

class UserTableScreenState extends State<UserTableScreen> {
  // Lista para almacenar los vehículos
  List<User> vehicles = [];

  @override
  void initState() {
    super.initState();
    // Cargar vehículos desde la base de datos cuando la pantalla se inicializa
    _loadUsers();
  }

  // Cargar vehículos desde la base de datos
  Future<void> _loadUsers() async {
    List<User> loadedUsers = await DatabaseController().getUsers();

    print('USERS CARGADOS');
    loadedUsers.forEach((element) {
      print(element.firstName);
    });

    setState(() {
      vehicles = loadedUsers;
    });
  }

  // // Método para agregar un vehículo
  // Future<void> _addUser() async {
  //   // User newUser = User(
  //   //   plate: 'NEW123',
  //   //   brand: 'Chevrolet',
  //   //   manufactureDate: DateTime(2023, 3, 15),
  //   //   color: 'Green',
  //   //   cost: 18000.00,
  //   //   isActive: true,
  //   // );
  //   //
  //   // // Guardar en la base de datos
  //   // await DatabaseController().insertUser(newUser);
  //
  //   // Actualizar la tabla después de agregar el vehículo
  //   _loadUsers();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Usuarios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Apellido Encriptado')),
                    ],
                    rows: vehicles.map((vehicle) {
                      return DataRow(
                        cells: [
                          DataCell(Text(vehicle.firstName)),
                          DataCell(Text(
                              "...${vehicle.lastName.substring(vehicle.lastName.length - 4)}")),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}