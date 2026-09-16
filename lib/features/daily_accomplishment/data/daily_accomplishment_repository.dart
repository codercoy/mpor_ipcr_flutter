import '../domain/daily_accomplishment_record.dart';

class DailyAccomplishmentRepository {
  final Map<DateTime, DailyAccomplishmentRecord> _records = {};

  DateTime _dateKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> save(DailyAccomplishmentRecord record) async {
    final key = _dateKey(record.date);

    _records[key] = record.copyWith(
      date: key,
    );
  }

  Future<DailyAccomplishmentRecord?> get(DateTime date) async {
    return _records[_dateKey(date)];
  }

  Future<bool> exists(DateTime date) async {
    return _records.containsKey(_dateKey(date));
  }

  Future<List<DailyAccomplishmentRecord>> getMonth(
    int year,
    int month,
  ) async {
    return _records.values
        .where(
          (record) =>
              record.date.year == year &&
              record.date.month == month,
        )
        .toList()
      ..sort(
        (a, b) => a.date.compareTo(b.date),
      );
  }
}

/// Shared repository instance used by the Daily Accomplishment feature.
///
/// This is temporary in-memory storage. It will later be replaced by
/// persistent local storage without changing the presentation layer.
final dailyAccomplishmentRepository =
    DailyAccomplishmentRepository();