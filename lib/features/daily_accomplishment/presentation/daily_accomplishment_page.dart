import 'package:flutter/material.dart';

import 'calendar_widget.dart';

class DailyAccomplishmentPage extends StatefulWidget {
  const DailyAccomplishmentPage({super.key});

  @override
  State<DailyAccomplishmentPage> createState() =>
      _DailyAccomplishmentPageState();
}

class _DailyAccomplishmentPageState
    extends State<DailyAccomplishmentPage> {
  DateTime _displayedMonth = DateTime(2026, 9);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: CalendarWidget(
              month: _displayedMonth,
              onDateSelected: _handleDateSelected,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Accomplishment',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Record and review your daily accomplishments.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _buildMonthNavigation(),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: _goToPreviousMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        SizedBox(
          width: 150,
          child: Center(
            child: Text(
              _monthTitle(_displayedMonth),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: _goToNextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  void _handleDateSelected(DateTime date) {
    final bool isWeekend =
        date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;

    if (isWeekend) {
      _showWeekendWorkDialog(date);
      return;
    }

    _openDayEntry(date);
  }

  Future<void> _showWeekendWorkDialog(DateTime date) async {
    final bool? isWorking = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Weekend'),
          content: Text(
            'Are you working on ${_formattedDate(date)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes, I'm working"),
            ),
          ],
        );
      },
    );

    if (!mounted || isWorking != true) {
      return;
    }

    _openDayEntry(date);
  }

  void _openDayEntry(DateTime date) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Daily Accomplishment'),
          content: Text(
            'Selected date: ${_formattedDate(date)}',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formattedDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _monthTitle(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}