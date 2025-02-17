import 'package:flutter/material.dart';
import 'package:persistencia/controllers/database_controller.dart';
import 'package:persistencia/controllers/vehicle_controller.dart';
import 'package:persistencia/models/Vehicle.dart';
import 'package:persistencia/views/add_vehicle_screen.dart';
import 'package:persistencia/views/edit_vehicle_screen.dart';

class VehicleTableScreen extends StatefulWidget {
  @override
  _VehicleTableScreenState createState() => _VehicleTableScreenState();
}

class _VehicleTableScreenState extends State<VehicleTableScreen> {
  List<Vehicle> vehicles = [];
  final VehicleController _controller = VehicleController();
  final DatabaseController _databaseController = DatabaseController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    List<Vehicle> loadedVehicles = await DatabaseController().getVehicles();
    print('VEHICULOS CARGADOS');
    loadedVehicles.forEach((element) {
      print(element.plate);
    });
    setState(() {
      vehicles = loadedVehicles;
    });
  }

  Future<void> _addVehicle() async {
    final newVehicle = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVehicleScreen(controller: _controller),
      ),
    );
    if (newVehicle != null) {
      await _databaseController.insertVehicle(newVehicle);
      _loadVehicles();
    }
  }

  Future<void> _editVehicle(Vehicle vehicle) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditVehicleScreen(
          vehicle: vehicle,
          onVehicleEdited: (editedVehicle) async {
            await _databaseController.updateVehicle(editedVehicle, vehicle.plate);
            _loadVehicles();
          },
        ),
      ),
    );
  }

  void _deleteVehicle(String plate) async {
    await _databaseController.deleteVehicle(plate);
    _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabla de Vehículos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _addVehicle,
              child: Text('Agregar Vehículo'),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Placa')),
                      DataColumn(label: Text('Marca')),
                      DataColumn(label: Text('Fecha de Fabricación')),
                      DataColumn(label: Text('Color')),
                      DataColumn(label: Text('Costo')),
                      DataColumn(label: Text('Activo')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: vehicles.map((vehicle) {
                      return DataRow(
                        cells: [
                          DataCell(Text(vehicle.plate)),
                          DataCell(Text(vehicle.brand)),
                          DataCell(Text('${vehicle.manufactureDate.toLocal()}'.split(' ')[0])),
                          DataCell(Text(vehicle.color)),
                          DataCell(Text('\$${vehicle.cost.toStringAsFixed(2)}')),
                          DataCell(Text(vehicle.isActive ? 'Sí' : 'No')),
                          DataCell(
                            PopupMenuButton<String>(
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  _editVehicle(vehicle);
                                } else if (result == 'delete') {
                                  _deleteVehicle(vehicle.plate);
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Borrar'),
                                ),
                              ],
                            ),
                          ),
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