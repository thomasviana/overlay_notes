import 'package:injectable/injectable.dart';

import '../domain/note.dart';
import '../domain/note_repository.dart';

@LazySingleton(as: NoteRepository)
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl();

  @override
  Future<void> create(Note note) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(Note note) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> update(Note note) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
