import 'package:flutter/material.dart';
import 'package:persistencia/controllers/database_controller.dart';
import 'package:persistencia/models/Rec.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final DatabaseController _controller = DatabaseController();
  final TextEditingController att1Controller = TextEditingController();
  final TextEditingController semm2Controller = TextEditingController();
  static String? text;

  @override
  void initState() {
    iniciar();
    super.initState();
  }

  Future<void> iniciar() async {
    Rec texto = await _controller.getRec();
    setState(() {
      text = texto.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pass',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(190, 2, 8, 61),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF2C2C34), Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), // Sin degradado en modo claro
          color: null, // Fondo blanco en modo claro
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: const Color(0xFF2C2C34), // Fondo dinámico
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    Text(
                      text!,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de nombre
                    TextField(
                      controller: att1Controller,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.white54,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.white54,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E2C),
                      ),
                      style: TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    // Campo de apellido
                    TextField(
                      controller: semm2Controller,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        labelStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.white54,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.white54,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E2C),
                      ),
                      style: TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),

                    // Botón de ingreso
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 50,
                        ),
                      ),
                      onPressed: () async {
                        await _controller.insertRec(Rec(0,
                            att1Controller.text, semm2Controller.text));
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
