part of 'pdf_document_view_cubit.dart';

class PdfDocumentViewState {
  List<OverlayEntry?> entries;
  final bool isNotesMode;

  PdfDocumentViewState({
    required this.entries,
    required this.isNotesMode,
  });

  factory PdfDocumentViewState.initial() => PdfDocumentViewState(
        isNotesMode: false,
        entries: [],
      );

  PdfDocumentViewState copyWith({
    List<OverlayEntry?>? entries,
    bool? isNotesMode,
  }) {
    return PdfDocumentViewState(
      entries: entries ?? this.entries,
      isNotesMode: isNotesMode ?? this.isNotesMode,
    );
  }
}
