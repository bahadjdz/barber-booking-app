class Appointment {
  final int? id;
  final String customerName;
  final String? phone;
  final String? serviceName;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final String status; // waiting, cutting, done
  final double price;
  final String? notes;

  Appointment({
    this.id,
    required this.customerName,
    this.phone,
    this.serviceName,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_name': customerName,
      'phone': phone,
      'service_name': serviceName,
      'date': date,
      'time': time,
      'status': status,
      'price': price,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      phone: map['phone'] as String?,
      serviceName: map['service_name'] as String?,
      date: map['date'] as String,
      time: map['time'] as String,
      status: map['status'] as String,
      price: (map['price'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  Appointment copyWith({
    int? id,
    String? customerName,
    String? phone,
    String? serviceName,
    String? date,
    String? time,
    String? status,
    double? price,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      price: price ?? this.price,
      notes: notes ?? this.notes,
    );
  }
}
