import 'package:flutter/material.dart';
import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/models/aviso.dart';
import 'package:reparapp/services/api_service.dart';
import 'package:reparapp/screens/admin_aviso_detalle_screen.dart';
import 'package:reparapp/screens/admin_crear_aviso_screen.dart';

class AdminAvisosListScreen extends StatefulWidget {
  final Usuario usuario;

  const AdminAvisosListScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<AdminAvisosListScreen> createState() => _AdminAvisosListScreenState();
}

class _AdminAvisosListScreenState extends State<AdminAvisosListScreen> {
  late Future<List<Aviso>> _avisosFuture;
  String _filtroEstado = 'todos';

  @override
  void initState() {
    super.initState();
    _avisosFuture = ApiService.getTodosLosAvisos();
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

  Future<void> _eliminarAviso(Aviso aviso) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Aviso'),
        content: Text('¿Estás seguro de que deseas eliminar el aviso "${aviso.titulo}"?'),
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
        final success = await ApiService.eliminarAviso(aviso.id);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aviso eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _avisosFuture = ApiService.getTodosLosAvisos();
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
        title: const Text('Gestionar Avisos'),
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
                  _buildFilterButton('pendiente', 'Pendiente'),
                  const SizedBox(width: 8),
                  _buildFilterButton('en_ruta', 'En ruta'),
                  const SizedBox(width: 8),
                  _buildFilterButton('en_curso', 'En curso'),
                  const SizedBox(width: 8),
                  _buildFilterButton('finalizado', 'Finalizado'),
                ],
              ),
            ),
          ),
          
          // Lista de avisos
          Expanded(
            child: FutureBuilder<List<Aviso>>(
              future: _avisosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay avisos'),
                  );
                }

                List<Aviso> avisos = snapshot.data!;
                
                // Filtrar avisos según estado
                if (_filtroEstado != 'todos') {
                  avisos = avisos.where((a) => a.estado == _filtroEstado).toList();
                }

                return ListView.builder(
                  itemCount: avisos.length,
                  itemBuilder: (context, index) {
                    final aviso = avisos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAvisoDetalleScreen(
                                aviso: aviso,
                                usuario: widget.usuario,
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              _avisosFuture = ApiService.getTodosLosAvisos();
                            });
                          });
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getColorEstado(aviso.estado).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.assignment,
                            color: _getColorEstado(aviso.estado),
                          ),
                        ),
                        title: Text(
                          aviso.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Cliente: ${aviso.nombreCliente}',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  aviso.getFechaFormateada(),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  aviso.hora,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'eliminar') {
                              _eliminarAviso(aviso);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red[700]),
                                  const SizedBox(width: 8),
                                  const Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getColorEstado(aviso.estado).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getEstadoTexto(aviso.estado),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getColorEstado(aviso.estado),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminCrearAvisoScreen(usuario: widget.usuario),
            ),
          ).then((_) {
            setState(() {
              _avisosFuture = ApiService.getTodosLosAvisos();
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterButton(String value, String label) {
    final isSelected = _filtroEstado == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _filtroEstado = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepOrange[700] : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: BorderSide(
          color: isSelected ? Colors.deepOrange[700]! : Colors.grey[300]!,
        ),
      ),
      child: Text(label),
    );
  }
}
