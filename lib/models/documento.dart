class Documento {
  int id;
  int idAviso;
  String tipo; // 'foto_antes', 'foto_durante', 'foto_despues'
  String ruta;
  String nombre;
  DateTime fechaSubida;

  Documento({
    required this.id,
    required this.idAviso,
    required this.tipo,
    required this.ruta,
    required this.nombre,
    required this.fechaSubida,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] ?? 0,
      idAviso: json['idAviso'] ?? 0,
      tipo: json['tipo'] ?? 'foto_durante',
      ruta: json['ruta'] ?? '',
      nombre: json['nombre'] ?? '',
      fechaSubida: DateTime.parse(json['fechaSubida'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'idAviso': idAviso,
    'tipo': tipo,
    'ruta': ruta,
    'nombre': nombre,
    'fechaSubida': fechaSubida.toIso8601String(),
  };
}
