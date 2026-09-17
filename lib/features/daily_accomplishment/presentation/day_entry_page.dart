import 'package:flutter/material.dart';

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
  State<DayEntryPage> createState() =>
      _DayEntryPageState();
}

class _DayEntryPageState extends State<DayEntryPage> {
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
    _TaskEntry(
      'Attended Meetings / Seminars / Workshops',
    ),
    _TaskEntry('Intervening Tasks'),
  ];

  DailyAccomplishmentStatus _status =
      DailyAccomplishmentStatus.accomplishment;

  LeaveType? _leaveType;

  final TextEditingController _leaveOtherController =
      TextEditingController();

  TimeOfDay? _timeIn;
  TimeOfDay? _timeOut;

  int _tardinessMinutes = 0;
  int _undertimeMinutes = 0;

  static const TimeOfDay _officialStartTime =
      TimeOfDay(
    hour: 8,
    minute: 0,
  );

  static const TimeOfDay _officialEndTime =
      TimeOfDay(
    hour: 17,
    minute: 0,
  );

  bool get _isReadOnly => widget.readOnly;

  bool get _isOnDuty =>
      _status ==
          DailyAccomplishmentStatus.accomplishment ||
      _status ==
          DailyAccomplishmentStatus.noAccomplishment;

  bool get _isLeave =>
      _status == DailyAccomplishmentStatus.leave;

  @override
  void initState() {
    super.initState();

    _loadExistingRecord();
  }

  @override
  void dispose() {
    _leaveOtherController.dispose();

    super.dispose();
  }

  void _loadExistingRecord() {
    final record = widget.record;

    if (record == null) {
      return;
    }

    for (int i = 0; i < _tasks.length; i++) {
      _tasks[i].quantity =
          _taskQuantity(record, i);
    }

    _status = record.status;

    _leaveType = record.leaveType;

    _leaveOtherController.text =
        record.leaveOtherReason ?? '';

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

    _tardinessMinutes =
        record.tardinessMinutes;

    _undertimeMinutes =
        record.undertimeMinutes;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildDateHeader(),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildStatusSection(),

                    const SizedBox(height: 24),

                    if (_status ==
                        DailyAccomplishmentStatus
                            .accomplishment)
                      _buildTasksSection(),

                    if (_status ==
                        DailyAccomplishmentStatus
                            .accomplishment)
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

  Widget _buildDateHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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

  Widget _buildStatusSection() {
    return _buildCard(
      title: 'Daily Status',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                DropdownButton<
                    DailyAccomplishmentStatus>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(
                      value:
                          DailyAccomplishmentStatus
                              .accomplishment,
                      child: Text(
                        'Accomplishment',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          DailyAccomplishmentStatus
                              .noAccomplishment,
                      child: Text(
                        'On Duty – No Accomplishment',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          DailyAccomplishmentStatus
                              .leave,
                      child: Text('Leave'),
                    ),
                    DropdownMenuItem(
                      value:
                          DailyAccomplishmentStatus
                              .holiday,
                      child: Text(
                        'Holiday / Non-Working Day',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          DailyAccomplishmentStatus
                              .travelOrder,
                      child: Text('Travel Order'),
                    ),
                    DropdownMenuItem(
                      value:
                          DailyAccomplishmentStatus
                              .officialTraining,
                      child: Text(
                        'Official Training / Seminar / Workshop',
                      ),
                    ),
                  ],
                  onChanged: _isReadOnly
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          _changeStatus(value);
                        },
                ),
              ],
            ),

            if (_isLeave) ...[
              const Divider(height: 24),
              _buildLeaveTypeRow(),
            ],

            if (_isLeave &&
                _leaveType == LeaveType.other) ...[
              const Divider(height: 24),
              _buildLeaveOtherReason(),
            ],
          ],
        ),
      ),
    );
  }

  void _changeStatus(
    DailyAccomplishmentStatus status,
  ) {
    setState(() {
      _status = status;

      if (status !=
          DailyAccomplishmentStatus.leave) {
        _leaveType = null;
        _leaveOtherController.clear();
      }

      if (status !=
          DailyAccomplishmentStatus
              .accomplishment) {
        _clearTaskQuantities();
      }

      if (!_isOnDuty) {
        _timeIn = null;
        _timeOut = null;
        _tardinessMinutes = 0;
        _undertimeMinutes = 0;
      }

      if (_isOnDuty) {
        _calculateAttendanceMinutes();
      }
    });
  }

  void _clearTaskQuantities() {
    for (final task in _tasks) {
      task.quantity = 0;
    }
  }

  Widget _buildLeaveTypeRow() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Leave Type',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        DropdownButton<LeaveType>(
          value: _leaveType,
          hint: const Text('Select'),
          items: const [
            DropdownMenuItem(
              value: LeaveType.sickLeave,
              child: Text('Sick Leave'),
            ),
            DropdownMenuItem(
              value: LeaveType.vacationLeave,
              child: Text('Vacation Leave'),
            ),
            DropdownMenuItem(
              value:
                  LeaveType.specialPrivilegeLeave,
              child: Text(
                'Special Privilege Leave',
              ),
            ),
            DropdownMenuItem(
              value: LeaveType.mandatoryLeave,
              child: Text('Mandatory Leave'),
            ),
            DropdownMenuItem(
              value: LeaveType.wellnessLeave,
              child: Text('Wellness Leave'),
            ),
            DropdownMenuItem(
              value: LeaveType.other,
              child: Text('Others'),
            ),
          ],
          onChanged: _isReadOnly
              ? null
              : (value) {
                  setState(() {
                    _leaveType = value;

                    if (value != LeaveType.other) {
                      _leaveOtherController.clear();
                    }
                  });
                },
        ),
      ],
    );
  }

  Widget _buildLeaveOtherReason() {
    return TextField(
      controller: _leaveOtherController,
      enabled: !_isReadOnly,
      decoration: const InputDecoration(
        labelText: 'Other Leave',
        hintText: 'Specify leave type',
        border: OutlineInputBorder(),
      ),
      maxLength: 100,
    );
  }

  Widget _buildTasksSection() {
    return _buildCard(
      title: 'Accomplishments',
      child: Column(
        children: [
          for (int i = 0;
              i < _tasks.length;
              i++) ...[
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

          _buildCounterButton(
            icon: Icons.remove,
            onPressed:
                _isReadOnly ||
                        task.quantity <= 0
                    ? null
                    : () {
                        setState(() {
                          task.quantity--;
                        });
                      },
          ),

          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                '${task.quantity}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          _buildCounterButton(
            icon: Icons.add,
            onPressed: _isReadOnly
                ? null
                : () {
                    setState(() {
                      task.quantity++;
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
        tooltip: icon == Icons.add
            ? 'Add'
            : 'Subtract',
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return _buildCard(
      title: 'Attendance',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isOnDuty) ...[
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
            ] else ...[
              Text(
                _statusDescription(),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusDescription() {
    switch (_status) {
      case DailyAccomplishmentStatus.leave:
        return 'No attendance time is required for leave.';

      case DailyAccomplishmentStatus.holiday:
        return 'Non-working day.';

      case DailyAccomplishmentStatus.travelOrder:
        return 'Official travel / duty outside the regular workplace.';

      case DailyAccomplishmentStatus.officialTraining:
        return 'Official training, seminar, or workshop.';

      case DailyAccomplishmentStatus.noAccomplishment:
        return 'You are on duty, but there is no accomplishment to record.';

      case DailyAccomplishmentStatus.accomplishment:
        return '';
    }
  }

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
          onPressed:
              _isReadOnly ? null : onTap,
          icon: const Icon(
            Icons.access_time,
          ),
          label: Text(
            value == null
                ? 'Select time'
                : value.format(context),
          ),
        ),
      ],
    );
  }

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

  void _calculateAttendanceMinutes() {
    if (!_isOnDuty) {
      _tardinessMinutes = 0;
      _undertimeMinutes = 0;
      return;
    }

    if (_timeIn != null) {
      final actualIn =
          _timeIn!.hour * 60 +
              _timeIn!.minute;

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

    if (_timeOut != null) {
      final actualOut =
          _timeOut!.hour * 60 +
              _timeOut!.minute;

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

  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
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

  Future<void> _saveEntry() async {
    if (_status ==
        DailyAccomplishmentStatus.leave) {
      if (_leaveType == null) {
        _showValidationMessage(
          'Please select a leave type.',
        );
        return;
      }

      if (_leaveType == LeaveType.other &&
          _leaveOtherController.text
              .trim()
              .isEmpty) {
        _showValidationMessage(
          'Please specify the other leave type.',
        );
        return;
      }
    }

    final bool notRegularDuty =
        !_isOnDuty;

    final String? dutyStatusReason =
        _legacyDutyStatusReason();

    final record =
        DailyAccomplishmentRecord(
      date: widget.date,

      status: _status,

      leaveType: _leaveType,

      leaveOtherReason:
          _leaveType == LeaveType.other
              ? _leaveOtherController.text.trim()
              : null,

      servedClients:
          _tasks[0].quantity,

      installValidatePin:
          _tasks[1].quantity,

      checkedPin:
          _tasks[2].quantity,

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

      submittedMpor:
          _tasks[8].quantity,

      submittedIpcr:
          _tasks[9].quantity,

      attendedMeetings:
          _tasks[10].quantity,

      interveningTasks:
          _tasks[11].quantity,

      notRegularDuty:
          notRegularDuty,

      dutyStatusReason:
          dutyStatusReason,

      timeIn:
          _timeOfDayToDateTime(_timeIn),

      timeOut:
          _timeOfDayToDateTime(_timeOut),

      tardinessMinutes:
          _tardinessMinutes,

      undertimeMinutes:
          _undertimeMinutes,
    );

    await dailyAccomplishmentRepository
        .save(record);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Daily accomplishment saved.',
        ),
      ),
    );

    Navigator.of(context).pop(true);
  }

  String? _legacyDutyStatusReason() {
    switch (_status) {
      case DailyAccomplishmentStatus
          .accomplishment:
        return null;

      case DailyAccomplishmentStatus
          .noAccomplishment:
        return null;

      case DailyAccomplishmentStatus.leave:
        return 'Leave';

      case DailyAccomplishmentStatus.holiday:
        return 'Holiday / Non-Working Day';

      case DailyAccomplishmentStatus.travelOrder:
        return 'Travel Order';

      case DailyAccomplishmentStatus
          .officialTraining:
        return 'Official Training / Seminar / Workshop';
    }
  }

  void _showValidationMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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

  String _formattedDate(
    DateTime date,
  ) {
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

class _TaskEntry {
  final String name;

  int quantity = 0;

  _TaskEntry(this.name);
}