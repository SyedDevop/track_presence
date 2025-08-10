import 'package:flutter/material.dart';

class Task {
  final int id;
  final String assignedTo;
  final String? assignedName;
  final String? title;
  final String? description;
  final DateTime? targetDate;
  final String status;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;

  Task({
    required this.id,
    required this.assignedTo,
    this.assignedName,
    this.title,
    this.description,
    this.targetDate,
    required this.status,
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.parse(json['id'].toString()),
      assignedTo: json['assigned_to'] ?? '',
      assignedName: json['assigned_name'],
      title: json['title'],
      description: json['description'],
      targetDate: json['target_date'] != null
          ? DateTime.tryParse(json['target_date'])
          : null,
      status: json['status'] ?? 'assigned',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assigned_to': assignedTo,
      'assigned_name': assignedName,
      'title': title,
      'description': description,
      'target_date': targetDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
    };
  }

  // UI Helper methods
  Color get statusColor {
    switch (status) {
      case 'assigned':
        return const Color(0xFFFF9800); // Orange
      case 'in_progress':
        return const Color(0xFF2196F3); // Blue
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'assigned':
        return Icons.assignment;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'assigned':
        return 'Assigned';
      default:
        return status.toUpperCase();
    }
  }

  bool get isOverdue {
    if (targetDate == null) return false;
    return targetDate!.isBefore(DateTime.now()) && status != 'completed';
  }
}

class TaskResponse {
  final int status;
  final String? message;
  final List<Task>? data;
  final Task? task;
  final TaskPagination? pagination;
  final TaskFilters? filters;

  TaskResponse({
    required this.status,
    this.message,
    this.data,
    this.task,
    this.pagination,
    this.filters,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      status: json['status'] ?? 0,
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => Task.fromJson(e)).toList()
          : null,
      task: json['data'] != null && json['data'] is Map
          ? Task.fromJson(json['data'])
          : null,
      pagination: json['pagination'] != null
          ? TaskPagination.fromJson(json['pagination'])
          : null,
      filters: json['filters'] != null
          ? TaskFilters.fromJson(json['filters'])
          : null,
    );
  }

  bool get isSuccess => status == 200;
}

class TaskPagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  TaskPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory TaskPagination.fromJson(Map<String, dynamic> json) {
    return TaskPagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class TaskFilters {
  final bool showAll;
  final String? status;
  final String? userId;

  TaskFilters({
    required this.showAll,
    this.status,
    this.userId,
  });

  factory TaskFilters.fromJson(Map<String, dynamic> json) {
    return TaskFilters(
      showAll: json['show_all'] ?? false,
      status: json['status'],
      userId: json['user_id'],
    );
  }
}
