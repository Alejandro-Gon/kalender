import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/constants.dart';
import 'package:kalender/src/extentions.dart';
import 'package:kalender/src/models/view_configurations/month_configurations/month_configuration.dart';
import 'package:kalender/src/models/view_configurations/view_configuration.dart';

class CalendarConfiguration {
  /// The [ViewConfiguration] that is used initially.
  final ViewConfiguration initialViewConfiguration;

  /// The [ViewConfiguration]s avaible for use.
  final List<ViewConfiguration> viewConfigurations;

  /// The initial date of the calendar.
  late final DateTime initialDate;

  /// The date time range of the calendar.
  late final DateTimeRange dateTimeRange;

  /// The [ScrollPhysics] used by the [CalendarView].
  final ScrollPhysics? scrollPhysics;

  /// Page transition duration.
  final Duration pageTransitionDuration;

  /// Page transition curve.
  final Curve pageTransitionCurve;

  /// Specifies the start of the week.
  ///
  /// Use [DateTime.monday] to [DateTime.sunday]
  final int firstDayOfWeek;

  /// Enable new event creation.
  ///
  /// This will enable/disable the ability to create new events with the built in gestures.
  final bool createNewEvents;

  /// The [bool] that indicates if it is a Mobile Platform.
  ///
  /// This will affect how the gestures are detected.
  late bool isMobileDevice;

  CalendarConfiguration({
    this.firstDayOfWeek = DateTime.monday,
    DateTime? initialDate,
    DateTimeRange? dateTimeRange,
    bool? isMobileDevice,
    this.initialViewConfiguration = const MonthConfiguration(),
    this.viewConfigurations = const <ViewConfiguration>[
      DayConfiguration(),
      WeekConfiguration(),
      WorkWeekConfiguration(),
      ThreeDayConfiguration(),
      FourDayConfiguration(),
      MonthConfiguration(),
    ],
    this.scrollPhysics,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.createNewEvents = true,
  }) {
    this.isMobileDevice = isMobileDevice ?? kIsWeb ? false : (Platform.isIOS || Platform.isAndroid);
    assert(
      firstDayOfWeek >= DateTime.monday && firstDayOfWeek <= DateTime.sunday,
      'First day of week must be between 1 and 7',
    );

    this.initialDate = initialDate ?? DateTime.now();
    this.dateTimeRange = dateTimeRange ?? defaultDateRange;

    assert(
      this.initialDate.isWithin(this.dateTimeRange),
      'Initial date must be within the date time range',
    );
  }
}
