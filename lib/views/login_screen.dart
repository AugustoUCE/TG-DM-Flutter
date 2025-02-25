import 'package:flutter/material.dart';
import 'package:persistencia/controllers/database_controller.dart';
import '../controllers/login_controller.dart';
import 'vehicle_list/vehicle_list_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool isDarkMode = true; // Inicialmente en modo oscuro

  @override
  void initState() {
    super.initState();
    final dbController = DatabaseController();
    WidgetsFlutterBinding.ensureInitialized();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isDarkMode ? const Color.fromARGB(190, 2, 8, 61) : Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode; // Alternar entre modos
              });
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [Color(0xFF1E1E2C), Color(0xFF2C2C34), Color(0xFF121212)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null, // Sin degradado en modo claro
          color: isDarkMode ? null : Colors.white, // Fondo blanco en modo claro
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: isDarkMode ? const Color(0xFF2C2C34) : Colors.white, // Fondo dinámico
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de nombre
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white54 : Colors.black26,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white54 : Colors.black26,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.blueAccent : Colors.blue,
                          ),
                        ),
                        filled: true,
                        fillColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
                      ),
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    // Campo de apellido
                    TextField(
                      controller: lastNameController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white54 : Colors.black26,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white54 : Colors.black26,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.blueAccent : Colors.blue,
                          ),
                        ),
                        filled: true,
                        fillColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
                      ),
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),

                    // Botón de ingreso
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF4A47A3)
                            : Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 50,
                        ),
                      ),
                      onPressed: () async {
                        if (await _controller.authenticate(
                          firstNameController.text,
                          lastNameController.text,
                        )) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VehicleListScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Credenciales inválidas')),
                          );
                        }
                      },
                      child: Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Enlace para registrarse
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        '¿No tienes cuenta? Regístrate aquí',
                        style: TextStyle(
                          color: isDarkMode ? Colors.blueAccent : Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
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