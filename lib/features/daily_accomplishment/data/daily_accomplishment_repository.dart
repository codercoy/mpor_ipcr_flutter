import '../domain/daily_accomplishment_record.dart';
import 'daily_accomplishment_local_datasource.dart';

class DailyAccomplishmentRepository {
  final DailyAccomplishmentLocalDataSource _localDataSource;

  DailyAccomplishmentRepository({
    DailyAccomplishmentLocalDataSource? localDataSource,
  }) : _localDataSource =
            localDataSource ?? DailyAccomplishmentLocalDataSource();

  Future<void> save(DailyAccomplishmentRecord record) {
    return _localDataSource.save(record);
  }

  Future<DailyAccomplishmentRecord?> get(DateTime date) {
    return _localDataSource.get(date);
  }

  Future<bool> exists(DateTime date) {
    return _localDataSource.exists(date);
  }

  Future<List<DailyAccomplishmentRecord>> getMonth(
    int year,
    int month,
  ) {
    return _localDataSource.getMonth(year, month);
  }
}

final dailyAccomplishmentRepository =
    DailyAccomplishmentRepository();