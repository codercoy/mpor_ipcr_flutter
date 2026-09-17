import 'package:flutter_test/flutter_test.dart';

import 'package:mpor_ipcr_flutter/app/database/app_database.dart';
import 'package:mpor_ipcr_flutter/features/daily_accomplishment/data/daily_accomplishment_local_datasource.dart';
import 'package:mpor_ipcr_flutter/features/daily_accomplishment/domain/daily_accomplishment_record.dart';

void main() {
  late AppDatabase appDatabase;
  late DailyAccomplishmentLocalDataSource dataSource;

  setUp(() async {
    appDatabase = AppDatabase(
      databaseName: 'mpor_ipcr_test.db',
    );

    dataSource = DailyAccomplishmentLocalDataSource(
      appDatabase: appDatabase,
    );

    final db = await appDatabase.database;

    await db.delete('daily_accomplishments');
  });

  tearDown(() async {
    await dataSource.close();
  });

  test(
    'DailyAccomplishmentLocalDataSource saves and retrieves a record',
    () async {
      final record = DailyAccomplishmentRecord(
        date: DateTime(2026, 9, 17),
        servedClients: 12,
        installValidatePin: 3,
        checkedPin: 4,
        updatePropertyIndexMaps: 5,
        updateTaxMapControlRolls: 6,
        updateMunicipalDigitalBaseMaps: 7,
        plotTechnicalDescription: 8,
        preparedDailyTimeRecord: 1,
        submittedMpor: 1,
        submittedIpcr: 1,
        attendedMeetings: 2,
        interveningTasks: 3,
        notRegularDuty: false,
        timeIn: DateTime(2026, 9, 17, 8, 5),
        timeOut: DateTime(2026, 9, 17, 16, 30),
        tardinessMinutes: 5,
        undertimeMinutes: 30,
      );

      await dataSource.save(record);

      final retrieved = await dataSource.get(
        DateTime(2026, 9, 17, 14, 30),
      );

      expect(retrieved, isNotNull);
      expect(retrieved!.date, DateTime(2026, 9, 17));

      expect(retrieved.servedClients, 12);
      expect(retrieved.installValidatePin, 3);
      expect(retrieved.checkedPin, 4);
      expect(retrieved.updatePropertyIndexMaps, 5);
      expect(retrieved.updateTaxMapControlRolls, 6);
      expect(retrieved.updateMunicipalDigitalBaseMaps, 7);
      expect(retrieved.plotTechnicalDescription, 8);
      expect(retrieved.preparedDailyTimeRecord, 1);
      expect(retrieved.submittedMpor, 1);
      expect(retrieved.submittedIpcr, 1);
      expect(retrieved.attendedMeetings, 2);
      expect(retrieved.interveningTasks, 3);

      expect(retrieved.notRegularDuty, false);

      expect(
        retrieved.timeIn,
        DateTime(2026, 9, 17, 8, 5),
      );

      expect(
        retrieved.timeOut,
        DateTime(2026, 9, 17, 16, 30),
      );

      expect(retrieved.tardinessMinutes, 5);
      expect(retrieved.undertimeMinutes, 30);

      expect(
        await dataSource.exists(DateTime(2026, 9, 17)),
        isTrue,
      );

      expect(
        await dataSource.exists(DateTime(2026, 9, 18)),
        isFalse,
      );
    },
  );

  test(
    'DailyAccomplishmentLocalDataSource returns null for missing record',
    () async {
      final result = await dataSource.get(
        DateTime(2026, 9, 18),
      );

      expect(result, isNull);
    },
  );

  test(
    'DailyAccomplishmentLocalDataSource replaces an existing date',
    () async {
      final original = DailyAccomplishmentRecord(
        date: DateTime(2026, 9, 17),
        servedClients: 10,
      );

      await dataSource.save(original);

      final updated = DailyAccomplishmentRecord(
        date: DateTime(2026, 9, 17),
        servedClients: 25,
        checkedPin: 5,
      );

      await dataSource.save(updated);

      final retrieved = await dataSource.get(
        DateTime(2026, 9, 17),
      );

      expect(retrieved, isNotNull);
      expect(retrieved!.servedClients, 25);
      expect(retrieved.checkedPin, 5);
    },
  );

  test(
    'DailyAccomplishmentLocalDataSource returns month records sorted by date',
    () async {
      await dataSource.save(
        DailyAccomplishmentRecord(
          date: DateTime(2026, 9, 20),
          servedClients: 20,
        ),
      );

      await dataSource.save(
        DailyAccomplishmentRecord(
          date: DateTime(2026, 9, 5),
          servedClients: 5,
        ),
      );

      await dataSource.save(
        DailyAccomplishmentRecord(
          date: DateTime(2026, 9, 12),
          servedClients: 12,
        ),
      );

      await dataSource.save(
        DailyAccomplishmentRecord(
          date: DateTime(2026, 10, 1),
          servedClients: 100,
        ),
      );

      final records = await dataSource.getMonth(
        2026,
        9,
      );

      expect(records.length, 3);

      expect(
        records[0].date,
        DateTime(2026, 9, 5),
      );
      expect(records[0].servedClients, 5);

      expect(
        records[1].date,
        DateTime(2026, 9, 12),
      );
      expect(records[1].servedClients, 12);

      expect(
        records[2].date,
        DateTime(2026, 9, 20),
      );
      expect(records[2].servedClients, 20);
    },
  );
}