import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String? bodyText;
  final DateTime? lastModifyDate;
  final bool? isOpaque;
  final Offset offset;
  Note({
    required this.id,
    this.bodyText,
    this.lastModifyDate,
    this.isOpaque,
    required this.offset,
  });

  factory Note.empty() => Note(
      id: const Uuid().v1(),
      bodyText: '',
      lastModifyDate: DateTime.now(),
      isOpaque: false,
      offset: const Offset(100, 100));

  Note copyWith({
    String? id,
    String? bodyText,
    DateTime? lastModifyDate,
    bool? isOpaque,
    Offset? offset,
  }) {
    return Note(
      id: id ?? this.id,
      bodyText: bodyText ?? this.bodyText,
      lastModifyDate: lastModifyDate ?? this.lastModifyDate,
      isOpaque: isOpaque ?? this.isOpaque,
      offset: offset ?? this.offset,
    );
  }

  set offset(Offset value) {
    assert(offset.dx > 0 && offset.dy > 0);
    offset = value;
  }
}
