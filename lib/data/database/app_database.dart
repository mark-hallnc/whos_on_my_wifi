import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            LazyDatabase(() async {
              final directory = await getApplicationSupportDirectory();
              return NativeDatabase.createInBackground(
                File(p.join(directory.path, 'wifi_history.sqlite')),
              );
            }),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Add explicit, tested migrations here when increasing schemaVersion.
    // Never silently delete a database when a migration is missing.
    onUpgrade: (m, from, to) async =>
        throw StateError('Missing migration $from -> $to'),
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
