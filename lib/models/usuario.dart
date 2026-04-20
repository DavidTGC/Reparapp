class Usuario {
  int id;
  String nombre;
  String email;
  String telefono;
  String rol; // 'admin' o 'operario'
  String password;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.password,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? 'operario',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'telefono': telefono,
    'rol': rol,
    'password': password,
  };
}
