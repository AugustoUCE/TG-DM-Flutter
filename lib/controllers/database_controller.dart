import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

import 'package:persistencia/models/User.dart';
import 'package:persistencia/models/Vehicle.dart';

import 'package:sqflite/sqflite.dart';

class DatabaseController {
  int generateId() {
    // Implementación para generar un ID único como entero
    return DateTime.now().millisecondsSinceEpoch;
  }
  static final DatabaseController _instance = DatabaseController._internal();

  factory DatabaseController() => _instance;

  static Database? _database;

  DatabaseController._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT NOT NULL,
            lastName TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plate TEXT NOT NULL UNIQUE,
            brand TEXT NOT NULL,
            manufactureDate TEXT NOT NULL,
            color TEXT NOT NULL,
            cost REAL NOT NULL,
            isActive INTEGER NOT NULL,
            imagePath TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE vehicles ADD COLUMN imagePath TEXT');
        }
      },
    );
  }

  String _encryptLastName(String lastName) {
    final bytes = utf8.encode(lastName);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  // CRUD for Users
  Future<int> insertUser(User user) async {
    final db = await database;
    final encryptedLastName = _encryptLastName(user.lastName);
    final userWithEncryptedLastName = User(
      id: user.id,
      firstName: user.firstName,
      lastName: encryptedLastName,
    );
    return await db.insert('users', userWithEncryptedLastName.toMap());
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    final encryptedLastName = _encryptLastName(user.lastName);
    return await db.update(
      'users',
      {
        'firstName': user.firstName,
        'lastName': encryptedLastName,
      },
      where: 'firstName = ? AND lastName = ?',
      whereArgs: [user.firstName, user.lastName],
    );
  }

  Future<int> deleteUser(String firstName, String lastName) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'firstName = ? AND lastName = ?',
      whereArgs: [firstName, lastName],
    );
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        firstName: maps[i]['firstName'],
        lastName: maps[i]['lastName'],
      );
    });
  }

  // CRUD for Vehicles
  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert('vehicles', vehicle.toMap());
  }

  Future<int> updateVehicle(Vehicle vehicle, String plate) async {
    print("vehicle: ${vehicle.plate}");

    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'plate = ?',
      whereArgs: [plate],
    );
  }

  Future<int> deleteVehicle(String plate) async {
    final db = await database;
    return await db.delete(
      'vehicles',
      where: 'plate = ?',
      whereArgs: [plate],
    );
  }

  Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vehicles');

    return List.generate(maps.length, (i) {
      return Vehicle(
        id: maps[i]['id'],
        plate: maps[i]['plate'],
        brand: maps[i]['brand'],
        manufactureDate: DateTime.parse(maps[i]['manufactureDate']),
        color: maps[i]['color'],
        cost: maps[i]['cost'],
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }

  Future<void> initializeDefaultUsers() async {
    final List<User> users = [
      User(
          id: generateId(),
          firstName: 'Emil',
          lastName:
              '651682a417b65991d6d0b7e55bf6eb1a67ea35e74295c075dada8c67e6695e4402011f3ed3dfc4e503ed7843177a9c9d34cd22722eacba94d45334d0ad7d3a9c'),
      User(
          id: generateId(),
          firstName: 'Kevin',
          lastName:
              '4a8d708913dbf3745c9769f9a5c1b3a65b68a3ad390f8019a4c6298b328b6adcbdba54be92d591fad42f63cd643b99f80e5c53ceb43c58eb57ded7847ca9f9eb'),
      User(
          id: generateId(),
          firstName: 'Jhon',
          lastName:
              'f04ab399ef59f5d7fe15e67d95020101c10ab976fa033cddfbecbb88ce10710e3fa5c231eef5c4440362011d6bb2bbdaf7032ba20d220684e7d22d8202d8085e'),
      User(
          id: generateId(),
          firstName: 'Augusto',
          lastName:
              '89be58831b2778569e2327034092572ddfd10ef89860fb4492939920bd44e509fb35efd0b0eafa3925fae8a1bc430288f9c20546c5f3dbf5d82db2aac99d8591'),
    ];

    for (var user in users) {
      final existingUsers = await getUsers();
      if (!existingUsers.any((u) => u.firstName == user.firstName)) {
        await insertUser(user);
      }
    }
  }

  Future<void> initializeDefaultVehicles(
      DatabaseController dbController) async {
    final vehi = [
      Vehicle(
        id: generateId(),
        plate: 'AAA-123',
        brand: 'Toyota',
        manufactureDate: DateTime(2020, 5, 20),
        color: 'Blanco',
        cost: 15000,
        isActive: true,
      ),
      Vehicle(
        id: generateId(),
        plate: 'BBB-456',
        brand: 'Honda',
        manufactureDate: DateTime(2018, 11, 10),
        color: 'Negro',
        cost: 12000,
        isActive: false,
      ),
      Vehicle(
        id: generateId(),
        plate: 'CCC-789',
        brand: 'Ford',
        manufactureDate: DateTime(2021, 7, 15),
        color: 'Azul',
        cost: 18000,
        isActive: true,
      ),
    ];

    final existingVehicles = await dbController.getVehicles();

    for (Vehicle vehicle in vehi) {
      if (!existingVehicles.any((v) => v.plate == vehicle.plate)) {
        await dbController.insertVehicle(vehicle);
      }
    }
  }
}
