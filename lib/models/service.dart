class BarberService {
  final int? id;
  final String name;
  final double price;
  final String icon;

  BarberService({
    this.id,
    required this.name,
    required this.price,
    this.icon = 'scissors',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'icon': icon,
    };
  }

  factory BarberService.fromMap(Map<String, dynamic> map) {
    return BarberService(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      icon: map['icon'] as String? ?? 'scissors',
    );
  }

  BarberService copyWith({
    int? id,
    String? name,
    double? price,
    String? icon,
  }) {
    return BarberService(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      icon: icon ?? this.icon,
    );
  }
}
