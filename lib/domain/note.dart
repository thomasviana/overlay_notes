import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Note {
  Offset _offset;
  final String? id;
  final int? page;
  final String? bodyText;
  final DateTime? lastModifiedDate;
  final bool? isOpaque;
  Note(
    this._offset, {
    this.id,
    this.page,
    this.bodyText,
    this.lastModifiedDate,
    this.isOpaque,
  });

  set offset(Offset offset) {
    assert(offset.dx > 0 && offset.dy > 0);
    _offset = offset;
  }

  Offset get offset => _offset;

  factory Note.empty() => Note(
        const Offset(100, 100),
        id: const Uuid().v1(),
        bodyText: '',
        lastModifiedDate: DateTime.now(),
        isOpaque: false,
      );

  Note copyWith(
    Offset? _offset, {
    String? id,
    String? bodyText,
    DateTime? lastModifiedDate,
    bool? isOpaque,
  }) {
    return Note(
      _offset ?? this._offset,
      id: id ?? this.id,
      bodyText: bodyText ?? this.bodyText,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
      isOpaque: isOpaque ?? this.isOpaque,
    );
  }
}
