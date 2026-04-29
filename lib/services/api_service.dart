import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/models/cliente.dart';
import 'package:reparapp/models/aviso.dart';
import 'package:reparapp/models/documento.dart';

class ApiService {
  // URL base de la API PHP
  // Para desarrollo web: asegúrate de que Flutter Web se sirve desde el mismo host/puerto que Apache
  // O cambia aquí a la dirección IP real de tu servidor (ej: http://192.168.1.100/reparapp/backend/api)
  static const String apiBaseUrl = 'https://doing-untreated-dweller.ngrok-free.dev/reparapp/backend/api';
  static const String resourceBaseUrl = 'https://doing-untreated-dweller.ngrok-free.dev/reparapp/backend';
  
  // Timeout para las peticiones HTTP
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Obtener URL completa para un recurso (imagen, documento)
  static String getResourceUrl(String relativePath) {
    // Si ya es una URL completa, devolverla tal cual
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    // Si es una ruta relativa, construir la URL completa
    if (relativePath.startsWith('/')) {
      return resourceBaseUrl + relativePath;
    }
    return '$resourceBaseUrl/$relativePath';
  }

  // Método para autenticar usuario
  static Future<Usuario?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/usuarios.php/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Usuario.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Obtener todos los usuarios
  static Future<List<Usuario>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/usuarios.php/usuarios'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<Usuario> usuarios = [];
          for (var usuario in data['data']) {
            usuarios.add(Usuario.fromJson(usuario));
          }
          return usuarios;
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      return [];
    }
  }

  // Obtener avisos del operario
  static Future<List<Aviso>> getAvisosOperario(int idOperario) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/avisos.php/avisos-por-operario?id_operario=$idOperario'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<Aviso> avisos = [];
          for (var aviso in data['data']) {
            avisos.add(Aviso.fromJson(aviso));
          }
          return avisos;
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo avisos del operario: $e');
      return [];
    }
  }

  // Obtener TODOS los avisos (para admin)
  static Future<List<Aviso>> getTodosLosAvisos() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/avisos.php/avisos'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<Aviso> avisos = [];
          for (var aviso in data['data']) {
            avisos.add(Aviso.fromJson(aviso));
          }
          return avisos;
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo todos los avisos: $e');
      return [];
    }
  }

  // Obtener detalle de aviso
  static Future<Aviso?> getAvisoDetalle(int idAviso) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/avisos.php/avisos?id=$idAviso'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'].isNotEmpty) {
          return Aviso.fromJson(data['data'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo detalle del aviso: $e');
      return null;
    }
  }

  // Crear nuevo aviso
  static Future<bool> crearAviso(Aviso aviso) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/avisos.php/avisos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': aviso.titulo,
          'descripcion': aviso.descripcion,
          'direccion': aviso.direccion,
          'ciudad': aviso.ciudad,
          'fecha': aviso.fecha.toString().split(' ')[0],
          'hora': aviso.hora,
          'estado': aviso.estado,
          'prioridad': aviso.prioridad,
          'tipoServicio': aviso.tipoServicio,
          'idCliente': aviso.idCliente,
          'idOperario': aviso.idOperario,
          'notas': aviso.notas,
        }),
      ).timeout(timeoutDuration);

      return response.statusCode == 201;
    } catch (e) {
      print('Error creando aviso: $e');
      return false;
    }
  }

  // Actualizar aviso
  static Future<bool> actualizarAviso(Aviso aviso) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/avisos.php/avisos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': aviso.id,
          'titulo': aviso.titulo,
          'descripcion': aviso.descripcion,
          'direccion': aviso.direccion,
          'fecha': aviso.fecha.toString().split(' ')[0],
          'hora': aviso.hora,
          'estado': aviso.estado,
          'tipoServicio': aviso.tipoServicio,
          'nombreCliente': aviso.nombreCliente,
          'telefonoCliente': aviso.telefonoCliente,
          'notas': aviso.notas,
          'firma': aviso.firma,
        }),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error actualizando aviso: $e');
      return false;
    }
  }

  // Actualizar notas del aviso
  static Future<bool> actualizarNotasAviso(int idAviso, String notas) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/avisos.php/avisos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': idAviso,
          'notas': notas,
        }),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error actualizando notas: $e');
      return false;
    }
  }

  // Cambiar estado del aviso
  static Future<bool> cambiarEstadoAviso(int idAviso, String nuevoEstado) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/avisos.php/avisos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': idAviso,
          'estado': nuevoEstado,
        }),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error cambiando estado del aviso: $e');
      return false;
    }
  }

  // Actualizar firma del aviso
  static Future<bool> actualizarFirmaAviso(int idAviso, String firma) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/avisos.php/avisos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': idAviso,
          'firma': firma,
        }),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error actualizando firma: $e');
      return false;
    }
  }

  // Obtener documentos del aviso
  static Future<List<Documento>> getDocumentosAviso(int idAviso) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/documentos.php/documentos-por-aviso?id_aviso=$idAviso'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<Documento> documentos = [];
          for (var doc in data['data']) {
            documentos.add(Documento.fromJson(doc));
          }
          return documentos;
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo documentos: $e');
      return [];
    }
  }

  // Agregar documento (foto) al aviso - Soporta mobile y web
  static Future<bool> agregarDocumento(int idAviso, dynamic archivoOBytes, String tipo) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/documentos.php/documentos'),
      );

      request.fields['id_aviso'] = idAviso.toString();
      request.fields['tipo'] = tipo;

      // Soportar tanto String (ruta) como bytes
      if (archivoOBytes is String) {
        // Es una ruta de archivo (mobile/desktop)
        if (!kIsWeb) {
          // Mobile: usar fromPath
          request.files.add(
            await http.MultipartFile.fromPath('archivo', archivoOBytes),
          );
        } else {
          // Web: no podemos usar fromPath directamente
          throw Exception(
            'En web, debes pasar bytes directamente en lugar de una ruta de archivo'
          );
        }
      } else if (archivoOBytes is List<int>) {
        // Son bytes (funciona en web y mobile)
        request.files.add(
          http.MultipartFile.fromBytes(
            'archivo',
            archivoOBytes,
            filename: 'documento.jpg',
          ),
        );
      } else {
        throw Exception('Formato de archivo no válido');
      }

      var response = await request.send().timeout(timeoutDuration);
      return response.statusCode == 201;
    } catch (e) {
      print('Error subiendo documento: $e');
      return false;
    }
  }

  // Eliminar documento
  static Future<bool> eliminarDocumento(int idDocumento) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/documentos.php/documentos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': idDocumento}),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando documento: $e');
      return false;
    }
  }

  // Crear nuevo usuario
  static Future<bool> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String rol,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/usuarios.php/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'telefono': telefono,
          'rol': rol,
        }),
      ).timeout(timeoutDuration);

      return response.statusCode == 201;
    } catch (e) {
      print('Error creando usuario: $e');
      return false;
    }
  }

  // Actualizar usuario
  static Future<bool> actualizarUsuario({
    required int id,
    required String nombre,
    required String email,
    required String telefono,
    required String rol,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/usuarios.php/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'nombre': nombre,
          'email': email,
          'telefono': telefono,
          'rol': rol,
        }),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error actualizando usuario: $e');
      return false;
    }
  }

  // Eliminar usuario
  static Future<bool> eliminarUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/usuarios.php/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando usuario: $e');
      return false;
    }
  }

  // Eliminar aviso
  static Future<bool> eliminarAviso(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/avisos.php/avisos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando aviso: $e');
      return false;
    }
  }

  // Obtener lista de clientes
  static Future<List<Cliente>> getClientes() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/clientes.php/clientes'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<Cliente> clientes = [];
          for (var cliente in data['data']) {
            clientes.add(Cliente.fromJson(cliente));
          }
          return clientes;
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo clientes: $e');
      return [];
    }
  }

  // Crear nuevo cliente
  static Future<Cliente?> crearCliente(String nombre, String dni, String telefono) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/clientes.php/clientes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'dni': dni,
          'telefono': telefono,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Cliente.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creando cliente: $e');
      return null;
    }
  }
}
