import 'package:flutter/material.dart';
import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/services/api_service.dart';

class AdminEditarUsuarioScreen extends StatefulWidget {
  final Usuario usuario;
  final Usuario adminUsuario;

  const AdminEditarUsuarioScreen({
    Key? key,
    required this.usuario,
    required this.adminUsuario,
  }) : super(key: key);

  @override
  State<AdminEditarUsuarioScreen> createState() =>
      _AdminEditarUsuarioScreenState();
}

class _AdminEditarUsuarioScreenState extends State<AdminEditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _dniController;

  late String _rolSeleccionado;
  bool _cargando = false;
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _emailController = TextEditingController(text: widget.usuario.email);
    _telefonoController = TextEditingController(text: widget.usuario.telefono ?? '');
    _dniController = TextEditingController(text: widget.usuario.dni ?? '');
    _rolSeleccionado = widget.usuario.rol;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _actualizarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
      _mensajeError = null;
    });

    try {
      final success = await ApiService.actualizarUsuario(
        id: widget.usuario.id,
        nombre: _nombreController.text,
        email: _emailController.text,
        telefono: _telefonoController.text,
        dni: _dniController.text,
        rol: _rolSeleccionado,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _mensajeError = 'Error al actualizar el usuario. Intenta de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _mensajeError = 'Error: $e';
      });
      print('Error actualizando usuario: $e');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
        backgroundColor: Colors.deepOrange[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mensaje de error
                if (_mensajeError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _mensajeError!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_mensajeError != null) const SizedBox(height: 16),

                // Campo Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Teléfono
                TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Campo DNI
                TextFormField(
                  controller: _dniController,
                  decoration: InputDecoration(
                    labelText: 'DNI',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de Rol
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Usuario',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rolSeleccionado = 'operario';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _rolSeleccionado == 'operario'
                                      ? Colors.blue[100]
                                      : Colors.grey[100],
                                  border: Border.all(
                                    color: _rolSeleccionado == 'operario'
                                        ? Colors.blue[700]!
                                        : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.build,
                                      size: 32,
                                      color: _rolSeleccionado == 'operario'
                                          ? Colors.blue[700]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Operario',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rolSeleccionado = 'admin';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _rolSeleccionado == 'admin'
                                      ? Colors.orange[100]
                                      : Colors.grey[100],
                                  border: Border.all(
                                    color: _rolSeleccionado == 'admin'
                                        ? Colors.orange[700]!
                                        : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings,
                                      size: 32,
                                      color: _rolSeleccionado == 'admin'
                                          ? Colors.orange[700]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón Actualizar Usuario
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _actualizarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange[700],
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Actualizar Usuario',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
