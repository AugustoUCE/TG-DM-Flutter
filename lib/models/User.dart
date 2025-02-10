class User {
  final int id;
  final String firstName;
  final String lastName;

  User({required this.id, required this.firstName, required this.lastName});

  // Método para convertir un objeto User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  // Método para convertir un JSON a un User

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  // Método para convertir un User a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
