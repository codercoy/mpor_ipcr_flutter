class DailyAccomplishmentRecord {
  final DateTime date;

  // Daily accomplishment quantities
  final int servedClients;
  final int installValidatePin;
  final int checkedPin;
  final int updatePropertyIndexMaps;
  final int updateTaxMapControlRolls;
  final int updateMunicipalDigitalBaseMaps;
  final int plotTechnicalDescription;
  final int preparedDailyTimeRecord;
  final int submittedMpor;
  final int submittedIpcr;
  final int attendedMeetings;
  final int interveningTasks;

  // Attendance / duty status
  final bool notRegularDuty;
  final String? dutyStatusReason;

  // Actual attendance times
  final DateTime? timeIn;
  final DateTime? timeOut;

  // Calculated attendance values
  final int tardinessMinutes;
  final int undertimeMinutes;

  const DailyAccomplishmentRecord({
    required this.date,
    this.servedClients = 0,
    this.installValidatePin = 0,
    this.checkedPin = 0,
    this.updatePropertyIndexMaps = 0,
    this.updateTaxMapControlRolls = 0,
    this.updateMunicipalDigitalBaseMaps = 0,
    this.plotTechnicalDescription = 0,
    this.preparedDailyTimeRecord = 0,
    this.submittedMpor = 0,
    this.submittedIpcr = 0,
    this.attendedMeetings = 0,
    this.interveningTasks = 0,
    this.notRegularDuty = false,
    this.dutyStatusReason,
    this.timeIn,
    this.timeOut,
    this.tardinessMinutes = 0,
    this.undertimeMinutes = 0,
  });

  DailyAccomplishmentRecord copyWith({
    DateTime? date,
    int? servedClients,
    int? installValidatePin,
    int? checkedPin,
    int? updatePropertyIndexMaps,
    int? updateTaxMapControlRolls,
    int? updateMunicipalDigitalBaseMaps,
    int? plotTechnicalDescription,
    int? preparedDailyTimeRecord,
    int? submittedMpor,
    int? submittedIpcr,
    int? attendedMeetings,
    int? interveningTasks,
    bool? notRegularDuty,
    String? dutyStatusReason,
    DateTime? timeIn,
    DateTime? timeOut,
    int? tardinessMinutes,
    int? undertimeMinutes,
  }) {
    return DailyAccomplishmentRecord(
      date: date ?? this.date,
      servedClients: servedClients ?? this.servedClients,
      installValidatePin:
          installValidatePin ?? this.installValidatePin,
      checkedPin: checkedPin ?? this.checkedPin,
      updatePropertyIndexMaps:
          updatePropertyIndexMaps ?? this.updatePropertyIndexMaps,
      updateTaxMapControlRolls:
          updateTaxMapControlRolls ?? this.updateTaxMapControlRolls,
      updateMunicipalDigitalBaseMaps:
          updateMunicipalDigitalBaseMaps ??
              this.updateMunicipalDigitalBaseMaps,
      plotTechnicalDescription:
          plotTechnicalDescription ?? this.plotTechnicalDescription,
      preparedDailyTimeRecord:
          preparedDailyTimeRecord ?? this.preparedDailyTimeRecord,
      submittedMpor: submittedMpor ?? this.submittedMpor,
      submittedIpcr: submittedIpcr ?? this.submittedIpcr,
      attendedMeetings:
          attendedMeetings ?? this.attendedMeetings,
      interveningTasks:
          interveningTasks ?? this.interveningTasks,
      notRegularDuty:
          notRegularDuty ?? this.notRegularDuty,
      dutyStatusReason:
          dutyStatusReason ?? this.dutyStatusReason,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      tardinessMinutes:
          tardinessMinutes ?? this.tardinessMinutes,
      undertimeMinutes:
          undertimeMinutes ?? this.undertimeMinutes,
    );
  }
}