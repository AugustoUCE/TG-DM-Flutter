class Vehicle {
  int id;
  String plate;

  String brand;

  DateTime manufactureDate;

  String color;

  double cost;

  bool isActive;

  String? imagePath;
  
  

  Vehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.manufactureDate,
    required this.color,
    required this.cost,
    required this.isActive,
    this.imagePath, 
    
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      plate: json['plate'],
      brand: json['brand'],
      manufactureDate: DateTime.parse(json['manufactureDate']),
      color: json['color'],
      cost: json['cost'],
      isActive: json['isActive'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'manufactureDate': manufactureDate.toIso8601String(),
      'color': color,
      'cost': cost,
      'isActive': isActive,
      'imagePath': imagePath,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'manufactureDate': manufactureDate.toIso8601String(),
      'color': color,
      'cost': cost,
      'isActive': isActive,
      'imagePath': imagePath,
    };
  }
}
