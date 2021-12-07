import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

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
  var count = 0;

  Offset offset1 = const Offset(100, 200);
  Offset offset2 = const Offset(100, 300);

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

  OverlayEntry? entry1;
  OverlayEntry? entry2;
  List<OverlayEntry?>? entries;

  void createNote1() {
    entry1 = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: offset1.dx,
        top: offset1.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            offset1 += details.delta;
            entry1!.markNeedsBuild();
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
    Overlay.of(context)!.insert(entry1!);
  }

  void createNote2() {
    entry2 = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: offset2.dx,
        top: offset2.dy,
        child: GestureDetector(
            onPanUpdate: (details) {
              offset2 += details.delta;
              entry2!.markNeedsBuild();
            },
            child: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.note_rounded,
                color: Colors.white,
              ),
            )),
      ),
    );
    Overlay.of(context)!.insert(entry2!);
  }

  void showOverlay() {
    Overlay.of(context)!.insert(entry1!);
    Overlay.of(context)!.insert(entry2!);
  }

  void hideOverlay({int onPage = 1}) {
    entry1?.remove();
    entry2?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: isEditNotesMode
              ? const Text('')
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
          actions: [
            if (isEditNotesMode) ...[
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    count += 1;
                  });
                  if (count == 1) {
                    createNote1();
                    print('Note 1');
                  } else if (count == 2) {
                    createNote2();
                    print('Note 2');
                  }
                },
              ),
              // IconButton(
              //   icon: const Icon(Icons.add),
              //   onPressed: () {
              //     createNote2();
              //     print('new note');
              //   },
              // ),
            ],
          ]),
      body: PdfView(
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
