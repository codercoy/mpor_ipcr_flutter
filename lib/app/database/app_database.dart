import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static const String defaultDatabaseName = 'mpor_ipcr.db';

  static const int _databaseVersion = 3;

  static bool _factoryInitialized = false;

  final String databaseName;

  Database? _database;

  AppDatabase({
    this.databaseName = defaultDatabaseName,
  });

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _initializeDatabaseFactory();

    _database = await _openDatabase();

    return _database!;
  }

  void _initializeDatabaseFactory() {
    if (_factoryInitialized) {
      return;
    }

    if (Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _factoryInitialized = true;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      databaseName,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createDailyAccomplishmentsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createDailyAccomplishmentsTable(db);
        }

        if (oldVersion < 3) {
          await _upgradeToVersion3(db);
        }
      },
    );
  }

  Future<void> _createDailyAccomplishmentsTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE daily_accomplishments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,

        daily_status TEXT NOT NULL DEFAULT 'accomplishment',
        leave_type TEXT,
        leave_other_reason TEXT,

        served_clients INTEGER NOT NULL DEFAULT 0,
        install_validate_pin INTEGER NOT NULL DEFAULT 0,
        checked_pin INTEGER NOT NULL DEFAULT 0,
        update_property_index_maps INTEGER NOT NULL DEFAULT 0,
        update_tax_map_control_rolls INTEGER NOT NULL DEFAULT 0,
        update_municipal_digital_base_maps INTEGER NOT NULL DEFAULT 0,
        plot_technical_description INTEGER NOT NULL DEFAULT 0,
        prepared_daily_time_record INTEGER NOT NULL DEFAULT 0,
        submitted_mpor INTEGER NOT NULL DEFAULT 0,
        submitted_ipcr INTEGER NOT NULL DEFAULT 0,
        attended_meetings INTEGER NOT NULL DEFAULT 0,
        intervening_tasks INTEGER NOT NULL DEFAULT 0,

        not_regular_duty INTEGER NOT NULL DEFAULT 0,
        duty_status_reason TEXT,

        time_in TEXT,
        time_out TEXT,

        tardiness_minutes INTEGER NOT NULL DEFAULT 0,
        undertime_minutes INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeToVersion3(
    Database db,
  ) async {
    await db.execute('''
      ALTER TABLE daily_accomplishments
      ADD COLUMN daily_status TEXT
      NOT NULL DEFAULT 'accomplishment'
    ''');

    await db.execute('''
      ALTER TABLE daily_accomplishments
      ADD COLUMN leave_type TEXT
    ''');

    await db.execute('''
      ALTER TABLE daily_accomplishments
      ADD COLUMN leave_other_reason TEXT
    ''');

    // Preserve and convert existing legacy records.
    //
    // Existing "Leave" records become structured Leave records.
    await db.update(
      'daily_accomplishments',
      {
        'daily_status': 'leave',
      },
      where: 'not_regular_duty = 1 AND duty_status_reason = ?',
      whereArgs: ['Leave'],
    );

    // Existing holiday records become structured Holiday records.
    await db.update(
      'daily_accomplishments',
      {
        'daily_status': 'holiday',
      },
      where:
          'not_regular_duty = 1 AND duty_status_reason = ?',
      whereArgs: ['Holiday / Non-Working Day'],
    );

    // Existing travel order records.
    await db.update(
      'daily_accomplishments',
      {
        'daily_status': 'travelOrder',
      },
      where:
          'not_regular_duty = 1 AND duty_status_reason = ?',
      whereArgs: ['Travel Order'],
    );

    // Existing official training records.
    await db.update(
      'daily_accomplishments',
      {
        'daily_status': 'officialTraining',
      },
      where:
          'not_regular_duty = 1 AND duty_status_reason = ?',
      whereArgs: [
        'Official Training / Seminar / Workshop',
      ],
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}