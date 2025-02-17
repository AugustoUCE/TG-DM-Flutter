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
    await _connection.query('''
      CREATE SEQUENCE IF NOT EXISTS user_id_seq START 10;
    ''');
  }

  Future<void> createVehicleSequence() async {
    await _connection.query('''
      CREATE SEQUENCE IF NOT EXISTS vehicle_id_seq START 1;
    ''');
  }

  Future<int> generateId(String sequenceName) async {
    final result = await _connection.query('SELECT nextval(@sequenceName)', substitutionValues: {
      'sequenceName': sequenceName,
    });
    return result.first.first as int;
  }

  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      "dbautohub.camfbgvuh5re.us-east-1.rds.amazonaws.com",
      5432,
      "autohub",
      username: "autohub",
      password: "2025autohub\$17",
      useSSL: true,
    );
    await _connection.open();
    await createUserSequence();
    await createVehicleSequence();
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
    INSERT OR IGNORE INTO users (id, firstName, lastName) VALUES
    (1, 'Emil', '651682a417b65991d6d0b7e55bf6eb1a67ea35e74295c075dada8c67e6695e4402011f3ed3dfc4e503ed7843177a9c9d34cd22722eacba94d45334d0ad7d3a9c'),
    (2, 'Kevin', '4a8d708913dbf3745c9769f9a5c1b3a65b68a3ad390f8019a4c6298b328b6adcbdba54be92d591fad42f63cd643b99f80e5c53ceb43c58eb57ded7847ca9f9eb'),
    (3, 'Jhon', 'f04ab399ef59f5d7fe15e67d95020101c10ab976fa033cddfbecbb88ce10710e3fa5c231eef5c4440362011d6bb2bbdaf7032ba20d220684e7d22d8202d8085e'),
    (4, 'Augusto', '89be58831b2778569e2327034092572ddfd10ef89860fb4492939920bd44e509fb35efd0b0eafa3925fae8a1bc430288f9c20546c5f3dbf5d82db2aac99d8591')
    ON CONFLICT DO NOTHING;
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
        imagePath TEXT
      );
    ''');
  }

  String _encryptLastName(String lastName) {
    final bytes = utf8.encode(lastName);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  // CRUD for Users
  Future<int> insertUser(User user) async {
    final id = await generateId('user_id_seq');
    final encryptedLastName = _encryptLastName(user.lastName);
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
      'INSERT INTO vehicles (id, plate, brand, manufactureDate, color, cost, isActive, imagePath) VALUES (@id, @plate, @brand, @manufactureDate, @color, @cost, @isActive, @imagePath) RETURNING id',
      substitutionValues: {
        'id': id,
        'plate': vehicle.plate,
        'brand': vehicle.brand,
        'manufactureDate': vehicle.manufactureDate.toIso8601String(),
        'color': vehicle.color,
        'cost': vehicle.cost,
        'isActive': vehicle.isActive,
        'imagePath': vehicle.imagePath,
      },
    );
    return result.first[0];
  }

  Future<int> updateVehicle(Vehicle vehicle, String plate) async {
    final result = await _connection.query(
      'UPDATE vehicles SET plate = @plate, brand = @brand, manufactureDate = @manufactureDate, color = @color, cost = @cost, isActive = @isActive, imagePath = @imagePath WHERE plate = @plate',
      substitutionValues: {
        'plate': plate,
        'brand': vehicle.brand,
        'manufactureDate': vehicle.manufactureDate.toIso8601String(),
        'color': vehicle.color,
        'cost': vehicle.cost,
        'isActive': vehicle.isActive,
        'imagePath': vehicle.imagePath,
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
        manufactureDate: DateTime.parse(row[3]),
        color: row[4],
        cost: row[5],
        isActive: row[6],
        imagePath: row[7],
      );
    }).toList();
  }
}