import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/Vehicle.dart';
import '../controllers/vehicle_controller.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleController controller;

  const AddVehicleScreen({
    super.key,
    required this.controller,
  });

  @override
  AddVehicleScreenState createState() => AddVehicleScreenState();
}

class AddVehicleScreenState extends State<AddVehicleScreen> {
  final TextEditingController letterController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String selectedColor = 'Blanco';
  bool isActive = false;
  DateTime? selectedDate;
  String? imageUrl;

   int generateId() {
    // Implementación para generar un ID único como entero
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text =
            '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
      });
    }
  }
    Future<void> _showImageSourceSelection() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capturar Foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de la Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageUrl = pickedFile.path; // Actualiza la URL con la nueva imagen
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Vehículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
           GestureDetector(
                onTap: _showImageSourceSelection,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl != null
                      ? FileImage(File(imageUrl!))
                      : AssetImage('assets/default_image.png') as ImageProvider,
                  child: imageUrl == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: letterController,
                      maxLength: 3,
                      decoration: const InputDecoration(labelText: 'Letras'),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: numberController,
                      maxLength: 4,
                      decoration: const InputDecoration(labelText: 'Números'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Fabricación',
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField(
                value: selectedColor,
                items: ['Blanco', 'Negro', 'Azul']
                    .map((color) =>
                        DropdownMenuItem(value: color, child: Text(color)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColor = value as String;
                  });
                },
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: costController,
                decoration: const InputDecoration(labelText: 'Costo'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('Activo'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Por favor selecciona una fecha.')),
                    );
                    return;
                  }
                  final plate =
                      '${letterController.text}-${numberController.text}';
                  final vehicle = Vehicle(
                   id: generateId(),
                    plate: plate,
                    brand: brandController.text,
                    manufactureDate: selectedDate!,
                    color: selectedColor,
                    cost: double.parse(costController.text),
                    isActive: isActive,
                    imagePath: imageUrl,
                  );
                  Navigator.pop(context, vehicle);
                  // DatabaseController().insertVehicle(vehicle);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
