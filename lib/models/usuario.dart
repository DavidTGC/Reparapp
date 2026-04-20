class Usuario {
  int id;
  String nombre;
  String email;
  String telefono;
  String dni;
  String rol; // 'admin' o 'operario'
  String password;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.dni,
    required this.rol,
    required this.password,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      dni: json['dni'] ?? '',
      rol: json['rol'] ?? 'operario',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'telefono': telefono,
    'dni': dni,
    'rol': rol,
    'password': password,
  };
}
