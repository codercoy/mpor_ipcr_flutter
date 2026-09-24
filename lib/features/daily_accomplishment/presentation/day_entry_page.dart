import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/daily_accomplishment_repository.dart';
import '../domain/daily_accomplishment_record.dart';

class DayEntryPage extends StatefulWidget {
  final DateTime date;
  final DailyAccomplishmentRecord? record;
  final bool readOnly;

  const DayEntryPage({
    super.key,
    required this.date,
    this.record,
    this.readOnly = false,
  });

  @override
  State<DayEntryPage> createState() => _DayEntryPageState();
}

class _DayEntryPageState extends State<DayEntryPage> {
  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------

  final List<_TaskEntry> _tasks = [
    _TaskEntry('Served Clients / Taxpayers'),
    _TaskEntry('Install / Validate PIN'),
    _TaskEntry('Checked PIN'),
    _TaskEntry('Update Property Index Maps'),
    _TaskEntry('Update Tax Map Control Rolls'),
    _TaskEntry('Update Municipal Digital Base Maps'),
    _TaskEntry('Plot Technical Description'),
    _TaskEntry('Prepared Daily Time Record'),
    _TaskEntry('Submitted MPOR'),
    _TaskEntry('Submitted IPCR'),
    _TaskEntry('Attended Meetings / Seminars / Workshops'),
    _TaskEntry('Intervening Tasks'),
  ];

  // ---------------------------------------------------------------------------
  // Attendance
  // ---------------------------------------------------------------------------

  bool _notRegularDuty = false;
  String? _dutyStatusReason;

  TimeOfDay? _timeIn;
  TimeOfDay? _timeOut;

  int _tardinessMinutes = 0;
  int _undertimeMinutes = 0;

  // Temporary official schedule for testing.
  // This will become configurable later.
  static const TimeOfDay _officialStartTime = TimeOfDay(
    hour: 8,
    minute: 0,
  );

  static const TimeOfDay _officialEndTime = TimeOfDay(
    hour: 17,
    minute: 0,
  );

  bool get _isReadOnly => widget.readOnly;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadExistingRecord();
  }

  void _loadExistingRecord() {
    final record = widget.record;

    if (record == null) {
      _initializeTaskControllers();
      return;
    }

    for (int i = 0; i < _tasks.length; i++) {
      final quantity = _taskQuantity(record, i);

      _tasks[i].quantity = quantity;
      _tasks[i].controller.text = '$quantity';
    }

    _notRegularDuty = record.notRegularDuty;
    _dutyStatusReason = record.dutyStatusReason;

    if (record.timeIn != null) {
      _timeIn = TimeOfDay(
        hour: record.timeIn!.hour,
        minute: record.timeIn!.minute,
      );
    }

    if (record.timeOut != null) {
      _timeOut = TimeOfDay(
        hour: record.timeOut!.hour,
        minute: record.timeOut!.minute,
      );
    }

    _tardinessMinutes = record.tardinessMinutes;
    _undertimeMinutes = record.undertimeMinutes;
  }

  void _initializeTaskControllers() {
    for (final task in _tasks) {
      task.controller.text = '0';
    }
  }

  @override
  void dispose() {
    for (final task in _tasks) {
      task.controller.dispose();
    }

    super.dispose();
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          _isReadOnly
              ? 'Daily Accomplishment — View'
              : widget.record == null
                  ? 'Daily Accomplishment Entry'
                  : 'Daily Accomplishment — Edit',
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTasksSection(),
                    const SizedBox(height: 24),
                    _buildAttendanceSection(),
                    const SizedBox(height: 28),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Date Header
  // ---------------------------------------------------------------------------

  Widget _buildDateHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isReadOnly
              ? 'Daily Accomplishment — View'
              : widget.record == null
                  ? 'Daily Accomplishment Entry'
                  : 'Daily Accomplishment — Edit',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formattedDate(widget.date),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Accomplishments
  // ---------------------------------------------------------------------------

  Widget _buildTasksSection() {
    return _buildCard(
      title: 'Accomplishments',
      child: Column(
        children: [
          for (int i = 0; i < _tasks.length; i++) ...[
            _buildTaskRow(i),
            if (i < _tasks.length - 1)
              const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskRow(int index) {
    final task = _tasks[index];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.name,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),

          // Minus
          _buildCounterButton(
            icon: Icons.remove,
            onPressed: _isReadOnly || task.quantity <= 0
                ? null
                : () {
                    setState(() {
                      task.quantity--;
                      task.controller.text =
                          '${task.quantity}';
                    });
                  },
          ),

          // Direct numeric entry
          SizedBox(
            width: 80,
            height: 40,
            child: _isReadOnly
                ? Center(
                    child: Text(
                      '${task.quantity}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : TextField(
                    controller: task.controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(
                          color: Colors.indigo,
                          width: 2,
                        ),
                      ),
                    ),
                    onTap: () {
                      final text =
                          task.controller.text;

                      task.controller.selection =
                          TextSelection(
                        baseOffset: 0,
                        extentOffset: text.length,
                      );
                    },
                    onChanged: (value) {
                      final parsed =
                          int.tryParse(value);

                      setState(() {
                        task.quantity =
                            parsed ?? 0;
                      });
                    },
                  ),
          ),

          // Plus
          _buildCounterButton(
            icon: Icons.add,
            onPressed: _isReadOnly
                ? null
                : () {
                    setState(() {
                      task.quantity++;
                      task.controller.text =
                          '${task.quantity}';
                      task.controller.selection =
                          TextSelection.collapsed(
                        offset:
                            task.controller.text.length,
                      );
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip:
            icon == Icons.add ? 'Add' : 'Subtract',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Attendance
  // ---------------------------------------------------------------------------

  Widget _buildAttendanceSection() {
    return _buildCard(
      title: 'Attendance',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDutyStatusDropdown(),

            if (!_notRegularDuty) ...[
              const Divider(height: 24),

              _buildTimeRow(
                label: 'Time In',
                value: _timeIn,
                onTap: _isReadOnly
                    ? () {}
                    : () => _selectTime(
                          isTimeIn: true,
                        ),
              ),

              const Divider(height: 24),

              _buildTimeRow(
                label: 'Time Out',
                value: _timeOut,
                onTap: _isReadOnly
                    ? () {}
                    : () => _selectTime(
                          isTimeIn: false,
                        ),
              ),

              const Divider(height: 24),

              _buildCalculatedRow(
                label: 'Tardiness',
                value: _tardinessMinutes,
              ),

              const Divider(height: 24),

              _buildCalculatedRow(
                label: 'Undertime',
                value: _undertimeMinutes,
              ),
            ],

            if (_notRegularDuty) ...[
              const Divider(height: 24),
              _buildReasonDropdown(),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Duty Status
  // ---------------------------------------------------------------------------

  Widget _buildDutyStatusDropdown() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Absent / Not on Regular Duty?',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        DropdownButton<bool>(
          value: _notRegularDuty,
          items: const [
            DropdownMenuItem(
              value: false,
              child: Text('No'),
            ),
            DropdownMenuItem(
              value: true,
              child: Text('Yes'),
            ),
          ],
          onChanged: _isReadOnly
              ? null
              : (value) {
                  if (value == null) return;

                  setState(() {
                    _notRegularDuty = value;

                    if (!_notRegularDuty) {
                      _dutyStatusReason = null;
                    } else {
                      _timeIn = null;
                      _timeOut = null;
                      _tardinessMinutes = 0;
                      _undertimeMinutes = 0;
                    }
                  });
                },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Duty Status Reason
  // ---------------------------------------------------------------------------

  Widget _buildReasonDropdown() {
    const reasons = [
      'Leave',
      'Holiday / Non-Working Day',
      'Travel Order',
      'Official Training / Seminar / Workshop',
    ];

    return Row(
      children: [
        const Expanded(
          child: Text(
            'Reason',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        DropdownButton<String>(
          value: _dutyStatusReason,
          hint: const Text('Select'),
          items: reasons.map((reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          onChanged: _isReadOnly
              ? null
              : (value) {
                  setState(() {
                    _dutyStatusReason = value;
                  });
                },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Time Input
  // ---------------------------------------------------------------------------

  Widget _buildTimeRow({
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _isReadOnly ? null : onTap,
          icon: const Icon(Icons.access_time),
          label: Text(
            value == null
                ? 'Select time'
                : value.format(context),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Calculated Attendance Values
  // ---------------------------------------------------------------------------

  Widget _buildCalculatedRow({
    required String label,
    required int value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        Text(
          '$value minutes',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Time Picker
  // ---------------------------------------------------------------------------

  Future<void> _selectTime({
    required bool isTimeIn,
  }) async {
    if (_isReadOnly) {
      return;
    }

    final initialTime = isTimeIn
        ? (_timeIn ?? _officialStartTime)
        : (_timeOut ?? _officialEndTime);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isTimeIn) {
        _timeIn = picked;
      } else {
        _timeOut = picked;
      }

      _calculateAttendanceMinutes();
    });
  }

  // ---------------------------------------------------------------------------
  // Automatic Tardiness / Undertime Calculation
  // ---------------------------------------------------------------------------

  void _calculateAttendanceMinutes() {
    if (_notRegularDuty) {
      _tardinessMinutes = 0;
      _undertimeMinutes = 0;
      return;
    }

    // Tardiness
    if (_timeIn != null) {
      final actualIn =
          _timeIn!.hour * 60 + _timeIn!.minute;

      final officialStart =
          _officialStartTime.hour * 60 +
              _officialStartTime.minute;

      _tardinessMinutes =
          actualIn > officialStart
              ? actualIn - officialStart
              : 0;
    } else {
      _tardinessMinutes = 0;
    }

    // Undertime
    if (_timeOut != null) {
      final actualOut =
          _timeOut!.hour * 60 + _timeOut!.minute;

      final officialEnd =
          _officialEndTime.hour * 60 +
              _officialEndTime.minute;

      _undertimeMinutes =
          actualOut < officialEnd
              ? officialEnd - actualOut
              : 0;
    } else {
      _undertimeMinutes = 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Card
  // ---------------------------------------------------------------------------

  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              14,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action Buttons
  // ---------------------------------------------------------------------------

  Widget _buildActionButtons() {
    if (_isReadOnly) {
      return Row(
        mainAxisAlignment:
            MainAxisAlignment.end,
        children: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _saveEntry,
          icon: const Icon(
            Icons.save_outlined,
          ),
          label: const Text('Save'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _saveEntry() async {
    // Make sure the latest text in every field
    // is reflected in the quantity values.
    for (final task in _tasks) {
      final parsed =
          int.tryParse(task.controller.text);

      task.quantity = parsed ?? 0;

      if (task.quantity < 0) {
        task.quantity = 0;
      }
    }

    final record = DailyAccomplishmentRecord(
      date: widget.date,

      // Accomplishment quantities
      servedClients: _tasks[0].quantity,
      installValidatePin: _tasks[1].quantity,
      checkedPin: _tasks[2].quantity,
      updatePropertyIndexMaps:
          _tasks[3].quantity,
      updateTaxMapControlRolls:
          _tasks[4].quantity,
      updateMunicipalDigitalBaseMaps:
          _tasks[5].quantity,
      plotTechnicalDescription:
          _tasks[6].quantity,
      preparedDailyTimeRecord:
          _tasks[7].quantity,
      submittedMpor: _tasks[8].quantity,
      submittedIpcr: _tasks[9].quantity,
      attendedMeetings: _tasks[10].quantity,
      interveningTasks: _tasks[11].quantity,

      // Duty status
      notRegularDuty: _notRegularDuty,
      dutyStatusReason: _dutyStatusReason,

      // Attendance
      timeIn: _timeOfDayToDateTime(_timeIn),
      timeOut: _timeOfDayToDateTime(_timeOut),
      tardinessMinutes: _tardinessMinutes,
      undertimeMinutes: _undertimeMinutes,
    );

    await dailyAccomplishmentRepository.save(
      record,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Daily accomplishment saved.',
        ),
      ),
    );

    Navigator.of(context).pop(true);
  }

  DateTime? _timeOfDayToDateTime(
    TimeOfDay? time,
  ) {
    if (time == null) {
      return null;
    }

    return DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      time.hour,
      time.minute,
    );
  }

  // ---------------------------------------------------------------------------
  // Date Formatting
  // ---------------------------------------------------------------------------

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
}

// -----------------------------------------------------------------------------
// Task Entry Model
// -----------------------------------------------------------------------------

class _TaskEntry {
  final String name;
  final TextEditingController controller =
      TextEditingController();

  int quantity = 0;

  _TaskEntry(this.name);
}