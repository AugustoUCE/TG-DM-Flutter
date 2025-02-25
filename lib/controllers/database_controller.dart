import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';
import 'package:persistencia/models/User.dart';
import 'package:persistencia/models/Vehicle.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseController {
  static final DatabaseController _instance = DatabaseController._internal();

  factory DatabaseController() => _instance;

  DatabaseController._internal();

  late PostgreSQLConnection _connection;

  Future<void> createUserSequence() async {
    await _connection.query(r'''
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'user_id_seq') THEN
          CREATE SEQUENCE user_id_seq START 1;
        END IF;
      END
      $$;
    ''');
  }

  Future<void> createVehicleSequence() async {
    await _connection.query(r'''
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'vehicle_id_seq') THEN
          CREATE SEQUENCE vehicle_id_seq START 1;
        END IF;
      END
      $$;
    ''');
  }

  Future<int> generateId(String sequenceName) async {
    final result = await _connection
        .query('SELECT nextval(@sequenceName)', substitutionValues: {
      'sequenceName': sequenceName,
    });
    return result.first.first as int;
  }

  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      dotenv.env['AWS_URL']!,
      int.parse(dotenv.env['URL_PORT']!),
      "postgres",
      username: dotenv.env['AWS_USERNAME']!,
      password: dotenv.env['AWS_PASSWORD']!,
      useSSL: true,
    );
    await _connection.open();
    await createTables();
    await insertUsersList(users);
  }

  Future<void> closeConnection() async {
    await _connection.close();
  }

  Future<void> createTables() async {
    await _connection.query('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL
      );
    ''');

    await _connection.query('''
      CREATE TABLE IF NOT EXISTS vehicles (
        id SERIAL PRIMARY KEY,
        plate TEXT NOT NULL UNIQUE,
        brand TEXT NOT NULL,
        manufactureDate DATE NOT NULL,
        color TEXT NOT NULL,
        cost REAL NOT NULL,
        isActive BOOLEAN NOT NULL,
        imageUrl TEXT
      );
    ''');

    await createUserSequence();
    await createVehicleSequence();
  }

  String _encryptLastName(String lastName) {
    final bytes = utf8.encode(lastName);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  // CRUD for Users
  Future<int> insertUser(User user) async {
    final id = await generateId('user_id_seq');
    final encryptedLastName = user.lastName;
    final result = await _connection.query(
      'INSERT INTO users (id, firstName, lastName) VALUES (@id, @firstName, @lastName) RETURNING id',
      substitutionValues: {
        'id': id,
        'firstName': user.firstName,
        'lastName': encryptedLastName,
      },
    );
    return result.first[0];
  }

  Future<int> insertUserIfNotExists(User user) async {
    // Verificar si el usuario ya existe
    final result = await _connection.query(
      'SELECT id FROM users WHERE firstName = @firstName AND lastName = @lastName',
      substitutionValues: {
        'firstName': user.firstName,
        'lastName': user.lastName,
      },
    );

    if (result.isNotEmpty) {
      // El usuario ya existe, no insertar
      return result.first[0];
    }

    // Insertar el usuario si no existe
    final id = await generateId('user_id_seq');
    final encryptedLastName = user.lastName;
    final insertResult = await _connection.query(
      'INSERT INTO users (id, firstName, lastName) VALUES (@id, @firstName, @lastName) RETURNING id',
      substitutionValues: {
        'id': id,
        'firstName': user.firstName,
        'lastName': encryptedLastName,
      },
    );
    return insertResult.first[0];
  }

  Future<void> insertUsersList(List<User> users) async {
    for (var user in users) {
      await insertUserIfNotExists(user);
    }
  }

  Future<int> updateUser(User user) async {
    final encryptedLastName = _encryptLastName(user.lastName);
    final result = await _connection.query(
      'UPDATE users SET firstName = @firstName, lastName = @lastName WHERE id = @id',
      substitutionValues: {
        'id': user.id,
        'firstName': user.firstName,
        'lastName': encryptedLastName,
      },
    );
    return result.affectedRowCount;
  }

  Future<int> deleteUser(int id) async {
    final result = await _connection.query(
      'DELETE FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );
    return result.affectedRowCount;
  }

  Future<List<User>> getUsers() async {
    final result = await _connection.query('SELECT * FROM users');
    return result.map((row) {
      return User(
        id: row[0],
        firstName: row[1],
        lastName: row[2],
      );
    }).toList();
  }

  // CRUD for Vehicles
  Future<int> insertVehicle(Vehicle vehicle) async {
    final id = await generateId('vehicle_id_seq');
    final result = await _connection.query(
      'INSERT INTO vehicles (id, plate, brand, manufactureDate, color, cost, isActive, imageUrl) VALUES (@id, @plate, @brand, @manufactureDate, @color, @cost, @isActive, @imageUrl) RETURNING id',
      substitutionValues: {
        'id': id,
        'plate': vehicle.plate,
        'brand': vehicle.brand,
        'manufactureDate': vehicle.manufactureDate.toIso8601String(),
        'color': vehicle.color,
        'cost': vehicle.cost,
        'isActive': vehicle.isActive,
        'imageUrl': vehicle.imageUrl,
      },
    );
    return result.first[0];
  }

  Future<int> updateVehicle(Vehicle vehicle, String plate) async {
    final result = await _connection.query(
      'UPDATE vehicles SET plate = @plate, brand = @brand, manufactureDate = @manufactureDate, color = @color, cost = @cost, isActive = @isActive, imageUrl = @imageUrl WHERE plate = @plate',
      substitutionValues: {
        'plate': plate,
        'brand': vehicle.brand,
        'manufactureDate': vehicle.manufactureDate.toIso8601String(),
        'color': vehicle.color,
        'cost': vehicle.cost,
        'isActive': vehicle.isActive,
        'imageUrl': vehicle.imageUrl,
      },
    );
    return result.affectedRowCount;
  }

  Future<int> deleteVehicle(String plate) async {
    final result = await _connection.query(
      'DELETE FROM vehicles WHERE plate = @plate',
      substitutionValues: {'plate': plate},
    );
    return result.affectedRowCount;
  }

  Future<List<Vehicle>> getVehicles() async {
    final result = await _connection.query('SELECT * FROM vehicles');
    return result.map((row) {
      return Vehicle(
        id: row[0],
        plate: row[1],
        brand: row[2],
        manufactureDate: DateTime.parse(row[3].toString()), // Ensure correct parsing
        color: row[4],
        cost: row[5],
        isActive: row[6],
        imageUrl: row[7],
      );
    }).toList();
  }

  List<User> users = [
    User(
      id: 1,
      firstName: 'Emil',
      lastName:
          '651682a417b65991d6d0b7e55bf6eb1a67ea35e74295c075dada8c67e6695e4402011f3ed3dfc4e503ed7843177a9c9d34cd22722eacba94d45334d0ad7d3a9c',
    ),
    User(
      id: 2,
      firstName: 'Kevin',
      lastName:
          '4a8d708913dbf3745c9769f9a5c1b3a65b68a3ad390f8019a4c6298b328b6adcbdba54be92d591fad42f63cd643b99f80e5c53ceb43c58eb57ded7847ca9f9eb',
    ),
    User(
      id: 3,
      firstName: 'Jhon',
      lastName:
          'f04ab399ef59f5d7fe15e67d95020101c10ab976fa033cddfbecbb88ce10710e3fa5c231eef5c4440362011d6bb2bbdaf7032ba20d220684e7d22d8202d8085e',
    ),
    User(
      id: 4,
      firstName: 'Augusto',
      lastName:
          '89be58831b2778569e2327034092572ddfd10ef89860fb4492939920bd44e509fb35efd0b0eafa3925fae8a1bc430288f9c20546c5f3dbf5d82db2aac99d8591',
    ),
  ];
}
