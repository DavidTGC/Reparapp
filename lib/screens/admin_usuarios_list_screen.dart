import 'package:flutter/material.dart';
import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/services/api_service.dart';
import 'package:reparapp/screens/admin_editar_usuario_screen.dart';
import 'package:reparapp/screens/admin_crear_usuario_screen.dart';

class AdminUsuariosListScreen extends StatefulWidget {
  final Usuario usuario;

  const AdminUsuariosListScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<AdminUsuariosListScreen> createState() => _AdminUsuariosListScreenState();
}

class _AdminUsuariosListScreenState extends State<AdminUsuariosListScreen> {
  late Future<List<Usuario>> _usuariosFuture;
  String _filtroRol = 'todos'; // 'todos', 'admin', 'operario'

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  void _cargarUsuarios() {
    _usuariosFuture = ApiService.getUsuarios();
  }

  Color _getColorRol(String rol) {
    switch (rol) {
      case 'admin':
        return Colors.deepOrange;
      case 'operario':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTextoRol(String rol) {
    switch (rol) {
      case 'admin':
        return 'Administrador';
      case 'operario':
        return 'Operario';
      default:
        return rol;
    }
  }

  IconData _getIconoRol(String rol) {
    switch (rol) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'operario':
        return Icons.build;
      default:
        return Icons.person;
    }
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de que deseas eliminar a ${usuario.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        final success = await ApiService.eliminarUsuario(usuario.id);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _cargarUsuarios();
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios'),
        backgroundColor: Colors.deepOrange[700],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('todos', 'Todos'),
                  const SizedBox(width: 8),
                  _buildFilterButton('admin', 'Administradores'),
                  const SizedBox(width: 8),
                  _buildFilterButton('operario', 'Operarios'),
                ],
              ),
            ),
          ),

          // Lista de usuarios
          Expanded(
            child: FutureBuilder<List<Usuario>>(
              future: _usuariosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<Usuario> usuarios = snapshot.data ?? [];

                // Filtrar por rol
                if (_filtroRol != 'todos') {
                  usuarios = usuarios.where((u) => u.rol == _filtroRol).toList();
                }

                if (usuarios.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay usuarios para mostrar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getColorRol(usuario.rol),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            _getIconoRol(usuario.rol),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          usuario.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              usuario.email,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getColorRol(usuario.rol).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getTextoRol(usuario.rol),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getColorRol(usuario.rol),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminEditarUsuarioScreen(
                                    usuario: usuario,
                                    adminUsuario: widget.usuario,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  _cargarUsuarios();
                                });
                              });
                            } else if (value == 'eliminar') {
                              _eliminarUsuario(usuario);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'editar',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminCrearUsuarioScreen(usuario: widget.usuario),
            ),
          ).then((_) {
            setState(() {
              _cargarUsuarios();
            });
          });
        },
        child: const Icon(Icons.add),
      ),    );
  }

  Widget _buildFilterButton(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _filtroRol == value,
      onSelected: (selected) {
        setState(() {
          _filtroRol = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.deepOrange[100],
      labelStyle: TextStyle(
        color: _filtroRol == value ? Colors.deepOrange[700] : Colors.grey[600],
        fontWeight: _filtroRol == value ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
