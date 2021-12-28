part of 'pdf_view_page_cubit.dart';

class PdfViewPageState {
  final Map<int, List<OverlayEntry?>> entries;
  final Map<int, List<Note>> notes;
  final String? currentText;
  final int? previousPage;
  final int currentPage;
  final Note? currentNote;
  final bool isNotesMode;
  final bool isSelectedNote;
  final bool isForwardEnable;
  final bool isBackwardEnable;

  PdfViewPageState({
    required this.entries,
    required this.notes,
    this.currentText,
    this.previousPage,
    required this.currentPage,
    this.currentNote,
    required this.isNotesMode,
    required this.isSelectedNote,
    required this.isForwardEnable,
    required this.isBackwardEnable,
  });

  factory PdfViewPageState.initial() => PdfViewPageState(
        notes: {1: []},
        entries: {1: []},
        currentPage: 1,
        isNotesMode: false,
        isSelectedNote: false,
        isForwardEnable: false,
        isBackwardEnable: false,
      );

  PdfViewPageState copyWith({
    Map<int, List<OverlayEntry?>>? entries,
    Map<int, List<Note>>? notes,
    String? currentText,
    int? previousPage,
    int? currentPage,
    Note? currentNote,
    bool? isNotesMode,
    bool? isSelectedNote,
    bool? isForwardEnable,
    bool? isBackwardEnable,
  }) {
    return PdfViewPageState(
      entries: entries ?? this.entries,
      notes: notes ?? this.notes,
      currentText: currentText ?? this.currentText,
      previousPage: previousPage ?? this.previousPage,
      currentPage: currentPage ?? this.currentPage,
      currentNote: currentNote ?? this.currentNote,
      isNotesMode: isNotesMode ?? this.isNotesMode,
      isSelectedNote: isSelectedNote ?? this.isSelectedNote,
      isForwardEnable: isForwardEnable ?? this.isForwardEnable,
      isBackwardEnable: isBackwardEnable ?? this.isBackwardEnable,
    );
  }
}
