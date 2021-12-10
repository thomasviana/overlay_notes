import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:overlay/domain/note.dart';

import '../../../../application/add_new_note.dart';

part 'pdf_view_page_state.dart';

@injectable
class PdfViewPageCubit extends Cubit<PdfViewPageState> {
  AddNewNote addNewNote;
  PdfViewPageCubit(
    this.addNewNote,
  ) : super(PdfViewPageState.initial());

  void hideOverlay() {
    if (state.entries.isEmpty) return;
    for (var entry in state.entries) {
      entry?.remove();
    }
  }

  void showOverlay(BuildContext context) {
    if (state.entries.isEmpty) return;
    for (var entry in state.entries) {
      assert(entry != null);
      Overlay.of(context)!.insert(entry!);
    }
  }

  void onAddNotePressed(BuildContext context, OverlayEntry noteAsOverlayEntry) {
    state.entries.add(noteAsOverlayEntry);
    emit(
      state.copyWith(isNotesMode: true),
    );
    showOverlay(context);
  }

  void onDonePressed() {
    hideOverlay();
    emit(
      state.copyWith(isNotesMode: false),
    );
  }

  void onNotesModePressed(BuildContext context) {
    emit(
      state.copyWith(isNotesMode: !state.isNotesMode),
    );
    showOverlay(context);
  }

  void onPageChanged(BuildContext context, int page) {
    if (page == 1) {
      showOverlay(context);
    } else if (page == 2) {
      hideOverlay();
    }
  }

  void onNoteTextChanged(String noteText) {
    emit(
      state.copyWith(
        note: state.note.copyWith(bodyText: noteText),
      ),
    );
  }
}
