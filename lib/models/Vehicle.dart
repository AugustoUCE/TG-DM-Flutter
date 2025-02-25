class Vehicle {
  int id;
  String plate;

  String brand;

  DateTime manufactureDate;

  String color;

  String mail;

  double cost;

  bool isActive;

  String? imageUrl;
  
  

  Vehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.manufactureDate,
    required this.color,
    required this.mail,
    required this.cost,
    required this.isActive,
    this.imageUrl,
    
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      plate: json['plate'],
      brand: json['brand'],
      manufactureDate: DateTime.parse(json['manufactureDate']),
      color: json['color'],
      mail: json['mail'],
      cost: json['cost'],
      isActive: json['isActive'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'manufactureDate': manufactureDate.toIso8601String(),
      'color': color,
      'mail': mail,
      'cost': cost,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'manufactureDate': manufactureDate.toIso8601String(),
      'color': color,
      'mail': mail,
      'cost': cost,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }
}
