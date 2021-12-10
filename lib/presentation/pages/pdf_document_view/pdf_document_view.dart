import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

import 'components/add_note.dart';
import 'cubit/pdf_document_view_cubit.dart';

class PdfDocumentView extends StatefulWidget {
  const PdfDocumentView({Key? key}) : super(key: key);

  @override
  State<PdfDocumentView> createState() => _PdfDocumentViewState();
}

class _PdfDocumentViewState extends State<PdfDocumentView> {
  late PdfDocumentViewCubit cubit;
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
    cubit = context.read<PdfDocumentViewCubit>();
  }

  @override
  void dispose() {
    pdfController.dispose();
    cubit.hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfDocumentViewCubit, PdfDocumentViewState>(
      builder: _buildState,
    );
  }

  Widget _buildState(BuildContext context, PdfDocumentViewState state) {
    return Scaffold(
      appBar: _buildAppBar(context, state),
      body: _buildBody(context, state),
      floatingActionButton:
          state.isNotesMode ? null : _showFloatingActionButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context, PdfDocumentViewState state) {
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

  Widget _buildBody(BuildContext context, PdfDocumentViewState state) {
    return GestureDetector(
      onLongPressStart: (details) {
        cubit.hideOverlay();
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) => _showAddNoteBottomSheet(context, details),
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

  Widget _showAddNoteBottomSheet(
      BuildContext context, LongPressStartDetails details) {
    return AddNote(
      onPressed: () {
        cubit.onAddNotePressed(context, details);
      },
    );
  }
}
