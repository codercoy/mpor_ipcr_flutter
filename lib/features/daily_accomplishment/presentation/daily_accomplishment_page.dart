import 'package:flutter/material.dart';

import '../data/daily_accomplishment_repository.dart';
import '../domain/daily_accomplishment_record.dart';


import 'calendar_widget.dart';
import 'day_entry_page.dart';

class DailyAccomplishmentPage extends StatefulWidget {
  const DailyAccomplishmentPage({super.key});

  @override
  State<DailyAccomplishmentPage> createState() =>
      _DailyAccomplishmentPageState();
}

class _DailyAccomplishmentPageState
    extends State<DailyAccomplishmentPage> {
  DateTime _displayedMonth = DateTime(2026, 9);

  Map<DateTime, DailyAccomplishmentStatus> _statusByDate = {};

  @override
  void initState() {
    super.initState();
    _loadMonthRecords();
  }

  Future<void> _loadMonthRecords() async {
    final records =
        await dailyAccomplishmentRepository.getMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );

    if (!mounted) return;

    setState(() {
      _statusByDate = {
        for (final record in records)
          DateTime(
            record.date.year,
            record.date.month,
            record.date.day,
          ): record.status,
      };
    });
  }

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
              statusByDate: _statusByDate,
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

    _loadMonthRecords();
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });

    _loadMonthRecords();
  }

  Future<void> _handleDateSelected(
    DateTime date,
  ) async {
    final bool isWeekend =
        date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;

    if (isWeekend) {
      await _showWeekendWorkDialog(date);
      return;
    }

    await _openDayEntry(date);
  }

  Future<void> _showWeekendWorkDialog(
    DateTime date,
  ) async {
    final bool? isWorking =
        await showDialog<bool>(
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

    await _openDayEntry(date);
  }

  Future<void> _openDayEntry(
    DateTime date,
  ) async {
    final existingRecord =
        await dailyAccomplishmentRepository.get(date);

    if (!mounted) return;

    if (existingRecord == null) {
      final bool? saved =
          await showDialog<bool>(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding:
                const EdgeInsets.all(24),
            child: SizedBox(
              width: 900,
              height: 700,
              child: DayEntryPage(
                date: date,
                record: null,
                readOnly: false,
              ),
            ),
          );
        },
      );

      if (!mounted || saved != true) {
        return;
      }

      await _loadMonthRecords();
      return;
    }

    final bool? edit =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Daily Accomplishment Already Encoded',
          ),
          content: const Text(
            'This Daily Accomplishment has already been encoded.\n\n'
            'Do you want to edit this entry?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (edit != true) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding:
                const EdgeInsets.all(24),
            child: SizedBox(
              width: 900,
              height: 700,
              child: DayEntryPage(
                date: date,
                record: existingRecord,
                readOnly: true,
              ),
            ),
          );
        },
      );

      return;
    }

    final bool? saved =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.all(24),
          child: SizedBox(
            width: 900,
            height: 700,
            child: DayEntryPage(
              date: date,
              record: existingRecord,
              readOnly: false,
            ),
          ),
        );
      },
    );

    if (!mounted || saved != true) {
      return;
    }

    await _loadMonthRecords();
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

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
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