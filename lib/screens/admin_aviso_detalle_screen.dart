import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/models/aviso.dart';
import 'package:reparapp/models/documento.dart';
import 'package:reparapp/services/api_service.dart';

class AdminAvisoDetalleScreen extends StatefulWidget {
  final Aviso aviso;
  final Usuario usuario;

  const AdminAvisoDetalleScreen({
    Key? key,
    required this.aviso,
    required this.usuario,
  }) : super(key: key);

  @override
  State<AdminAvisoDetalleScreen> createState() => _AdminAvisoDetalleScreenState();
}

class _AdminAvisoDetalleScreenState extends State<AdminAvisoDetalleScreen> {
  late Aviso _aviso;
  late TextEditingController _notasController;
  late TextEditingController _descripcionController;
  late TextEditingController _horaController;
  List<Documento> _documentos = [];
  bool _isLoadingDocs = false;
  bool _isSaving = false;

  DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _aviso = widget.aviso;
    _notasController = TextEditingController(text: _aviso.notas);
    _descripcionController = TextEditingController(text: _aviso.descripcion);
    _horaController = TextEditingController(text: _aviso.hora);
    _selectedDate = _aviso.fecha;
    _selectedTime = TimeOfDay.now();
    _cargarDocumentos();
    _cargarOperarios();
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

  Future<void> _cargarOperarios() async {
    // En una versión real, esto se cargaría de la API
    // Por ahora usaremos datos mock
    setState(() {
      // Aquí iría la carga de operarios
    });
  }

  Future<void> _guardarCambios() async {
    setState(() {
      _isSaving = true;
    });
    try {
      _aviso.descripcion = _descripcionController.text;
      _aviso.hora = _horaController.text;
      _aviso.fecha = _selectedDate;

      // Aquí iría el llamado a la API para guardar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
        backgroundColor: Colors.deepOrange[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado y título
            Container(
              color: Colors.deepOrange[50],
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del cliente
                  const Text(
                    'Información del Cliente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.deepOrange[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_aviso.nombreCliente)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.deepOrange[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_aviso.telefonoCliente)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.deepOrange[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_aviso.direccion)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tipo de servicio
                  const Text(
                    'Tipo de Servicio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _aviso.tipoServicio,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Descripción editable
                  const Text(
                    'Descripción del Trabajo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descripcionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Descripción del trabajo...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Calendario para fecha
                  const Text(
                    'Fecha Asignada',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: _selectedDate,
                      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hora
                  const Text(
                    'Hora Asignada',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _horaController,
                    decoration: InputDecoration(
                      hintText: 'Ej: 09:30',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.schedule),
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _selectedTime = pickedTime;
                              _horaController.text = pickedTime.format(context);
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Asignar a Operario
                  const Text(
                    'Asignar a Operario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _aviso.idOperario,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Miguel Rodríguez'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Antonio Moreno'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _aviso.idOperario = value;
                          });
                        }
                      },
                      underline: const SizedBox(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Lo que el operario ha rellenado - Notas
                  const Text(
                    'Notas del Operario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green[50],
                    ),
                    child: Text(
                      _notasController.text.isEmpty
                          ? 'Sin notas del operario'
                          : _notasController.text,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: _notasController.text.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Firma del operario
                  const Text(
                    'Firma del Operario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_aviso.firma.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Firma guardada'),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Image.memory(
                              base64Decode(_aviso.firma),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Sin firma del operario',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Fotos/Documentos
                  const Text(
                    'Documentos / Fotos del Operario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingDocs)
                    const Center(child: CircularProgressIndicator())
                  else if (_documentos.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Sin documentos adjuntos',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _documentos.map((doc) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.image, color: Colors.deepOrange),
                            title: Text(doc.nombre),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(doc.fechaSubida),
                            ),
                            trailing: const Icon(Icons.check_circle, color: Colors.green),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cambiar estado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _mostrarDialogoEstado();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cambiar Estado',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEstado() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Pendiente'),
                onTap: () {
                  _cambiarEstado('pendiente');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('En ruta'),
                onTap: () {
                  _cambiarEstado('en_ruta');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('En curso'),
                onTap: () {
                  _cambiarEstado('en_curso');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Finalizado'),
                onTap: () {
                  _cambiarEstado('finalizado');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _cambiarEstado(String nuevoEstado) {
    setState(() {
      _aviso.estado = nuevoEstado;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estado cambiad a ${_getEstadoTexto(nuevoEstado)}')),
    );
  }

  @override
  void dispose() {
    _notasController.dispose();
    _descripcionController.dispose();
    _horaController.dispose();
    super.dispose();
  }
}
