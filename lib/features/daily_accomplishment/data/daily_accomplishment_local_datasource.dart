import 'package:sqflite/sqflite.dart';

import '../../../app/database/app_database.dart';
import '../domain/daily_accomplishment_record.dart';

class DailyAccomplishmentLocalDataSource {
  final AppDatabase _appDatabase;

  DailyAccomplishmentLocalDataSource({
    AppDatabase? appDatabase,
  }) : _appDatabase = appDatabase ?? AppDatabase();

  Future<void> save(DailyAccomplishmentRecord record) async {
    final db = await _appDatabase.database;

    final normalizedDate = DateTime(
      record.date.year,
      record.date.month,
      record.date.day,
    );

    await db.insert(
      'daily_accomplishments',
      _toMap(record, normalizedDate),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyAccomplishmentRecord?> get(DateTime date) async {
    final db = await _appDatabase.database;

    final normalizedDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final rows = await db.query(
      'daily_accomplishments',
      where: 'date = ?',
      whereArgs: [_dateToString(normalizedDate)],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _fromMap(rows.first);
  }

  Future<bool> exists(DateTime date) async {
    final db = await _appDatabase.database;

    final normalizedDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final rows = await db.query(
      'daily_accomplishments',
      columns: ['id'],
      where: 'date = ?',
      whereArgs: [_dateToString(normalizedDate)],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<List<DailyAccomplishmentRecord>> getMonth(
    int year,
    int month,
  ) async {
    final db = await _appDatabase.database;

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final rows = await db.query(
      'daily_accomplishments',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        _dateToString(startDate),
        _dateToString(endDate),
      ],
      orderBy: 'date ASC',
    );

    return rows.map(_fromMap).toList();
  }

  Map<String, dynamic> _toMap(
    DailyAccomplishmentRecord record,
    DateTime normalizedDate,
  ) {
    return {
      'date': _dateToString(normalizedDate),

      'served_clients': record.servedClients,
      'install_validate_pin': record.installValidatePin,
      'checked_pin': record.checkedPin,
      'update_property_index_maps':
          record.updatePropertyIndexMaps,
      'update_tax_map_control_rolls':
          record.updateTaxMapControlRolls,
      'update_municipal_digital_base_maps':
          record.updateMunicipalDigitalBaseMaps,
      'plot_technical_description':
          record.plotTechnicalDescription,
      'prepared_daily_time_record':
          record.preparedDailyTimeRecord,
      'submitted_mpor': record.submittedMpor,
      'submitted_ipcr': record.submittedIpcr,
      'attended_meetings': record.attendedMeetings,
      'intervening_tasks': record.interveningTasks,

      'not_regular_duty':
          record.notRegularDuty ? 1 : 0,
      'duty_status_reason':
          record.dutyStatusReason,

      'time_in':
          record.timeIn?.toIso8601String(),
      'time_out':
          record.timeOut?.toIso8601String(),

      'tardiness_minutes':
          record.tardinessMinutes,
      'undertime_minutes':
          record.undertimeMinutes,
    };
  }

  DailyAccomplishmentRecord _fromMap(
    Map<String, dynamic> map,
  ) {
    return DailyAccomplishmentRecord(
      date: DateTime.parse(map['date'] as String),

      servedClients:
          map['served_clients'] as int,
      installValidatePin:
          map['install_validate_pin'] as int,
      checkedPin:
          map['checked_pin'] as int,
      updatePropertyIndexMaps:
          map['update_property_index_maps'] as int,
      updateTaxMapControlRolls:
          map['update_tax_map_control_rolls'] as int,
      updateMunicipalDigitalBaseMaps:
          map['update_municipal_digital_base_maps'] as int,
      plotTechnicalDescription:
          map['plot_technical_description'] as int,
      preparedDailyTimeRecord:
          map['prepared_daily_time_record'] as int,
      submittedMpor:
          map['submitted_mpor'] as int,
      submittedIpcr:
          map['submitted_ipcr'] as int,
      attendedMeetings:
          map['attended_meetings'] as int,
      interveningTasks:
          map['intervening_tasks'] as int,

      notRegularDuty:
          (map['not_regular_duty'] as int) == 1,
      dutyStatusReason:
          map['duty_status_reason'] as String?,

      timeIn: map['time_in'] == null
          ? null
          : DateTime.parse(map['time_in'] as String),

      timeOut: map['time_out'] == null
          ? null
          : DateTime.parse(map['time_out'] as String),

      tardinessMinutes:
          map['tardiness_minutes'] as int,
      undertimeMinutes:
          map['undertime_minutes'] as int,
    );
  }

  String _dateToString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> close() async {
    await _appDatabase.close();
  }
}