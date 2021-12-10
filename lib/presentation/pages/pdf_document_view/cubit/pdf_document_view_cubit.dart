import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:overlay/application/add_new_note.dart';

part 'pdf_document_view_state.dart';

@injectable
class PdfDocumentViewCubit extends Cubit<PdfDocumentViewState> {
  AddNewNote addNewNote;
  PdfDocumentViewCubit(
    this.addNewNote,
  ) : super(PdfDocumentViewState.initial());

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

  void onAddNotePressed(BuildContext context, LongPressStartDetails details) {
    final newNote = addNewNote(details.globalPosition);
    print(state.entries.length);
    state.entries.add(newNote);
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
}
