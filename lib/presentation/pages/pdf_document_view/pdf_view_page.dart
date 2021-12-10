import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

import 'cubit/pdf_view_page_cubit.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({Key? key}) : super(key: key);

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  late PdfViewPageCubit cubit;
  late PdfController pdfController;
  late Future<PdfDocument> pdfDocument;

  @override
  void initState() {
    pdfDocument = PdfDocument.openAsset('/assets/pdf/sample.pdf');
    pdfController = PdfController(
      document: pdfDocument,
    );
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   showOverlay();
    // });
    super.initState();
    cubit = context.read<PdfViewPageCubit>();
  }

  @override
  void dispose() {
    pdfController.dispose();
    cubit.hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfViewPageCubit, PdfViewPageState>(
      builder: _buildState,
    );
  }

  Widget _buildState(BuildContext context, PdfViewPageState state) {
    return Scaffold(
      appBar: _buildAppBar(context, state),
      body: _buildBody(context, state),
      floatingActionButton:
          state.isNotesMode ? null : _showFloatingActionButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context, PdfViewPageState state) {
    return AppBar(
      title: state.isNotesMode
          ? const Text('Notes Mode')
          : const Text(
              'PDF View',
              textAlign: TextAlign.center,
            ),
      leading: state.isNotesMode
          ? TextButton(
              onPressed: cubit.onDonePressed,
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, PdfViewPageState state) {
    return GestureDetector(
      onLongPressStart: (details) {
        cubit.hideOverlay();
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) => _AddNoteFormBottomSheet(
              details: details,
              onNoteTextChanged: (value) => cubit.onNoteTextChanged(value),
              onAddPressed: () {
                final noteAsOverlayEntry =
                    _buildNoteAsOverlayEntry(details.globalPosition);
                cubit.onAddNotePressed(context, noteAsOverlayEntry);
              }),
        );
      },
      child: PdfView(
        documentLoader: const Center(child: CircularProgressIndicator()),
        pageLoader: const Center(child: CircularProgressIndicator()),
        controller: pdfController,
        pageSnapping: false,
        scrollDirection: Axis.vertical,
        onPageChanged: (page) => cubit.onPageChanged(context, page),
      ),
    );
  }

  Widget _showFloatingActionButton() {
    return FloatingActionButton(
      child: const Icon(
        Icons.note_rounded,
        color: Colors.white,
      ),
      onPressed: () {
        cubit.onNotesModePressed(context);
      },
    );
  }

  OverlayEntry _buildNoteAsOverlayEntry(Offset offset) {
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
              builder: (context) => _NoteDetailBottomSheet(
                noteText: cubit.state.note.bodyText,
                onDeletePressed: () {},
                onMorePressed: () {},
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

class _AddNoteFormBottomSheet extends HookWidget {
  final LongPressStartDetails details;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onNoteTextChanged;

  const _AddNoteFormBottomSheet({
    Key? key,
    required this.details,
    required this.onAddPressed,
    required this.onNoteTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textEditingController = useTextEditingController();

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => _close(context),
                ),
                const Text('Add a note'),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    _close(context);
                    Future.delayed(const Duration(milliseconds: 0), () {
                      onAddPressed();
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Note',
              ),
              onChanged: (value) {
                onNoteTextChanged(value);
              },
            )
          ],
        ),
      ),
    );
  }

  void _close(BuildContext context) => Navigator.pop(context);
}

class _NoteDetailBottomSheet extends HookWidget {
  final String? noteText;
  final VoidCallback onMorePressed;
  final VoidCallback onDeletePressed;

  const _NoteDetailBottomSheet({
    Key? key,
    required this.noteText,
    required this.onMorePressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      maxChildSize: 0.35,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () => _close(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
            Container(
              child: Text(noteText ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  void _close(BuildContext context) => Navigator.pop(context);
}
