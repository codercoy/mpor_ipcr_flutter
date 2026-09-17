import 'package:flutter_test/flutter_test.dart';
import 'package:mpor_ipcr_flutter/app/database/app_database.dart';

void main() {
  test('AppDatabase creates the Daily Accomplishment table', () async {
    final database = AppDatabase();

    final db = await database.database;

    expect(db.isOpen, isTrue);

    final tables = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'daily_accomplishments'
      ''',
    );

    expect(tables.length, 1);
    expect(tables.first['name'], 'daily_accomplishments');

    await database.close();

    expect(db.isOpen, isFalse);
  });
}