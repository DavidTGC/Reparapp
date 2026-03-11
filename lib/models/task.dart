import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String address;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String description;
  final String status; // pendiente, en_progreso, completada
  final String operarioId;
  final List<String> photoList; // rutas de fotos
  final String notes; // notas del trabajo realizado
  final DateTime? completedDate;

  Task({
    required this.id,
    required this.title,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.description,
    this.status = 'pendiente',
    required this.operarioId,
    this.photoList = const [],
    this.notes = '',
    this.completedDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'],
      description: json['description'],
      status: json['status'] ?? 'pendiente',
      operarioId: json['operarioId'],
      photoList: List<String>.from(json['photoList'] ?? []),
      notes: json['notes'] ?? '',
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime,
      'description': description,
      'status': status,
      'operarioId': operarioId,
      'photoList': photoList,
      'notes': notes,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  // Método para obtener solo la fecha formateada
  String getFormattedDate() {
    return "${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}";
  }

  // Método para saber si la tarea es hoy
  bool isToday() {
    final now = DateTime.now();
    return scheduledDate.day == now.day &&
        scheduledDate.month == now.month &&
        scheduledDate.year == now.year;
  }

  // Método para saber si la tarea está vencida
  bool isOverdue() {
    return scheduledDate.isBefore(DateTime.now()) && status != 'completada';
  }
}
