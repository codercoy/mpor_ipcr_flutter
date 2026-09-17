import 'package:flutter_test/flutter_test.dart';

import 'package:mpor_ipcr_flutter/app/database/app_database.dart';

void main() {
  test(
    'Inspect January 2026 Daily Accomplishment records',
    () async {
      final appDatabase = AppDatabase();
      final db = await appDatabase.database;

      final records = await db.query(
        'daily_accomplishments',
        where: 'date >= ? AND date < ?',
        whereArgs: [
          '2026-01-01',
          '2026-02-01',
        ],
        orderBy: 'date ASC',
      );

      print('');
      print('==============================================');
      print('JANUARY 2026 DAILY ACCOMPLISHMENT RECORDS');
      print('==============================================');
      print('');

      print('Total encoded days: ${records.length}');
      print('');

      for (final record in records) {
        print('----------------------------------------------');
        print('Date: ${record['date']}');
        print('Served Clients: ${record['served_clients']}');
        print(
          'Install/Validate PIN: '
          '${record['install_validate_pin']}',
        );
        print('Checked PIN: ${record['checked_pin']}');
        print(
          'Update Property Index Maps: '
          '${record['update_property_index_maps']}',
        );
        print(
          'Update Tax Map/Control Rolls: '
          '${record['update_tax_map_control_rolls']}',
        );
        print(
          'Update Municipal Digital Base Maps: '
          '${record['update_municipal_digital_base_maps']}',
        );
        print(
          'Plot Technical Description: '
          '${record['plot_technical_description']}',
        );
        print(
          'Prepared Daily Time Record: '
          '${record['prepared_daily_time_record']}',
        );
        print('Submitted MPOR: ${record['submitted_mpor']}');
        print('Submitted IPCR: ${record['submitted_ipcr']}');
        print(
          'Attended Meetings: '
          '${record['attended_meetings']}',
        );
        print(
          'Intervening Tasks: '
          '${record['intervening_tasks']}',
        );
        print(
          'Not Regular Duty: '
          '${record['not_regular_duty']}',
        );
        print(
          'Duty Status Reason: '
          '${record['duty_status_reason']}',
        );
        print('Time In: ${record['time_in']}');
        print('Time Out: ${record['time_out']}');
        print(
          'Tardiness Minutes: '
          '${record['tardiness_minutes']}',
        );
        print(
          'Undertime Minutes: '
          '${record['undertime_minutes']}',
        );
      }

      print('');
      print('==============================================');
      print('END OF JANUARY 2026');
      print('==============================================');
      print('');

      await appDatabase.close();
    },
  );
}