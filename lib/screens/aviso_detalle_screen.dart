import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:reparapp/models/aviso.dart';
import 'package:reparapp/models/documento.dart';
import 'package:reparapp/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class AvisoDetalleScreen extends StatefulWidget {
  final Aviso aviso;

  const AvisoDetalleScreen({Key? key, required this.aviso}) : super(key: key);

  @override
  State<AvisoDetalleScreen> createState() => _AvisoDetalleScreenState();
}

class _AvisoDetalleScreenState extends State<AvisoDetalleScreen> {
  late Aviso _aviso;
  late TextEditingController _notasController;
  late SignatureController _signatureController;
  List<Documento> _documentos = [];
  bool _isLoadingDocs = false;
  bool _isChangingStatus = false;

  @override
  void initState() {
    super.initState();
    _aviso = widget.aviso;
    _notasController = TextEditingController(text: _aviso.notas);
    _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _cargarDocumentos();
  }

  Future<void> _cargarDocumentos() async {
    setState(() {
      _isLoadingDocs = true;
    });
    try {
      final docs = await ApiService.getDocumentosAviso(_aviso.id);
      setState(() {
        _documentos = docs;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDocs = false;
        });
      }
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final success = await ApiService.agregarDocumento(
          _aviso.id,
          pickedFile.path,
          'foto_durante',
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto añadida exitosamente')),
          );
          _cargarDocumentos();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al capturar la foto')),
        );
      }
    }
  }

  Future<void> _seleccionarFotosGaleria() async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        for (var pickedFile in pickedFiles) {
          await ApiService.agregarDocumento(
            _aviso.id,
            pickedFile.path,
            'foto_durante',
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pickedFiles.length} foto(s) añadida(s)')),
          );
          _cargarDocumentos();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al seleccionar fotos')),
        );
      }
    }
  }

  Future<void> _guardarNotas() async {
    setState(() {
      _isChangingStatus = true;
    });
    try {
      final success = await ApiService.actualizarNotasAviso(
        _aviso.id,
        _notasController.text,
      );
      if (success && mounted) {
        setState(() {
          _aviso.notas = _notasController.text;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notas guardadas')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingStatus = false;
        });
      }
    }
  }

  void _abrirDlgFirma() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Firma'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.grey[100]!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _signatureController.clear();
              },
              child: const Text('Borrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_signatureController.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, realiza una firma')),
                  );
                  return;
                }
                
                await _guardarFirma();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarFirma() async {
    setState(() {
      _isChangingStatus = true;
    });
    try {
      final signature = await _signatureController.toPngBytes();
      if (signature != null && mounted) {
        final firmaBs64 = base64Encode(signature);
        final success = await ApiService.actualizarFirmaAviso(
          _aviso.id,
          firmaBs64,
        );
        if (success && mounted) {
          setState(() {
            _aviso.firma = firmaBs64;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Firma guardada correctamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la firma')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingStatus = false;
        });
      }
      _signatureController.clear();
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    setState(() {
      _isChangingStatus = true;
    });
    try {
      final success = await ApiService.cambiarEstadoAviso(
        _aviso.id,
        nuevoEstado,
      );
      if (success && mounted) {
        setState(() {
          _aviso.estado = nuevoEstado;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingStatus = false;
        });
      }
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_ruta':
        return Colors.blue;
      case 'en_curso':
        return Colors.purple;
      case 'finalizado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_ruta':
        return 'En ruta';
      case 'en_curso':
        return 'En curso';
      case 'finalizado':
        return 'Finalizado';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Aviso'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado
            Container(
              color: Colors.blue[50],
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _aviso.titulo,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getColorEstado(_aviso.estado).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getEstadoTexto(_aviso.estado),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorEstado(_aviso.estado),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Información del cliente
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Cliente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_aviso.nombreCliente),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(_aviso.telefonoCliente),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_aviso.direccion),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Detalles del aviso
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalles del Aviso',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text('Tipo: ${_aviso.tipoServicio}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(_aviso.getFechaFormateada()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(_aviso.hora),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_aviso.descripcion),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cambiar estado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cambiar Estado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isChangingStatus ||  _aviso.estado == 'en_ruta'
                              ? null
                              : () => _cambiarEstado('en_ruta'),
                          child: const Text('En ruta'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isChangingStatus ||  _aviso.estado == 'en_curso'
                              ? null
                              : () => _cambiarEstado('en_curso'),
                          child: const Text('En curso'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isChangingStatus ||  _aviso.estado == 'finalizado'
                              ? null
                              : () => _cambiarEstado('finalizado'),
                          child: const Text('Finalizar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Documentos/Fotos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Documentos / Fotos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _tomarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cámara'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _seleccionarFotosGaleria,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lista de documentos
            if (_isLoadingDocs)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_documentos.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No hay fotos adjuntas',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _documentos.map((doc) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.image, color: Colors.blue),
                        title: Text(doc.nombre),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(doc.fechaSubida),
                        ),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Notas del trabajo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notas del Trabajo Realizado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notasController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Describe el trabajo realizado...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isChangingStatus ? null : _guardarNotas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isChangingStatus
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Guardar Notas',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Firma
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firma',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isChangingStatus ? null : _abrirDlgFirma,
                      icon: const Icon(Icons.edit),
                      label: Text(_aviso.firma.isNotEmpty 
                          ? 'Modificar Firma' 
                          : 'Realizar Firma'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_aviso.firma.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.green[50],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700], size: 24),
                            const SizedBox(width: 8),
                            const Text('Firma guardada', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notasController.dispose();
    _signatureController.dispose();
    super.dispose();
  }
}
