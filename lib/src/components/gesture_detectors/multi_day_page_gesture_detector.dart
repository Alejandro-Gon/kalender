import 'package:flutter/material.dart';

import 'package:kalender/kalender.dart';
import 'package:kalender/src/constants.dart';

/// This widget is used to detect gestures on the [MultiDayPageWidget].
class MultiDayPageGestureDetector<T> extends StatefulWidget {
  const MultiDayPageGestureDetector({
    super.key,
    required this.viewConfiguration,
    required this.visibleDates,
    required this.heightPerMinute,
    required this.verticalStep,
  });

  final MultiDayViewConfiguration viewConfiguration;
  final List<DateTime> visibleDates;

  /// The height per minute.
  final double heightPerMinute;
  final double verticalStep;

  @override
  State<MultiDayPageGestureDetector<T>> createState() =>
      _MultiDayPageGestureDetectorState<T>();
}

class _MultiDayPageGestureDetectorState<T>
    extends State<MultiDayPageGestureDetector<T>> {
  CalendarScope<T> get scope => CalendarScope.of<T>(context);
  CalendarEventsController<T> get controller => scope.eventsController;
  bool get createEvents => widget.viewConfiguration.createEvents;
  CreateEventTrigger get createEventTrigger =>
      widget.viewConfiguration.createEventTrigger;
  bool get isMobile => scope.platformData.isMobileDevice;
  bool get longPressDrag =>
      createEventTrigger == CreateEventTrigger.longPressDrag;
  bool get longPressAndDrag =>
      createEventTrigger == CreateEventTrigger.longPressAndDrag;
  bool get tapAndDrag => createEventTrigger == CreateEventTrigger.tapAndDrag;

  int get newEventDurationInMinutes =>
      widget.viewConfiguration.newEventDuration.inMinutes;
  bool get canDrag => createEvents && !isMobile && !longPressDrag;

  double cursorOffset = 0;
  int currentVerticalSteps = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          createEvents ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.visibleDates.map((date) {
          return Expanded(
            child: Column(
              children: List.generate(
                (hoursADay * 60) ~/ newEventDurationInMinutes,
                (slotIndex) {
                  return Expanded(
                    child: SizedBox.expand(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onLongPress: longPressDrag
                            ? null
                            : () {
                                if (longPressAndDrag) {
                                  _createEvent(
                                    calculateNewEventDateTimeRange(
                                      date,
                                      slotIndex,
                                    ),
                                  );
                                } else {
                                  controller.deselectEvent();
                                }
                              },
                        onTap: () {
                          if (tapAndDrag) {
                            _createEvent(
                              calculateNewEventDateTimeRange(date, slotIndex),
                            );
                          } else {
                            controller.deselectEvent();
                          }
                        },
                        onLongPressStart: createEvents && !longPressDrag
                            ? null
                            : (_) {
                                _onVerticalDragStart(
                                  calculateNewEventDateTimeRange(
                                    date,
                                    slotIndex,
                                  ),
                                );
                              },
                        onLongPressMoveUpdate: createEvents && !longPressDrag
                            ? null
                            : (moveDetails) {
                                final details = DragUpdateDetails(
                                  delta: Offset(
                                    moveDetails.offsetFromOrigin.dx,
                                    moveDetails.offsetFromOrigin.dy -
                                        cursorOffset,
                                  ),
                                  globalPosition: moveDetails.globalPosition,
                                );
                                _onVerticalDragUpdate(
                                  details,
                                  calculateNewEventDateTimeRange(
                                    date,
                                    slotIndex,
                                  ),
                                );
                              },
                        onLongPressEnd: createEvents && !longPressDrag
                            ? null
                            : (moveDetails) {
                                _onVerticalDragEnd(DragEndDetails());
                              },
                        onVerticalDragStart: !canDrag
                            ? null
                            : (_) {
                                _onVerticalDragStart(
                                  calculateNewEventDateTimeRange(
                                    date,
                                    slotIndex,
                                  ),
                                );
                              },
                        onVerticalDragUpdate: !canDrag
                            ? null
                            : (details) {
                                _onVerticalDragUpdate(
                                  details,
                                  calculateNewEventDateTimeRange(
                                    date,
                                    slotIndex,
                                  ),
                                );
                              },
                        onVerticalDragEnd: !canDrag ? null : _onVerticalDragEnd,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Creates new event.
  void _createEvent(DateTimeRange dateTimeRange) async {
    // If the create events flag is false, return.
    if (!createEvents) return;

    // Call the onEventCreate callback.
    final newEvent = scope.functions.onCreateEvent?.call(
      dateTimeRange,
    );

    // If the new event is null, return.
    if (newEvent == null) return;

    // Call the onEventCreated callback.
    await scope.functions.onEventCreated?.call(
      newEvent,
    );

    // // If the selected event is not null, deselect it.
    // if (controller.selectedEvent != null) {
    //   controller.deselectEvent();
    //   return;
    // }

    // // Set the selected event to a new event.
    // scope.eventsController.selectEvent(
    //   CalendarEvent<T>(
    //     dateTimeRange: dateTimeRange,
    //   ),
    // );
    // // Call the onCreateEvent callback.
    // await scope.functions.onCreateEvent?.call(
    //   scope.eventsController.selectedEvent!,
    // );
  }

  /// Handles the vertical drag start event.
  void _onVerticalDragStart(
    DateTimeRange initialDateTimeRange,
  ) {
    cursorOffset = 0;
    currentVerticalSteps = 0;

    // Call the onEventCreate callback.
    final newEvent = scope.functions.onCreateEvent?.call(
      initialDateTimeRange,
    );

    // If the new event is null, return.
    if (newEvent == null) return;

    scope.eventsController.selectEvent(
      newEvent,
    );
  }

  /// Handles the vertical drag update event.
  void _onVerticalDragUpdate(
    DragUpdateDetails details,
    DateTimeRange initialDateTimeRange,
  ) {
    if (scope.eventsController.selectedEvent == null) return;

    cursorOffset += details.delta.dy;

    final verticalSteps = cursorOffset ~/ widget.verticalStep;
    if (verticalSteps == currentVerticalSteps) return;

    DateTimeRange dateTimeRange;
    if (currentVerticalSteps.isNegative) {
      dateTimeRange = DateTimeRange(
        start: initialDateTimeRange.start.add(
          Duration(
            minutes: newEventDurationInMinutes * currentVerticalSteps,
          ),
        ),
        end: initialDateTimeRange.end,
      );
    } else {
      dateTimeRange = DateTimeRange(
        start: initialDateTimeRange.start,
        end: initialDateTimeRange.end.add(
          Duration(
            minutes: newEventDurationInMinutes * currentVerticalSteps,
          ),
        ),
      );
    }

    scope.eventsController.selectedEvent?.dateTimeRange = dateTimeRange;

    currentVerticalSteps = verticalSteps;
  }

  /// Handles the vertical drag end event.
  void _onVerticalDragEnd(DragEndDetails _) async {
    if (scope.eventsController.selectedEvent == null) return;

    cursorOffset = 0;

    final selectedEvent = scope.eventsController.selectedEvent!;

    await scope.functions.onEventCreated?.call(
      selectedEvent,
    );
  }

  ///
  DateTimeRange calculateNewEventDateTimeRange(DateTime date, int slotIndex) {
    final start = date.add(
      Duration(
        minutes: slotIndex * newEventDurationInMinutes,
      ),
    );
    final end = start.add(
      widget.viewConfiguration.newEventDuration,
    );
    return DateTimeRange(start: start, end: end);
  }
}
