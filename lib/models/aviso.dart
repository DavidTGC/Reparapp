import 'package:intl/intl.dart';

class Aviso {
  int id;
  String titulo;
  String descripcion;
  String direccion;
  DateTime fecha;
  String hora;
  String estado; // 'pendiente', 'en_ruta', 'en_curso', 'finalizado'
  String tipoServicio;
  String nombreCliente;
  String telefonoCliente;
  int idOperario;
  String notas;
  String firma;

  Aviso({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.direccion,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.tipoServicio,
    required this.nombreCliente,
    required this.telefonoCliente,
    required this.idOperario,
    this.notas = '',
    this.firma = '',
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      direccion: json['direccion'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      hora: json['hora'] ?? 'No especificada',
      estado: json['estado'] ?? 'pendiente',
      tipoServicio: json['tipoServicio'] ?? '',
      nombreCliente: json['nombreCliente'] ?? '',
      telefonoCliente: json['telefonoCliente'] ?? '',
      idOperario: json['idOperario'] ?? 0,
      notas: json['notas'] ?? '',
      firma: json['firma'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'direccion': direccion,
    'fecha': fecha.toIso8601String(),
    'hora': hora,
    'estado': estado,
    'tipoServicio': tipoServicio,
    'nombreCliente': nombreCliente,
    'telefonoCliente': telefonoCliente,
    'idOperario': idOperario,
    'firma': firma,
    'notas': notas,
  };

  String getFechaFormateada() {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }
}
