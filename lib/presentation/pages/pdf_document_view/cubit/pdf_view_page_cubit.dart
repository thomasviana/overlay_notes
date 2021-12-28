import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

import '../../../../domain/note.dart';

part 'pdf_view_page_state.dart';

@injectable
class PdfViewPageCubit extends Cubit<PdfViewPageState> {
  PdfViewPageCubit() : super(PdfViewPageState.initial());

  void hideCurrentOverlay() {
    final currentPageEntries = state.entries[state.currentPage];
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    for (var entry in currentPageEntries) {
      entry?.remove();
    }
  }

  void addOverlayEntry(BuildContext context, OverlayEntry entry) {
    final currentPageEntries = state.entries[state.currentPage];
    if (currentPageEntries == null) {
      state.entries.putIfAbsent(state.currentPage, () => [entry]);
    } else {
      currentPageEntries.add(entry);
    }
    _showOverlay(context);
  }

  void _showOverlay(BuildContext context) {
    final currentPageEntries = state.entries[state.currentPage];
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    for (var entry in currentPageEntries) {
      Overlay.of(context)!.insert(entry!);
    }
  }

  void onAddNotePressed(BuildContext context, LongPressStartDetails details) {
    final currentPageNotes = state.notes[state.currentPage];
    final newNote = Note.empty()
        .copyWith(details.globalPosition, bodyText: state.currentText);
    if (currentPageNotes == null) {
      state.notes.putIfAbsent(state.currentPage, () => [newNote]);
    } else {
      currentPageNotes.add(newNote);
    }
  }

  void onCancelPressed(BuildContext context) {
    _showOverlay(context);
  }

  void onDonePressed(context) {
    if (state.isSelectedNote) {
      _hideSingleNote();
    } else {
      hideCurrentOverlay();
    }
    emit(state.copyWith(isSelectedNote: false, isNotesMode: false));
  }

  void _hideSingleNote() {
    final currentPageEntries = state.entries[state.currentPage];
    final currentPageNotes = state.notes[state.currentPage];
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    final index = currentPageNotes!
        .indexWhere((note) => note.id == state.currentNote!.id);
    currentPageEntries[index]?.remove();
  }

  void _hidePrevSingleNote() {
    final prevPageEntries = state.entries[state.previousPage];
    if (prevPageEntries == null || prevPageEntries.isEmpty) return;
    prevPageEntries.last?.remove();
  }

  void _showNextSingleNote(BuildContext context) {
    final nextPageEntries = state.entries[state.currentPage + 1];
    if (nextPageEntries == null || nextPageEntries.isEmpty) return;

    Overlay.of(context)!.insert(nextPageEntries.first!);

    final prevPageEntries = state.entries[state.previousPage];
    if (prevPageEntries == null || prevPageEntries.isEmpty) return;
    prevPageEntries.last?.remove();
  }

  void onNotesModePressed(BuildContext context) {
    emit(state.copyWith(isNotesMode: !state.isNotesMode));
    _showOverlay(context);
  }

  void onNoteSelected(BuildContext context, Note selectedNote) {
    final notesList = state.notes[state.currentPage]!;
    final noteIndex =
        notesList.indexWhere((note) => note.id == selectedNote.id);
    emit(
      state.copyWith(
        isSelectedNote: !state.isSelectedNote,
        currentText: notesList[noteIndex].bodyText,
        currentNote: selectedNote,
      ),
    );
    hideCurrentOverlay();
    _showSingleNote(context, selectedNote);
    _checkNavigationAvailability();
  }

  void _showSingleNote(BuildContext context, Note selectedNote) {
    final currentPageEntries = state.entries[state.currentPage];
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    var index = state.notes[state.currentPage]!
        .indexWhere((note) => note.id == selectedNote.id);
    Overlay.of(context)!.insert(currentPageEntries[index]!);
  }

  void _showOtherNotes(BuildContext context) {
    final currentPageEntries = state.entries[state.currentPage];
    final currentPageNotes = state.notes[state.currentPage]!;
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    final index =
        currentPageNotes.indexWhere((note) => note.id == state.currentNote!.id);
    for (var i = 0; i < currentPageEntries.length; i++) {
      if (i != index) {
        Overlay.of(context)!.insert(currentPageEntries[i]!);
      }
    }
  }

  void onNavigateForward(BuildContext context, PdfController pdfController) {
    final currentPageNotes = state.notes[state.currentPage]!;
    final nextPage = state.currentPage + 1;
    final index =
        currentPageNotes.indexWhere((note) => note.id == state.currentNote!.id);
    if (index == currentPageNotes.length - 1 && state.notes[nextPage] != null) {
      _hideCurrentNote();
      pdfController.jumpToPage(state.currentPage + 1);
    } else {
      _hideCurrentNote();
      _showNextNote(context);
    }
    _checkNavigationAvailability();
  }

  void onNavigateBack(BuildContext context, PdfController pdfController) {
    final currentPageNotes = state.notes[state.currentPage]!;
    final prevPage = state.currentPage - 1;
    final index =
        currentPageNotes.indexWhere((note) => note.id == state.currentNote!.id);
    if (index == 0 && state.notes[prevPage] != null) {
      _hideCurrentNote();
      pdfController.jumpToPage(state.currentPage - 1);
    } else {
      _hideCurrentNote();
      _showPrevNote(context);
    }
    _checkNavigationAvailability();
  }

  void _hideCurrentNote() {
    final currentPageEntries = state.entries[state.currentPage];
    final currentPageNotes = state.notes[state.currentPage]!;
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    final index =
        currentPageNotes.indexWhere((note) => note.id == state.currentNote!.id);
    currentPageEntries[index]?.remove();
  }

  void _showNextNote(BuildContext context) {
    final currentPageEntries = state.entries[state.currentPage];
    final currentPageNotes = state.notes[state.currentPage]!;
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    var index =
        currentPageNotes.indexWhere((note) => note.id == state.currentNote!.id);
    print('current page: ${state.currentPage}');

    emit(state.copyWith(currentNote: currentPageNotes[index + 1]));
    Overlay.of(context)!.insert(currentPageEntries[index + 1]!);

    emit(state.copyWith(currentText: state.currentNote!.bodyText));
  }

  void _showPrevNote(BuildContext context) {
    final currentPageEntries = state.entries[state.currentPage];
    final currentPageNotes = state.notes[state.currentPage]!;
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    final index = state.notes[state.currentPage]!
        .indexWhere((note) => note.id == state.currentNote!.id);
    emit(state.copyWith(currentNote: currentPageNotes[index - 1]));
    Overlay.of(context)!.insert(currentPageEntries[index - 1]!);
    emit(state.copyWith(currentText: state.currentNote!.bodyText));
  }

  void onDismissNoteDetail(BuildContext context) {
    _showOtherNotes(context);
    emit(state.copyWith(isSelectedNote: false));
  }

  void onPageChanged(BuildContext context, int page) {
    emit(state.copyWith(previousPage: state.currentPage));
    emit(state.copyWith(currentPage: page));

    if (!state.isNotesMode) return;
    if (state.isSelectedNote) {
      // _hidePrevSingleNote();
      if (state.notes[state.currentPage] != null) {
        if (state.currentPage > state.previousPage!) {
          emit(state.copyWith(
              currentNote: state.notes[state.currentPage]!.first));
          print('navigating forward');
        } else {
          emit(state.copyWith(
              currentNote: state.notes[state.currentPage]!.last));
          print('navigating back');
        }
        _changeNoteOnPageChanged(context);
      }
    } else {
      _hidePreviousOverlay();
      _showOverlay(context);
    }
  }

  void _changeNoteOnPageChanged(BuildContext context) {
    final currentPageEntries = state.entries[state.currentPage];
    final currentPageNotes = state.notes[state.currentPage]!;
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    var index =
        currentPageNotes.indexWhere((note) => note.id == state.currentNote!.id);
    Overlay.of(context)!.insert(currentPageEntries[index]!);
    emit(state.copyWith(currentText: state.currentNote!.bodyText));
  }

  void _hidePreviousOverlay() {
    final previousPageNotes = state.entries[state.previousPage];
    if (previousPageNotes == null || previousPageNotes.isEmpty) return;
    for (var entry in previousPageNotes) {
      entry?.remove();
    }
  }

  void onNoteTextChanged(String noteText) {
    emit(state.copyWith(currentText: noteText));
  }

  void _checkNavigationAvailability() {
    final currentPageEntries = state.entries[state.currentPage];
    final currentPageNotes = state.notes[state.currentPage] ?? [];
    if (currentPageEntries == null || currentPageEntries.isEmpty) return;
    print('pagenotes length: ${currentPageNotes.length}');
    final index =
        currentPageNotes.indexWhere((note) => note.id == state.currentNote!.id);
    print('index : $index');
    if (index == currentPageNotes.length - 1 &&
        state.notes[state.currentPage + 1] == null) {
      emit(state.copyWith(isForwardEnable: false));
    } else if (currentPageNotes.length > 1 ||
        state.notes[state.currentPage + 1] != null) {
      emit(state.copyWith(isForwardEnable: true));
    }
    if (index > 0 || state.notes[state.currentPage - 1] != null) {
      emit(state.copyWith(isBackwardEnable: true));
    } else {
      emit(state.copyWith(isBackwardEnable: false));
    }
  }
}
