import '../domain/daily_accomplishment_record.dart';
import 'daily_accomplishment_local_datasource.dart';

class DailyAccomplishmentRepository {
  final DailyAccomplishmentLocalDataSource _dataSource;

  DailyAccomplishmentRepository({
    DailyAccomplishmentLocalDataSource? dataSource,
  }) : _dataSource =
            dataSource ?? DailyAccomplishmentLocalDataSource();

  Future<void> save(
    DailyAccomplishmentRecord record,
  ) async {
    await _dataSource.save(record);
  }

  Future<DailyAccomplishmentRecord?> get(
    DateTime date,
  ) async {
    return _dataSource.get(date);
  }

  Future<bool> exists(
    DateTime date,
  ) async {
    return _dataSource.exists(date);
  }

  Future<List<DailyAccomplishmentRecord>> getMonth(
    int year,
    int month,
  ) async {
    return _dataSource.getMonth(year, month);
  }

  Future<void> close() async {
    await _dataSource.close();
  }
}

/// Shared repository instance used by the Daily Accomplishment feature.
///
/// The repository now uses persistent local SQLite storage through
/// DailyAccomplishmentLocalDataSource.
final dailyAccomplishmentRepository =
    DailyAccomplishmentRepository();