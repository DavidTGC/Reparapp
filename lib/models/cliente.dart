class Cliente {
  final int id;
  final String nombre;
  final String dni;
  final String telefono;

  Cliente({
    required this.id,
    required this.nombre,
    required this.dni,
    required this.telefono,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      dni: json['dni'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
    };
  }
}
