part of 'pdf_view_page_cubit.dart';

class PdfViewPageState {
  List<OverlayEntry?> notes;
  final bool isNotesMode;

  PdfViewPageState({
    required this.notes,
    required this.isNotesMode,
  });

  factory PdfViewPageState.initial() => PdfViewPageState(
        isNotesMode: false,
        notes: [],
      );

  PdfViewPageState copyWith({
    List<OverlayEntry?>? notes,
    bool? isNotesMode,
  }) {
    return PdfViewPageState(
      notes: notes ?? this.notes,
      isNotesMode: isNotesMode ?? this.isNotesMode,
    );
  }
}
