import 'package:flutter/material.dart';

import '../domain/daily_accomplishment_record.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, DailyAccomplishmentStatus> statusByDate;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarWidget({
    super.key,
    required this.month,
    required this.statusByDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(
      month.year,
      month.month,
      1,
    );

    final daysInMonth = DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;

    // Sunday-first calendar:
    // Sunday = 0, Monday = 1, ..., Saturday = 6.
    final leadingEmptyDays =
        firstDayOfMonth.weekday % 7;

    final totalCells =
        ((leadingEmptyDays + daysInMonth) / 7).ceil() * 7;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.25,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayNumber =
                  index - leadingEmptyDays + 1;

              if (dayNumber < 1 ||
                  dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                month.year,
                month.month,
                dayNumber,
              );

              final normalizedDate = DateTime(
                date.year,
                date.month,
                date.day,
              );

              final status =
                  statusByDate[normalizedDate];

              return _buildDayCell(
                context,
                date,
                status,
              );
            },
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];

    return Row(
      children: weekdays.map((day) {
        final isWeekend =
            day == 'Sat' || day == 'Sun';

        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? Colors.grey.shade500
                    : Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime date,
    DailyAccomplishmentStatus? status,
  ) {
    final isToday = _isSameDate(
      date,
      DateTime.now(),
    );

    final isWeekend =
        date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onDateSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: isWeekend
                  ? Colors.grey.shade200
                  : Colors.transparent,
              border: Border.all(
                color: isToday
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                    : Colors.grey.shade300,
                width: isToday ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isToday
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isWeekend
                        ? Colors.grey.shade600
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                if (status != null)
                  _buildStatusIndicator(status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
    DailyAccomplishmentStatus status,
  ) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _statusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _statusColor(
    DailyAccomplishmentStatus status,
  ) {
    switch (status) {
      case DailyAccomplishmentStatus.accomplishment:
        return Colors.green;

      case DailyAccomplishmentStatus.noAccomplishment:
        return Colors.amber;

      case DailyAccomplishmentStatus.leave:
        return Colors.blue;

      case DailyAccomplishmentStatus.holiday:
        return Colors.purple;

      case DailyAccomplishmentStatus.travelOrder:
        return Colors.orange;

      case DailyAccomplishmentStatus.officialTraining:
        return Colors.teal;
    }
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 18,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(
          'Accomplishment',
          Colors.green,
        ),
        _legendItem(
          'No Accomplishment',
          Colors.amber,
        ),
        _legendItem(
          'Leave',
          Colors.blue,
        ),
        _legendItem(
          'Holiday',
          Colors.purple,
        ),
        _legendItem(
          'Travel Order',
          Colors.orange,
        ),
        _legendItem(
          'Official Training',
          Colors.teal,
        ),
      ],
    );
  }

  Widget _legendItem(
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  bool _isSameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}