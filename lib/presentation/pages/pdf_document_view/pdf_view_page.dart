import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

import '../../../domain/note.dart';
import 'cubit/pdf_view_page_cubit.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({Key? key}) : super(key: key);

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage>
    with SingleTickerProviderStateMixin {
  late PdfViewPageCubit cubit;

  late PdfController pdfController;
  late Future<PdfDocument> pdfDocument;

  late Animation<double> animation;
  late Animation<double> scaleAnimation;
  late AnimationController controller;

  double noteDetailContainerHeight = 300;
  double noteDisplacement = 0;
  double animatedRadius = 20;
  double animatedSize = 20;

  @override
  void initState() {
    pdfDocument = PdfDocument.openAsset('/assets/pdf/sample.pdf');
    pdfController = PdfController(document: pdfDocument);
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(() {
        setState(() {
          noteDisplacement = animation.value * noteDetailContainerHeight;
        });
      });

    scaleAnimation = Tween<double>(begin: 1, end: 0.6).animate(controller)
      ..addListener(() {
        setState(() {
          animatedRadius = scaleAnimation.value * 20;
          animatedSize = scaleAnimation.value * 20;
        });
      });

    super.initState();
    cubit = context.read<PdfViewPageCubit>();
  }

  @override
  void dispose() {
    pdfController.dispose();
    cubit.hideCurrentOverlay();
    controller.dispose();
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
      backgroundColor: Colors.white,
      title: state.isNotesMode
          ? const Text(
              'Notes Mode',
              style: TextStyle(color: Colors.black),
            )
          : const Text(
              'PDF View',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
      leading: state.isNotesMode
          ? TextButton(
              onPressed: () {
                cubit.onDonePressed(context);
                if (state.isNotesMode) {
                  controller.animateBack(0);
                }
              },
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.red),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, PdfViewPageState state) {
    return GestureDetector(
      onLongPressStart: (details) {
        if (!state.isNotesMode || state.isSelectedNote) return;
        cubit.hideCurrentOverlay();
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) => _AddNoteFormBottomSheet(
            details: details,
            onNoteTextChanged: (value) => cubit.onNoteTextChanged(value),
            onAddPressed: () {
              cubit.onAddNotePressed(context, details);
              final overlayNote = _buildNoteAsOverlayEntry(
                  state.notes[state.currentPage]!.last);
              cubit.addOverlayEntry(context, overlayNote);
            },
            onCancelPressed: () => cubit.onCancelPressed(context),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: PdfViewWidget(
              cubit: cubit,
              pdfController: pdfController,
              controller: controller,
            ),
          ),
          _NoteDetailContainer(
            isForwardEnable: state.isForwardEnable,
            isBackwardEnable: state.isBackwardEnable,
            noteDisplacement: noteDisplacement,
            onEditPressed: () {},
            onDeletePressed: () {},
            onNavigateBack: () => cubit.onNavigateBack(context, pdfController),
            onNavigateForward: () {
              cubit.onNavigateForward(context, pdfController);
            },
            noteText: state.currentText,
          )
        ],
      ),
    );
  }

  Widget _showFloatingActionButton() {
    return FloatingActionButton(
      child: const Icon(
        Icons.note_rounded,
        color: Colors.white,
      ),
      onPressed: () => cubit.onNotesModePressed(context),
    );
  }

  OverlayEntry _buildNoteAsOverlayEntry(Note newNote) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final appbarSize = (MediaQuery.of(context).padding.top + kToolbarHeight);
    final bodyHeight = MediaQuery.of(context).size.height - appbarSize;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: newNote.offset.dx - 20,
        top: newNote.offset.dy - 20,
        child: GestureDetector(
          onTap: () {
            cubit.onNoteSelected(context, newNote);
            controller.forward();
          },
          onPanUpdate: (details) {
            newNote.offset += details.delta;
            entry!.markNeedsBuild();
          },
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              // print('Total Height: ${size.height}');
              // print('appBar: $appbarSize');
              // print('body: $bodyHeight');
              // print('Offset dx: ${newNote.offset.dx}');
              // print('Offset dy: ${newNote.offset.dy}');

              //! dx
              final dh1 = size.width / 0.77;
              final vgs = (bodyHeight - dh1) / 2;
              final dy = newNote.offset.dy - vgs - appbarSize;
              final ratioY = (dy / dh1);
              // print('Document Height: $dh1');
              // print('Document Width: ${size.width}');
              // print('Vertical Gray Space: $vgs');
              // print('Ration y (%): $ratioY');
              final newDy =
                  ((bodyHeight - noteDetailContainerHeight) * ratioY) +
                      appbarSize;

              //! dy
              final dh2 = bodyHeight - noteDetailContainerHeight;
              final dw = dh2 * 0.77;
              final hgs = (size.width - dw) / 2;
              final ratioX = (newNote.offset.dx / size.width);
              // print('Document Height 2: $dh2');
              // print('Document Width 2: $dw');
              // print('size.width: ${size.width}');
              // print('Horizontal Gray Space: $hgs');
              // print('Ration y (%): $ratioX');
              final newDx = hgs + (dw * ratioX);

              final startingDy = newNote.offset.dy;
              final startingDx = newNote.offset.dx;

              return Transform(
                transform: Matrix4.translationValues(
                  animation.value * (newDx - startingDx + 8),
                  animation.value * (newDy - startingDy + 8),
                  0.0,
                ),
                child: CircleAvatar(
                  radius: animatedRadius,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.note_rounded,
                    color: Colors.white,
                    size: animatedSize,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    return entry;
  }
}

class PdfViewWidget extends StatelessWidget {
  final PdfViewPageCubit cubit;
  final PdfController pdfController;
  final AnimationController controller;
  const PdfViewWidget({
    Key? key,
    required this.cubit,
    required this.pdfController,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (cubit.state.isSelectedNote) {
          cubit.onDismissNoteDetail(context);
          controller.animateBack(0);
        }
      },
      child: PdfView(
        documentLoader: const Center(child: CircularProgressIndicator()),
        pageLoader: const Center(child: CircularProgressIndicator()),
        controller: pdfController,
        physics: cubit.state.isSelectedNote
            ? const NeverScrollableScrollPhysics()
            : null,
        pageSnapping: true,
        scrollDirection: Axis.vertical,
        onPageChanged: (page) => cubit.onPageChanged(context, page),
      ),
    );
  }
}

class _AddNoteFormBottomSheet extends HookWidget {
  final LongPressStartDetails details;
  final VoidCallback onAddPressed;
  final VoidCallback onCancelPressed;
  final ValueChanged<String> onNoteTextChanged;

  const _AddNoteFormBottomSheet({
    Key? key,
    required this.details,
    required this.onAddPressed,
    required this.onCancelPressed,
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
                    onPressed: () {
                      _close(context);
                      onCancelPressed();
                    }),
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
              onChanged: (value) => onNoteTextChanged(value),
            )
          ],
        ),
      ),
    );
  }

  void _close(BuildContext context) => Navigator.pop(context);
}

class _NoteDetailContainer extends StatelessWidget {
  final String? noteText;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;
  final VoidCallback onNavigateForward;
  final VoidCallback onNavigateBack;
  final bool isForwardEnable;
  final bool isBackwardEnable;

  final double noteDisplacement;
  const _NoteDetailContainer({
    Key? key,
    this.noteText,
    required this.onDeletePressed,
    required this.onEditPressed,
    required this.onNavigateForward,
    required this.onNavigateBack,
    required this.isForwardEnable,
    required this.isBackwardEnable,
    required this.noteDisplacement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
          color: Color(0xFFf2f1f7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      height: noteDisplacement,
      width: double.infinity,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(noteText ?? ''),
                const SizedBox(height: 10),
                const Text(
                  'Today',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                width: 120,
              ),
              IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: isBackwardEnable ? Colors.red : Colors.grey),
                onPressed: isBackwardEnable ? onNavigateBack : null,
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    color: isForwardEnable ? Colors.red : Colors.grey),
                onPressed: isForwardEnable ? onNavigateForward : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
