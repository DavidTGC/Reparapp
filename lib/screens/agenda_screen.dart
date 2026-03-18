import 'package:flutter/material.dart';
import 'package:reparapp/models/usuario.dart';
import 'package:reparapp/models/aviso.dart';
import 'package:reparapp/services/api_service.dart';
import 'package:reparapp/screens/aviso_detalle_screen.dart';
import 'package:intl/intl.dart';

class AgendaScreen extends StatefulWidget {
  final Usuario usuario;

  const AgendaScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late Future<List<Aviso>> _avisosFuture;
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _avisosFuture = ApiService.getAvisosOperario(widget.usuario.id);
  }

  List<Aviso> _filtrarAvisosPorFecha(List<Aviso> avisos) {
    return avisos.where((aviso) {
      return aviso.fecha.year == _fechaSeleccionada.year &&
             aviso.fecha.month == _fechaSeleccionada.month &&
             aviso.fecha.day == _fechaSeleccionada.day;
    }).toList();
  }

  String _getEstadoColor(String estado) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Aviso>>(
      future: _avisosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error al cargar los avisos'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _avisosFuture = ApiService.getAvisosOperario(widget.usuario.id);
                    });
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final avisos = snapshot.data ?? [];
        final avisosFiltrados = _filtrarAvisosPorFecha(avisos);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Selector de fecha
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    const Text(
                      'Selecciona una fecha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _fechaSeleccionada = _fechaSeleccionada.subtract(Duration(days: 1));
                            });
                          },
                          child: const Text('← Anterior'),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _fechaSeleccionada = _fechaSeleccionada.add(Duration(days: 1));
                            });
                          },
                          child: const Text('Siguiente →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _fechaSeleccionada = DateTime.now();
                          });
                        },
                        child: const Text('Hoy'),
                      ),
                    ),
                  ],
                ),
              ),
              // Lista de avisos
              Padding(
                padding: const EdgeInsets.all(16),
                child: avisosFiltrados.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay avisos para esta fecha',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: avisosFiltrados.map((aviso) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AvisoDetalleScreen(aviso: aviso),
                                  ),
                                );
                              },
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getColorEstado(aviso.estado).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.build,
                                  color: _getColorEstado(aviso.estado),
                                ),
                              ),
                              title: Text(aviso.titulo),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(aviso.nombreCliente),
                                  Text(aviso.direccion),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(aviso.hora),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getColorEstado(aviso.estado) == 'Pendiente'
                                      ? Colors.orange[100]
                                      : aviso.estado == 'en_curso'
                                          ? Colors.purple[100]
                                          : aviso.estado == 'finalizado'
                                              ? Colors.green[100]
                                              : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getEstadoColor(aviso.estado),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getColorEstado(aviso.estado),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
