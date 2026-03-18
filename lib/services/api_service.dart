import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/models/aviso.dart';
import 'package:reparapp/models/documento.dart';

class ApiService {
  // Mock data - En una versión final se conectaría a una API real
  
  static final List<Usuario> _usuarios = [
    Usuario(
      id: 1,
      nombre: 'Miguel Rodríguez',
      email: 'juan@reparapp.es',
      telefono: '656234567',
      rol: 'operario',
      password: '1234',
    ),
    Usuario(
      id: 2,
      nombre: 'Francisco Javier López',
      email: 'admin@reparapp.es',
      telefono: '655789123',
      rol: 'admin',
      password: '1234',
    ),
    Usuario(
      id: 3,
      nombre: 'Antonio Moreno',
      email: 'antonio@reparapp.es',
      telefono: '654123456',
      rol: 'operario',
      password: '1234',
    ),
  ];

  static final List<Aviso> _avisos = [
    Aviso(
      id: 1,
      titulo: 'Reparación fontanería',
      descripcion: 'Fuga en baño principal, revisar tuberías',
      direccion: 'Calle Larga 45, Jerez de la Frontera',
      fecha: DateTime.now(),
      hora: '09:00',
      estado: 'pendiente',
      tipoServicio: 'Fontanería',
      nombreCliente: 'Rafael Díaz Martínez',
      telefonoCliente: '956332145',
      idOperario: 1,
      notas: '',
    ),
    Aviso(
      id: 2,
      titulo: 'Instalación eléctrica',
      descripcion: 'Instalación de toma de corriente en cocina',
      direccion: 'Avenida Alcalde Álvaro Domecq 78, Jerez de la Frontera',
      fecha: DateTime.now().add(Duration(days: 1)),
      hora: '14:00',
      estado: 'pendiente',
      tipoServicio: 'Electricidad',
      nombreCliente: 'Isabel Ruiz Fernández',
      telefonoCliente: '956334512',
      idOperario: 1,
      notas: '',
    ),
    Aviso(
      id: 3,
      titulo: 'Desatasco de tuberías',
      descripcion: 'Desatasco en el sifón del lavabo',
      direccion: 'Calle Pizarro 23, Jerez de la Frontera',
      fecha: DateTime.now().add(Duration(days: 2)),
      hora: '10:30',
      estado: 'en_curso',
      tipoServicio: 'Desatascalia',
      nombreCliente: 'José María Gómez',
      telefonoCliente: '956445789',
      idOperario: 1,
      notas: '',
    ),
    Aviso(
      id: 4,
      titulo: 'Reparación calefacción',
      descripcion: 'Revisar y reparar sistema de calefacción central',
      direccion: 'Calle Nueva 56, Jerez de la Frontera',
      fecha: DateTime.now().add(Duration(days: 3)),
      hora: '11:00',
      estado: 'pendiente',
      tipoServicio: 'Calefacción',
      nombreCliente: 'Carmen López Pérez',
      telefonoCliente: '956667234',
      idOperario: 1,
      notas: '',
    ),
    Aviso(
      id: 5,
      titulo: 'Instalación sanitarios',
      descripcion: 'Instalación de inodoro y lavabo en baño',
      direccion: 'Calle Arcos 12, Jerez de la Frontera',
      fecha: DateTime.now().add(Duration(days: 4)),
      hora: '15:30',
      estado: 'pendiente',
      tipoServicio: 'Fontanería',
      nombreCliente: 'Estela Rodríguez Silva',
      telefonoCliente: '956778456',
      idOperario: 1,
      notas: '',
    ),
    Aviso(
      id: 6,
      titulo: 'Reparación puerta',
      descripcion: 'Reparar cristal roto en puerta de balcón',
      direccion: 'Calle Letrados 34, Jerez de la Frontera',
      fecha: DateTime.now().add(Duration(days: 5)),
      hora: '13:00',
      estado: 'finalizado',
      tipoServicio: 'Carpintería',
      nombreCliente: 'Vicente Morales Domínguez',
      telefonoCliente: '956889234',
      idOperario: 1,
      notas: '',
    ),
  ];

  static final List<Documento> _documentos = [];

  // Método para autenticar usuario
  static Future<Usuario?> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simular delay de red
    
    try {
      final usuario = _usuarios.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      return usuario;
    } catch (e) {
      return null;
    }
  }

  // Obtener avisos del operario
  static Future<List<Aviso>> getAvisosOperario(int idOperario) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _avisos.where((aviso) => aviso.idOperario == idOperario).toList();
  }

  // Obtener detalle de aviso
  static Future<Aviso?> getAvisoDetalle(int idAviso) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _avisos.firstWhere((aviso) => aviso.id == idAviso);
    } catch (e) {
      return null;
    }
  }

  // Actualizar notas del aviso
  static Future<bool> actualizarNotasAviso(int idAviso, String notas) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      final aviso = _avisos.firstWhere((a) => a.id == idAviso);
      aviso.notas = notas;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cambiar estado del aviso
  static Future<bool> cambiarEstadoAviso(int idAviso, String nuevoEstado) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      final aviso = _avisos.firstWhere((a) => a.id == idAviso);
      aviso.estado = nuevoEstado;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener documentos del aviso
  static Future<List<Documento>> getDocumentosAviso(int idAviso) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _documentos.where((doc) => doc.idAviso == idAviso).toList();
  }

  // Agregar documento (foto) al aviso
  static Future<bool> agregarDocumento(int idAviso, String ruta, String tipo) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      final nuevoDoc = Documento(
        id: _documentos.length + 1,
        idAviso: idAviso,
        tipo: tipo,
        ruta: ruta,
        nombre: 'Foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        fechaSubida: DateTime.now(),
      );
      _documentos.add(nuevoDoc);
      return true;
    } catch (e) {
      return false;
    }
  }
}
