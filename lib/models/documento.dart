class Documento {
  int id;
  int idAviso;
  String tipo; // 'foto_antes', 'foto_durante', 'foto_despues'
  String ruta;
  String nombre;
  DateTime fechaSubida;
  String? urlAcceso; // URL completa para acceder a la imagen

  Documento({
    required this.id,
    required this.idAviso,
    required this.tipo,
    required this.ruta,
    required this.nombre,
    required this.fechaSubida,
    this.urlAcceso,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      idAviso: json['idAviso'] is int ? json['idAviso'] : int.tryParse(json['idAviso'].toString()) ?? 0,
      tipo: json['tipo'] ?? 'foto_durante',
      ruta: json['ruta'] ?? json['ruta_archivo'] ?? '',
      nombre: json['nombre'] ?? json['nombre_archivo'] ?? '',
      fechaSubida: json['fechaSubida'] != null 
        ? DateTime.parse(json['fechaSubida'].toString())
        : (json['fecha_subida'] != null 
          ? DateTime.parse(json['fecha_subida'].toString())
          : DateTime.now()),
      urlAcceso: json['url_acceso'] ?? json['urlAcceso'],
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
