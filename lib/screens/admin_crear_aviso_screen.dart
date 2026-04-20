import 'package:flutter/material.dart';
import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/models/aviso.dart';
import 'package:reparapp/services/api_service.dart';

class AdminCrearAvisoScreen extends StatefulWidget {
  final Usuario usuario;

  const AdminCrearAvisoScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<AdminCrearAvisoScreen> createState() => _AdminCrearAvisoScreenState();
}

class _AdminCrearAvisoScreenState extends State<AdminCrearAvisoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _direccionController;
  late TextEditingController _tipoServicioController;
  late TextEditingController _nombreClienteController;
  late TextEditingController _telefonoClienteController;
  late TextEditingController _horaController;

  // Variables para el formulario
  DateTime _fechaSeleccionada = DateTime.now();
  int _operarioSeleccionado = 1;
  List<Usuario> _operarios = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController();
    _descripcionController = TextEditingController();
    _direccionController = TextEditingController();
    _tipoServicioController = TextEditingController();
    _nombreClienteController = TextEditingController();
    _telefonoClienteController = TextEditingController();
    _horaController = TextEditingController(text: '09:00');
    
    _cargarOperarios();
  }

  Future<void> _cargarOperarios() async {
    try {
      final usuarios = await ApiService.getUsuarios();
      print('Total usuarios cargados: ${usuarios.length}');
      
      // Filtrar operarios
      final operarios = usuarios.where((u) => u.rol == 'operario').toList();
      print('Operarios encontrados: ${operarios.length}');
      
      // Si no hay operarios con rol 'operario', usar todos los usuarios
      final listaFinal = operarios.isNotEmpty ? operarios : usuarios;
      
      setState(() {
        _operarios = listaFinal;
        if (_operarios.isNotEmpty) {
          _operarioSeleccionado = _operarios.first.id;
          print('Operario por defecto seleccionado: ${_operarios.first.nombre}');
        }
      });
    } catch (e) {
      print('Error al cargar operarios: $e');
      setState(() {
        _operarios = [];
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _horaController.text = picked.format(context);
      });
    }
  }

  Future<void> _crearAviso() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _cargando = true);

    try {
      final aviso = Aviso(
        id: 0, // El servidor asignará el ID
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        direccion: _direccionController.text,
        fecha: _fechaSeleccionada,
        hora: _horaController.text,
        estado: 'pendiente',
        tipoServicio: _tipoServicioController.text,
        nombreCliente: _nombreClienteController.text,
        telefonoCliente: _telefonoClienteController.text,
        idOperario: _operarioSeleccionado,
        notas: '',
      );

      final resultado = await ApiService.crearAviso(aviso);

      setState(() => _cargando = false);

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Aviso creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al crear el aviso'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _tipoServicioController.dispose();
    _nombreClienteController.dispose();
    _telefonoClienteController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Aviso'),
        backgroundColor: Colors.deepOrange[700],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Información del Aviso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título del aviso',
                        hintText: 'Ej: Reparación fontanería',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El título es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describe el trabajo a realizar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _tipoServicioController,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Servicio',
                        hintText: 'Ej: Fontanería, Electricidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.build),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El tipo de servicio es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _direccionController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        hintText: 'Dirección del cliente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La dirección es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Información del Cliente
                    const Text(
                      'Información del Cliente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nombreClienteController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Cliente',
                        hintText: 'Nombre completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre del cliente es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _telefonoClienteController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono del Cliente',
                        hintText: '656123456',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El teléfono es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Programación
                    const Text(
                      'Programación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fecha
                    GestureDetector(
                      onTap: _seleccionarFecha,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.deepOrange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha del Aviso',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora
                    GestureDetector(
                      onTap: _seleccionarHora,
                      child: TextFormField(
                        controller: _horaController,
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                        ),
                        readOnly: true,
                        onTap: _seleccionarHora,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La hora es requerida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Asignar Operario
                    const Text(
                      'Asignar a Operario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _operarios.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '⚠️ No hay operarios disponibles',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Por favor, crea operarios primero.',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<int>(
                            value: _operarioSeleccionado,
                            decoration: InputDecoration(
                              labelText: 'Selecciona un operario',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.engineering),
                            ),
                            items: _operarios
                                .map((operario) => DropdownMenuItem(
                                      value: operario.id,
                                      child: Text('${operario.nombre} (${operario.email})'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _operarioSeleccionado = value);
                              }
                            },
                          ),
                    const SizedBox(height: 32),

                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancelar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _crearAviso,
                          icon: const Icon(Icons.save),
                          label: const Text('Crear Aviso'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange[700],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
