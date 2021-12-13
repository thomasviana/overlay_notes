import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/note.dart';

part 'pdf_view_page_state.dart';

@injectable
class PdfViewPageCubit extends Cubit<PdfViewPageState> {
  PdfViewPageCubit() : super(PdfViewPageState.initial());

  void hidePreviousOverlay() {
    final previousPageNotes = state.entries[state.previousPage];
    if (previousPageNotes == null || previousPageNotes.isEmpty) return;
    for (var entry in previousPageNotes) {
      entry?.remove();
    }
  }

  void hideCurrentOverlay() {
    final currentPageNotes = state.entries[state.currentPage];
    if (currentPageNotes == null || currentPageNotes.isEmpty) return;
    for (var entry in currentPageNotes) {
      entry?.remove();
    }
  }

  void addOverlayEntry(BuildContext context, OverlayEntry entry) {
    final currentPageNotes = state.entries[state.currentPage];

    if (currentPageNotes == null) {
      state.entries.putIfAbsent(state.currentPage, () => [entry]);
    } else {
      currentPageNotes.add(entry);
    }
    showOverlay(context);
    print(state.entries);
  }

  void showOverlay(BuildContext context) {
    final currentPageNotes = state.entries[state.currentPage];
    if (currentPageNotes == null || currentPageNotes.isEmpty) return;
    for (var entry in currentPageNotes) {
      Overlay.of(context)!.insert(entry!);
    }
  }

  void onAddNotePressed(BuildContext context, LongPressStartDetails details) {
    state.notes.add(Note.empty()
        .copyWith(details.globalPosition, bodyText: state.currentText));
    emit(state.copyWith(isNotesMode: true));
  }

  void onDonePressed() {
    hideCurrentOverlay();
    emit(state.copyWith(isNotesMode: false));
  }

  void onNotesModePressed(BuildContext context) {
    emit(state.copyWith(isNotesMode: true));
    showOverlay(context);
  }

  void onPageChanged(BuildContext context, int page) {
    emit(state.copyWith(previousPage: state.currentPage));
    emit(state.copyWith(currentPage: page));
    if (!state.isNotesMode) return;
    hidePreviousOverlay();
    showOverlay(context);
  }

  void onNoteTextChanged(String noteText) {
    emit(state.copyWith(currentText: noteText, isAddEnabled: true));
  }
}
