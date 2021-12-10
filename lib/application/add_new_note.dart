import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../presentation/pages/pdf_document_view/components/note_detail.dart';

@injectable
class AddNewNote {
  OverlayEntry call(Offset offset) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 20,
        top: offset.dy - 20,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              context: context,
              builder: (context) => NoteDatail(
                onPressed: () {},
              ),
            );
          },
          onPanUpdate: (details) {
            offset += details.delta;
            entry!.markNeedsBuild();
          },
          child: const CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(
              Icons.note_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
    return entry;
  }
}
