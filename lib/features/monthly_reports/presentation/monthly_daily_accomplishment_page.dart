import 'package:flutter/material.dart';

import '../../daily_accomplishment/data/daily_accomplishment_repository.dart';
import '../../daily_accomplishment/domain/daily_accomplishment_record.dart';

import '../data/monthly_report_layout_repository.dart';

class MonthlyDailyAccomplishmentPage extends StatefulWidget {
  const MonthlyDailyAccomplishmentPage({super.key});

  @override
  State<MonthlyDailyAccomplishmentPage> createState() =>
      _MonthlyDailyAccomplishmentPageState();
}

class _MonthlyDailyAccomplishmentPageState
    extends State<MonthlyDailyAccomplishmentPage> {

    final MonthlyReportLayoutRepository _layoutRepository =
      MonthlyReportLayoutRepository();
  DateTime _displayedMonth = DateTime(2026, 1);

  List<DailyAccomplishmentRecord> _records = [];
  bool _isLoading = true;

  // Initial Excel-like dimensions.
  static const double _defaultActivityWidth = 220;
  static const double _defaultDayWidth = 32;
  static const double _defaultWeekWidth = 40;
  static const double _defaultMonthWidth = 48;

  static const double _minColumnWidth = 24;
  static const double _minActivityWidth = 140;
  static const double _maxColumnWidth = 500;

  static const double _defaultRowHeight = 36;
  static const double _minRowHeight = 24;
  static const double _maxRowHeight = 100;

  double _activityWidth = _defaultActivityWidth;
  double _dayWidth = _defaultDayWidth;
  double _weekWidth = _defaultWeekWidth;
  double _monthWidth = _defaultMonthWidth;

  double _rowHeight = _defaultRowHeight;

  int? _selectedColumnIndex;
  int? _selectedRowIndex;

  bool _boldSelected = false;

@override
void initState() {
  super.initState();
  _loadRecords();
  _loadLayout();
}

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    final records = await dailyAccomplishmentRepository.getMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );

    if (!mounted) return;

    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  Future<void> _loadLayout() async {
    final layout = await _layoutRepository.getLayout();

    if (!mounted) return;

    setState(() {
      _activityWidth = layout.activityWidth;
      _dayWidth = layout.dayWidth;
      _weekWidth = layout.weekWidth;
      _monthWidth = layout.monthWidth;
      _rowHeight = layout.rowHeight;
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });

    _loadRecords();
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });

    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildFormattingToolbar(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildReport(),
            ),
          ],
        ),
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
                'Daily Accomplishment Record Sheet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Monthly summary of daily accomplishments.',
                style: TextStyle(
                  fontSize: 12,
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
          visualDensity: VisualDensity.compact,
          onPressed: _goToPreviousMonth,
          icon: const Icon(
            Icons.chevron_left,
            size: 22,
          ),
        ),
        SizedBox(
          width: 120,
          child: Center(
            child: Text(
              _monthTitle(_displayedMonth),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          visualDensity: VisualDensity.compact,
          onPressed: _goToNextMonth,
          icon: const Icon(
            Icons.chevron_right,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildFormattingToolbar() {
    final bool hasSelection =
        _selectedColumnIndex != null || _selectedRowIndex != null;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.table_chart_outlined,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            hasSelection
                ? _selectionDescription()
                : 'Select a column or row to format',
            style: TextStyle(
              fontSize: 11,
              color: hasSelection
                  ? Colors.black87
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          const VerticalDivider(
            width: 1,
            indent: 8,
            endIndent: 8,
          ),
          const SizedBox(width: 8),
          _toolbarButton(
            label: 'Column Width',
            icon: Icons.swap_horiz,
            onPressed:
                hasSelection ? _showColumnWidthDialog : null,
          ),
          const SizedBox(width: 4),
          _toolbarButton(
            label: 'Row Height',
            icon: Icons.height,
            onPressed:
                hasSelection ? _showRowHeightDialog : null,
          ),
          const SizedBox(width: 4),
          _toolbarButton(
            label: 'Bold',
            icon: Icons.format_bold,
            selected: _boldSelected,
            onPressed: hasSelection
                ? () {
                    setState(() {
                      _boldSelected = !_boldSelected;
                    });
                  }
                : null,
          ),
          const Spacer(),
          _toolbarButton(
            label: 'Reset Layout',
            icon: Icons.restart_alt,
            onPressed: _resetLayout,
          ),
        ],
      ),
    );
  }

  Widget _toolbarButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool selected = false,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE0E7FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: onPressed == null
                    ? Colors.grey.shade400
                    : Colors.grey.shade800,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: onPressed == null
                      ? Colors.grey.shade400
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectionDescription() {
    if (_selectedColumnIndex != null) {
      if (_selectedColumnIndex == 0) {
        return 'Activities column selected';
      }

      final weekGroups = _buildWeekGroups();
      int index = 1;

      for (final group in weekGroups) {
        for (final reportDay in group.days) {
          if (index == _selectedColumnIndex) {
            return 'Column ${reportDay.date.day} selected';
          }
          index++;
        }

        if (index == _selectedColumnIndex) {
          return '${group.label} selected';
        }

        index++;
      }

      return 'Total column selected';
    }

    if (_selectedRowIndex != null) {
      return 'Row ${_selectedRowIndex! + 1} selected';
    }

    return 'Select a column or row to format';
  }

  Future<void> _showColumnWidthDialog() async {
    if (_selectedColumnIndex == null) return;

    final controller = TextEditingController(
      text: _selectedColumnWidth().round().toString(),
    );

    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Column Width'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Width',
              suffixText: 'px',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              final parsed =
                  double.tryParse(controller.text);

              if (parsed != null) {
                Navigator.of(context).pop(parsed);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed =
                    double.tryParse(controller.text);

                if (parsed != null) {
                  Navigator.of(context).pop(parsed);
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (value == null) return;

    _setSelectedColumnWidth(
      value.clamp(
        _selectedColumnIndex == 0
            ? _minActivityWidth
            : _minColumnWidth,
        _maxColumnWidth,
      ),
    );
  }

  Future<void> _showRowHeightDialog() async {
    if (_selectedRowIndex == null) return;

    final controller = TextEditingController(
      text: _rowHeight.round().toString(),
    );

    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Row Height'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Height',
              suffixText: 'px',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              final parsed =
                  double.tryParse(controller.text);

              if (parsed != null) {
                Navigator.of(context).pop(parsed);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed =
                    double.tryParse(controller.text);

                if (parsed != null) {
                  Navigator.of(context).pop(parsed);
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (value == null) return;

    setState(() {
      _rowHeight = value.clamp(
        _minRowHeight,
        _maxRowHeight,
      );
    });
  }

  double _selectedColumnWidth() {
    final index = _selectedColumnIndex;

    if (index == null) {
      return _dayWidth;
    }

    if (index == 0) {
      return _activityWidth;
    }

    final weekGroups = _buildWeekGroups();
    int currentIndex = 1;

    for (final group in weekGroups) {
      for (final _ in group.days) {
        if (currentIndex == index) {
          return _dayWidth;
        }

        currentIndex++;
      }

      if (currentIndex == index) {
        return _weekWidth;
      }

      currentIndex++;
    }

    return _monthWidth;
  }

  void _setSelectedColumnWidth(double value) {
    if (_selectedColumnIndex == null) return;

    if (_selectedColumnIndex == 0) {
      setState(() {
        _activityWidth = value;
      });
      return;
    }

    final weekGroups = _buildWeekGroups();
    int currentIndex = 1;

    for (final group in weekGroups) {
      for (final _ in group.days) {
        if (currentIndex == _selectedColumnIndex) {
          setState(() {
            _dayWidth = value;
          });
          return;
        }

        currentIndex++;
      }

      if (currentIndex == _selectedColumnIndex) {
        setState(() {
          _weekWidth = value;
        });
        return;
      }

      currentIndex++;
    }

    setState(() {
      _monthWidth = value;
    });
  }

  Future<void> _saveCurrentLayout() async {
    await _layoutRepository.saveLayout(
      MonthlyReportLayout(
        activityWidth: _activityWidth,
        dayWidth: _dayWidth,
        weekWidth: _weekWidth,
        monthWidth: _monthWidth,
        rowHeight: _rowHeight,
      ),
    );
  }

void _resetLayout() {
  setState(() {
    _activityWidth = _defaultActivityWidth;
    _dayWidth = _defaultDayWidth;
    _weekWidth = _defaultWeekWidth;
    _monthWidth = _defaultMonthWidth;
    _rowHeight = _defaultRowHeight;
    _selectedColumnIndex = null;
    _selectedRowIndex = null;
    _boldSelected = false;
  });

  _saveCurrentLayout();
}

  Widget _buildReport() {
    final weekGroups = _buildWeekGroups();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
        ),
      ),
      child: Column(
        children: [
          _buildReportTitle(),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              notificationPredicate: (notification) =>
                  notification.metrics.axis ==
                  Axis.vertical,
              child: SingleChildScrollView(
                child: Scrollbar(
                  thumbVisibility: true,
                  notificationPredicate: (notification) =>
                      notification.metrics.axis ==
                      Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildTable(weekGroups),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        7,
        12,
        6,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'DIVISION: TAX MAPPING OPERATIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Monthly Supervisor Summary',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _monthTitle(_displayedMonth).toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(
    List<_WeekGroup> weekGroups,
  ) {
    final rows = <Widget>[];

    rows.add(
      _buildHeaderRow(weekGroups),
    );

    rows.add(
      _buildSectionHeader(
        'CORE FUNCTIONS',
        weekGroups,
      ),
    );

    for (int i = 0;
        i < _coreFunctions.length;
        i++) {
      rows.add(
        _buildActivityRow(
          number: i + 1,
          activity: _coreFunctions[i],
          activityIndex: i,
          rowIndex: i,
          weekGroups: weekGroups,
        ),
      );
    }

    rows.add(
      _buildSectionHeader(
        'SUPPORT FUNCTIONS',
        weekGroups,
      ),
    );

    for (int i = 0;
        i < _supportFunctions.length;
        i++) {
      rows.add(
        _buildActivityRow(
          number: i + 1,
          activity: _supportFunctions[i],
          activityIndex: i + 7,
          rowIndex:
              i + _coreFunctions.length,
          weekGroups: weekGroups,
        ),
      );
    }

    return Column(
      children: rows,
    );
  }

  Widget _buildHeaderRow(
    List<_WeekGroup> weekGroups,
  ) {
    final cells = <Widget>[
      _buildSelectableHeaderCell(
        text: 'ACTIVITIES',
        width: _activityWidth,
        columnIndex: 0,
        color: const Color(0xFFF3F4F6),
      ),
    ];

    int columnIndex = 1;

    for (final group in weekGroups) {
      for (final reportDay in group.days) {
        cells.add(
          _buildSelectableHeaderCell(
            text: '${reportDay.date.day}',
            width: _dayWidth,
            columnIndex: columnIndex,
            color: const Color(0xFFF3F4F6),
          ),
        );

        columnIndex++;
      }

      cells.add(
        _buildSelectableHeaderCell(
          text: group.label,
          width: _weekWidth,
          columnIndex: columnIndex,
          color: const Color(0xFFE5E7EB),
        ),
      );

      columnIndex++;
    }

    cells.add(
      _buildSelectableHeaderCell(
        text: 'TOTAL',
        width: _monthWidth,
        columnIndex: columnIndex,
        color: const Color(0xFFDDE3F5),
      ),
    );

    return Row(children: cells);
  }

  Widget _buildSelectableHeaderCell({
    required String text,
    required double width,
    required int columnIndex,
    required Color color,
  }) {
    final selected =
        _selectedColumnIndex == columnIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColumnIndex = columnIndex;
          _selectedRowIndex = null;
        });
      },
      child: Container(
        width: width,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFC7D2FE)
              : color,
          border: Border(
            left: const BorderSide(
              color: Color(0xFFD1D5DB),
            ),
            bottom: const BorderSide(
              color: Color(0xFFD1D5DB),
            ),
            right: selected
                ? const BorderSide(
                    color: Colors.indigo,
                    width: 2,
                  )
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    List<_WeekGroup> weekGroups,
  ) {
    final cells = <Widget>[
      Container(
        width: _activityWidth,
        height: 24,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
        ),
        color: const Color(0xFFE5E7EB),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    for (final group in weekGroups) {
      for (final _ in group.days) {
        cells.add(
          Container(
            width: _dayWidth,
            height: 24,
            color: const Color(0xFFE5E7EB),
          ),
        );
      }

      cells.add(
        Container(
          width: _weekWidth,
          height: 24,
          color: const Color(0xFFE5E7EB),
        ),
      );
    }

    cells.add(
      Container(
        width: _monthWidth,
        height: 24,
        color: const Color(0xFFDDE3F5),
      ),
    );

    return Row(children: cells);
  }

  Widget _buildActivityRow({
    required int number,
    required String activity,
    required int activityIndex,
    required int rowIndex,
    required List<_WeekGroup> weekGroups,
  }) {
    final rowSelected =
        _selectedRowIndex == rowIndex;

    final cells = <Widget>[
      GestureDetector(
        onTap: () {
          setState(() {
            _selectedRowIndex = rowIndex;
            _selectedColumnIndex = null;
          });
        },
        child: Container(
          width: _activityWidth,
          height: _rowHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: rowSelected
                ? const Color(0xFFE0E7FF)
                : Colors.white,
            border: Border(
              bottom: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
              right: rowSelected
                  ? const BorderSide(
                      color: Colors.indigo,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  activity,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: _boldSelected &&
                            rowSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    int columnIndex = 1;

    for (final group in weekGroups) {
      for (final reportDay in group.days) {
        cells.add(
          _buildDayCell(
            reportDay,
            activityIndex,
            columnIndex,
            rowIndex,
          ),
        );

        columnIndex++;
      }

      cells.add(
        _numberCell(
          _weekTotal(
            group,
            activityIndex,
          ),
          width: _weekWidth,
          bold: true,
          showZero: true,
          selected:
              _selectedColumnIndex ==
                  columnIndex,
        ),
      );

      columnIndex++;
    }

    cells.add(
      _numberCell(
        _monthTotal(activityIndex),
        width: _monthWidth,
        bold: true,
        highlighted: true,
        showZero: true,
        selected:
            _selectedColumnIndex ==
                columnIndex,
      ),
    );

    return Row(children: cells);
  }

  Widget _buildDayCell(
    _ReportDay reportDay,
    int activityIndex,
    int columnIndex,
    int rowIndex,
  ) {
    final record = reportDay.record;

    if (record == null) {
      return _numberCell(
        null,
        width: _dayWidth,
        selected:
            _selectedColumnIndex ==
                columnIndex,
      );
    }

    if (record.status !=
        DailyAccomplishmentStatus.accomplishment) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedColumnIndex =
                columnIndex;
            _selectedRowIndex = rowIndex;
          });
        },
        child: Container(
          width: _dayWidth,
          height: _rowHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _selectedColumnIndex ==
                    columnIndex
                ? const Color(0xFFE0E7FF)
                : Colors.white,
            border: const Border(
              left: BorderSide(
                color: Color(0xFFD1D5DB),
              ),
              bottom: BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
          ),
          child: _statusLabel(record),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColumnIndex =
              columnIndex;
          _selectedRowIndex = rowIndex;
        });
      },
      child: _numberCell(
        _taskQuantity(
          record,
          activityIndex,
        ),
        width: _dayWidth,
        selected:
            _selectedColumnIndex ==
                columnIndex,
      ),
    );
  }

  Widget _numberCell(
    int? value, {
    required double width,
    bool bold = false,
    bool highlighted = false,
    bool showZero = false,
    bool selected = false,
  }) {
    final String text;

    if (value == null) {
      text = '';
    } else if (value == 0 && !showZero) {
      text = '';
    } else {
      text = '$value';
    }

    return Container(
      width: width,
      height: _rowHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFE0E7FF)
            : highlighted
                ? const Color(0xFFEFF2FA)
                : Colors.white,
        border: Border(
          left: const BorderSide(
            color: Color(0xFFD1D5DB),
          ),
          bottom: const BorderSide(
            color: Color(0xFFD1D5DB),
          ),
          right: selected
              ? const BorderSide(
                  color: Colors.indigo,
                  width: 2,
                )
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: bold
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _statusLabel(
    DailyAccomplishmentRecord record,
  ) {
    final String label;
    final Color color;

    switch (record.status) {
      case DailyAccomplishmentStatus.noAccomplishment:
        label = 'N/A';
        color = Colors.amber.shade700;
        break;

      case DailyAccomplishmentStatus.leave:
        label = 'LV';
        color = Colors.blue.shade600;
        break;

      case DailyAccomplishmentStatus.holiday:
        label = 'HOL';
        color = Colors.purple.shade600;
        break;

      case DailyAccomplishmentStatus.travelOrder:
        label = 'TO';
        color = Colors.orange.shade700;
        break;

      case DailyAccomplishmentStatus.officialTraining:
        label = 'TRN';
        color = Colors.teal.shade600;
        break;

      case DailyAccomplishmentStatus.accomplishment:
        label = '';
        color = Colors.green.shade600;
        break;
    }

    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 7,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  List<_WeekGroup> _buildWeekGroups() {
    final groups = <_WeekGroup>[];

    final firstDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final lastDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );

    // Start from the Sunday of the calendar week
    // containing the first day of the month.
    DateTime currentDate = firstDay.subtract(
      Duration(days: firstDay.weekday % 7),
    );

    while (!currentDate.isAfter(lastDay)) {
      final weekStart = currentDate;

      final weekEnd = weekStart.add(
        const Duration(days: 6),
      );

      final weekDays = <_ReportDay>[];

      // Display Monday-Friday only.
      //
      // Sunday and Saturday define the reporting
      // week but are not displayed as accomplishment
      // columns.
      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(
          Duration(days: day),
        );

        // Only include dates belonging to the
        // displayed month.
        if (date.year != _displayedMonth.year ||
            date.month != _displayedMonth.month) {
          continue;
        }

        // Saturday and Sunday are not accomplishment
        // columns.
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          continue;
        }

        weekDays.add(
          _ReportDay(
            date: date,
            record: _findRecord(date),
          ),
        );
      }

      // Ignore calendar weeks that contain no
      // working day from the selected month.
      if (weekDays.isNotEmpty) {
        final calendarWeekNumber = groups.length + 1;

        if (calendarWeekNumber <= 3) {
          // W1, W2 and W3 remain separate.
          groups.add(
            _WeekGroup(
              label: 'W$calendarWeekNumber',
              startDay: weekDays.first.date.day,
              endDay: weekDays.last.date.day,
            )..days.addAll(weekDays),
          );
        } else {
          // IMPORTANT:
          // All remaining working days belong to W4.
          //
          // This prevents the report from ever creating
          // W5. If the month spans five calendar weeks,
          // the fifth week's working days are merged
          // into W4.
          if (groups.length < 4) {
            groups.add(
              _WeekGroup(
                label: 'W4',
                startDay: weekDays.first.date.day,
                endDay: weekDays.last.date.day,
              )..days.addAll(weekDays),
            );
          } else {
            final fourthWeek = groups[3];

            fourthWeek.days.addAll(weekDays);
            fourthWeek.endDay = weekDays.last.date.day;
          }
        }
      }

      // Move to the next Sunday.
      currentDate = weekEnd.add(
        const Duration(days: 1),
      );
    }

    return groups;
  }

  int _weekTotal(
    _WeekGroup group,
    int activityIndex,
  ) {
    int total = 0;

    for (final reportDay in group.days) {
      final record = reportDay.record;

      if (record == null ||
          record.status !=
              DailyAccomplishmentStatus.accomplishment) {
        continue;
      }

      total += _taskQuantity(
        record,
        activityIndex,
      );
    }

    return total;
  }

  int _monthTotal(int activityIndex) {
    int total = 0;

    for (final record in _records) {
      if (record.status !=
          DailyAccomplishmentStatus.accomplishment) {
        continue;
      }

      total += _taskQuantity(
        record,
        activityIndex,
      );
    }

    return total;
  }

  int _taskQuantity(
    DailyAccomplishmentRecord record,
    int index,
  ) {
    switch (index) {
      case 0:
        return record.servedClients;
      case 1:
        return record.installValidatePin;
      case 2:
        return record.checkedPin;
      case 3:
        return record.updatePropertyIndexMaps;
      case 4:
        return record.updateTaxMapControlRolls;
      case 5:
        return record.updateMunicipalDigitalBaseMaps;
      case 6:
        return record.plotTechnicalDescription;
      case 7:
        return record.preparedDailyTimeRecord;
      case 8:
        return record.submittedMpor;
      case 9:
        return record.submittedIpcr;
      case 10:
        return record.attendedMeetings;
      case 11:
        return record.interveningTasks;
      default:
        return 0;
    }
  }

  DailyAccomplishmentRecord? _findRecord(
    DateTime date,
  ) {
    for (final record in _records) {
      if (record.date.year == date.year &&
          record.date.month == date.month &&
          record.date.day == date.day) {
        return record;
      }
    }

    return null;
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

  static const List<String> _coreFunctions = [
    'Served Clients / Taxpayers',
    'Install / Validate Property Index Number (PIN) to each EAAS',
    'Checked installed / validated PIN on each EAAS',
    'Update Property Index Maps (PIMs) per LRPU',
    'Updated Tax Map Control Rolls (TMCRs) per RPU',
    'Update Municipal Digital Base Maps per parcel',
    'Plot Technical Description of Lot Boundaries on the Digital Base Map',
  ];

  static const List<String> _supportFunctions = [
    'Prepared Daily Time Record (DTR)',
    'Submitted Monthly Performance Output Report (MPOR)',
    'Submitted Individual Performance Commitment and Review (IPCR)',
    'Attended meetings, seminars and workshop',
    'Performed Intervening Tasks',
  ];
}

class _ReportDay {
  final DateTime date;
  final DailyAccomplishmentRecord? record;

  const _ReportDay({
    required this.date,
    required this.record,
  });
}

class _WeekGroup {
  final String label;
  final int startDay;
  int endDay;
  final List<_ReportDay> days = [];

  _WeekGroup({
    required this.label,
    required this.startDay,
    required this.endDay,
  });
}