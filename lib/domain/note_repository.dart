import 'note.dart';

abstract class NoteRepository {
  Future<void> create(Note note);
  Future<void> update(Note note);
  Future<void> delete(Note note);
}
