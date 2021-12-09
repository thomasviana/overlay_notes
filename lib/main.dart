import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:overlay/note_detail.dart';

import 'add_note.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add notes to documents',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Add notes to documents'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PdfController _pdfController;
  late Future<PdfDocument> _pdfDocument;
  bool isEditNotesMode = false;

  @override
  void initState() {
    _pdfDocument = PdfDocument.openAsset('/assets/pdf/sample2.pdf');
    _pdfController = PdfController(
      document: _pdfDocument,
    );
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   showOverlay();
    // });
    super.initState();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    hideOverlay();
    super.dispose();
  }

  List<OverlayEntry?> entries = [];

  OverlayEntry createNote(offset) {
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
              builder: (context) => NoteDatail(
                onPressed: () {},
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
    entries.add(entry);
    return entry;
  }

  void showOverlay() {
    if (entries.isEmpty) return;
    for (var entry in entries) {
      assert(entry != null);
      Overlay.of(context)!.insert(entry!);
    }
  }

  void hideOverlay({int onPage = 1}) {
    if (entries.isEmpty) return;
    for (var entry in entries) {
      entry?.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEditNotesMode
            ? const Text('Notes Mode')
            : const Text(
                'PDF View',
                textAlign: TextAlign.center,
              ),
        leading: isEditNotesMode
            ? TextButton(
                onPressed: () {
                  hideOverlay();
                  setState(() {
                    isEditNotesMode = !isEditNotesMode;
                  });
                },
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
      ),
      body: GestureDetector(
        onLongPressStart: (details) {
          hideOverlay();
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            context: context,
            builder: (context) => AddNote(
              onPressed: () {
                setState(() {
                  isEditNotesMode = true;
                });
                createNote(details.globalPosition);
                showOverlay();
                print(entries.length);
              },
            ),
          );
        },
        child: PdfView(
          documentLoader: const Center(child: CircularProgressIndicator()),
          pageLoader: const Center(child: CircularProgressIndicator()),
          controller: _pdfController,
          pageSnapping: false,
          scrollDirection: Axis.vertical,
          onPageChanged: (page) {
            if (page == 1 && isEditNotesMode) {
              showOverlay();
            } else {
              hideOverlay();
            }
          },
        ),
      ),
      floatingActionButton: isEditNotesMode
          ? null
          : FloatingActionButton(
              child: const Icon(
                Icons.note_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isEditNotesMode = !isEditNotesMode;
                });
                showOverlay();
              },
            ),
    );
  }
}
