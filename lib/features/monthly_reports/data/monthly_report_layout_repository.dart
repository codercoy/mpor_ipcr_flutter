import 'package:sqflite/sqflite.dart';

import '../../../app/database/app_database.dart';

class MonthlyReportLayout {
  final double activityWidth;
  final double dayWidth;
  final double weekWidth;
  final double monthWidth;
  final double rowHeight;

  const MonthlyReportLayout({
    required this.activityWidth,
    required this.dayWidth,
    required this.weekWidth,
    required this.monthWidth,
    required this.rowHeight,
  });

  static const MonthlyReportLayout defaults =
      MonthlyReportLayout(
    activityWidth: 220,
    dayWidth: 32,
    weekWidth: 40,
    monthWidth: 48,
    rowHeight: 36,
  );
}

class MonthlyReportLayoutRepository {
  final AppDatabase _appDatabase;

  MonthlyReportLayoutRepository({
    AppDatabase? appDatabase,
  }) : _appDatabase =
            appDatabase ?? AppDatabase();

  Future<MonthlyReportLayout> getLayout() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      'monthly_report_layout',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      await _saveLayout(
        MonthlyReportLayout.defaults,
      );

      return MonthlyReportLayout.defaults;
    }

    final row = rows.first;

    return MonthlyReportLayout(
      activityWidth:
          (row['activity_width'] as num).toDouble(),
      dayWidth:
          (row['day_width'] as num).toDouble(),
      weekWidth:
          (row['week_width'] as num).toDouble(),
      monthWidth:
          (row['month_width'] as num).toDouble(),
      rowHeight:
          (row['row_height'] as num).toDouble(),
    );
  }

  Future<void> saveLayout(
    MonthlyReportLayout layout,
  ) async {
    await _saveLayout(layout);
  }

  Future<void> _saveLayout(
    MonthlyReportLayout layout,
  ) async {
    final db = await _appDatabase.database;

    await db.insert(
      'monthly_report_layout',
      {
        'id': 1,
        'activity_width': layout.activityWidth,
        'day_width': layout.dayWidth,
        'week_width': layout.weekWidth,
        'month_width': layout.monthWidth,
        'row_height': layout.rowHeight,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}