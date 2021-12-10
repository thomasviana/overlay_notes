import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection.dart';
import 'presentation/pages/pdf_document_view/cubit/pdf_view_page_cubit.dart';
import 'presentation/pages/pdf_document_view/pdf_view_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureInjection(Environment.prod);
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
      home: BlocProvider(
        create: (context) => sl<PdfViewPageCubit>(),
        child: const PdfViewPage(),
      ),
    );
  }
}
