// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'application/add_new_note.dart' as _i3;
import 'presentation/pages/pdf_document_view/cubit/pdf_document_view_cubit.dart'
    as _i4; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.factory<_i3.AddNewNote>(() => _i3.AddNewNote());
  gh.factory<_i4.PdfDocumentViewCubit>(
      () => _i4.PdfDocumentViewCubit(get<_i3.AddNewNote>()));
  return get;
}
