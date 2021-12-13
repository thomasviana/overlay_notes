part of 'pdf_view_page_cubit.dart';

class PdfViewPageState {
  final Map<int, List<OverlayEntry?>> entries;
  final List<Note> notes;
  final String currentText;
  final int previousPage;
  final int currentPage;
  final bool isNotesMode;

  PdfViewPageState({
    required this.entries,
    required this.notes,
    required this.currentText,
    required this.previousPage,
    required this.currentPage,
    required this.isNotesMode,
  });

  factory PdfViewPageState.initial() => PdfViewPageState(
        isNotesMode: false,
        entries: {1: []},
        notes: [],
        currentText: '',
        previousPage: 1,
        currentPage: 1,
      );

  PdfViewPageState copyWith({
    Map<int, List<OverlayEntry?>>? entries,
    List<Note>? notes,
    String? currentText,
    int? previousPage,
    int? currentPage,
    bool? isNotesMode,
  }) {
    return PdfViewPageState(
      entries: entries ?? this.entries,
      notes: notes ?? this.notes,
      currentText: currentText ?? this.currentText,
      previousPage: previousPage ?? this.previousPage,
      currentPage: currentPage ?? this.currentPage,
      isNotesMode: isNotesMode ?? this.isNotesMode,
    );
  }
}
