import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime month;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarWidget({
    super.key,
    required this.month,
    required this.onDateSelected,
  });

  static const List<String> _weekdays = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;

    final int firstWeekday = DateTime(
      month.year,
      month.month,
      1,
    ).weekday;

    final int leadingEmptyDays = firstWeekday - 1;

    final List<Widget> cells = [];

    for (int i = 0; i < leadingEmptyDays; i++) {
      cells.add(_buildEmptyCell());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(
        month.year,
        month.month,
        day,
      );

      cells.add(
        _buildDayCell(
          context,
          date,
        ),
      );
    }

    while (cells.length % 7 != 0) {
      cells.add(_buildEmptyCell());
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          _buildWeekdayHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: GridView.builder(
                padding: const EdgeInsets.only(right: 8),
                itemCount: cells.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return cells[index];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _weekdays.map((weekday) {
        final bool isWeekend =
            weekday == 'SAT' || weekday == 'SUN';

        return Expanded(
          child: Center(
            child: Text(
              weekday,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isWeekend
                    ? Colors.grey.shade500
                    : Colors.grey.shade700,
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
  ) {
    final bool isWeekend =
        date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          onDateSelected(date);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isWeekend
                ? Colors.grey.shade100
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isWeekend
                  ? Colors.grey.shade300
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isWeekend
                        ? Colors.grey.shade500
                        : Colors.grey.shade800,
                  ),
                ),
              ),
              if (isWeekend)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Text(
                    'WEEKEND',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}