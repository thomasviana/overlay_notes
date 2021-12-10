part of 'pdf_view_page_cubit.dart';

class PdfViewPageState {
  List<OverlayEntry?> entries;
  Note note;

  final bool isNotesMode;

  PdfViewPageState({
    required this.entries,
    required this.note,
    required this.isNotesMode,
  });

  factory PdfViewPageState.initial() => PdfViewPageState(
        isNotesMode: false,
        entries: [],
        note: Note.empty(),
      );

  PdfViewPageState copyWith({
    List<OverlayEntry?>? entries,
    Note? note,
    bool? isNotesMode,
  }) {
    return PdfViewPageState(
      entries: entries ?? this.entries,
      note: note ?? this.note,
      isNotesMode: isNotesMode ?? this.isNotesMode,
    );
  }
}
