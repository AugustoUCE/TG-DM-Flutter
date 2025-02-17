import 'package:postgres/postgres.dart';

class DatabaseService {
  late PostgreSQLConnection _connection;

  DatabaseService() {
    _connection = PostgreSQLConnection(
      "dbautohub.camfbgvuh5re.us-east-1.rds.amazonaws.com", // O usa "host.docker.internal" si es en Docker
      5432, 
      "autohub", 
      username: "autohub", 
      password: "2025autohub\$17",
      useSSL: true	,
    );
  }

  Future<void> conectar() async {
    try {
      await _connection.open();
      print("✅ Conectado a PostgreSQL");
    } catch (e) {
      print("❌ Error al conectar: $e");
    }
  }

  Future<void> cerrarConexion() async {
    await _connection.close();
    print("🔴 Conexión cerrada");
  }


}