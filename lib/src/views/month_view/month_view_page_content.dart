import 'package:flutter/material.dart';
import 'package:kalender/kalender_scope.dart';
import 'package:kalender/src/components/event_groups/multi_day_event_group_widget.dart';
import 'package:kalender/src/components/gesture_detectors/multi_day_header_gesture_detector.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/event_group_controllers/multi_day_event_group_controller.dart';
import 'package:kalender/src/models/view_configurations/month_configurations/month_view_configuration.dart';

class MonthViewPageContent<T> extends StatelessWidget {
  const MonthViewPageContent({
    super.key,
    required this.viewConfiguration,
    required this.visibleDateRange,
    required this.horizontalStep,
    required this.verticalStep,
  });

  final DateTimeRange visibleDateRange;
  final MonthViewConfiguration viewConfiguration;
  final double horizontalStep;
  final double verticalStep;

  @override
  Widget build(BuildContext context) {
    final scope = CalendarScope.of<T>(context);
    return Stack(
      children: <Widget>[
        scope.components.monthGridBuilder(),
        ListenableBuilder(
          listenable: scope.eventsController,
          builder: (context, child) {
            return Column(
              children: [
                for (int c = 0; c < 5; c++)
                  Builder(
                    builder: (context) {
                      // Calculate the start date.
                      final start = visibleDateRange.start.add(
                        Duration(days: c * 7),
                      );

                      // Calculate the end date.
                      final end = visibleDateRange.start.add(
                        Duration(days: (c * 7) + 7),
                      );
                      // Create a date range from the start and end dates.
                      final weekDateRange = DateTimeRange(
                        start: start,
                        end: end,
                      );

                      // Get the events from the events controller.
                      final events =
                          scope.eventsController.getEventsFromDateRange(
                        weekDateRange,
                      );

                      // Create a multi day event group from the events.
                      final multiDayEventGroup =
                          MultiDayEventGroupController<T>()
                              .generateMultiDayEventGroup(
                        events: events,
                      );

                      final selectedEvent =
                          scope.eventsController.selectedEvent;
                      final horizontalStepDuration =
                          viewConfiguration.horizontalStepDuration;
                      final verticalStepDuration =
                          viewConfiguration.verticalStepDuration;
                      final multiDayTileHeight =
                          viewConfiguration.multiDayTileHeight;

                      // Calculate the height of the multi day event group.
                      final height = multiDayTileHeight *
                          (multiDayEventGroup.maxNumberOfStackedEvents + 1);

                      return Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                for (int r = 0; r < 7; r++)
                                  scope.components.monthCellHeaderBuilder(
                                    visibleDateRange.start.add(
                                      Duration(days: (c * 7) + r),
                                    ),
                                    (date) => scope.functions.onDateTapped
                                        ?.call(date),
                                  ),
                              ],
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  MultiDayHeaderGestureDetector<T>(
                                    viewConfiguration: viewConfiguration,
                                    visibleDateRange: weekDateRange,
                                    horizontalStep: horizontalStep,
                                    verticalStep: verticalStep,
                                  ),
                                  SingleChildScrollView(
                                    child: SizedBox(
                                      height: height,
                                      child: Stack(
                                        children: [
                                          MultiDayEventGroupWidget<T>(
                                            multiDayEventGroup:
                                                multiDayEventGroup,
                                            visibleDateRange: weekDateRange,
                                            horizontalStep: horizontalStep,
                                            horizontalStepDuration:
                                                horizontalStepDuration,
                                            verticalStep: verticalStep,
                                            verticalStepDuration:
                                                verticalStepDuration,
                                            isChanging: false,
                                            multiDayTileHeight:
                                                multiDayTileHeight,
                                            rescheduleDateRange:
                                                visibleDateRange,
                                          ),
                                          if (selectedEvent != null &&
                                              scope.eventsController
                                                  .hasChangingEvent)
                                            ListenableBuilder(
                                              listenable: scope.eventsController
                                                  .selectedEvent!,
                                              builder: (context, child) {
                                                if (selectedEvent
                                                        .dateTimeRange.start
                                                        .isWithin(
                                                      weekDateRange,
                                                    ) ||
                                                    selectedEvent
                                                        .dateTimeRange.end
                                                        .isWithin(
                                                      weekDateRange,
                                                    ) ||
                                                    (selectedEvent.start
                                                            .isBefore(
                                                          weekDateRange.start,
                                                        ) &&
                                                        selectedEvent.end
                                                            .isAfter(
                                                          weekDateRange.end,
                                                        ))) {
                                                  final multiDayEventGroup =
                                                      MultiDayEventGroupController<
                                                              T>()
                                                          .generateMultiDayEventGroup(
                                                    events: [selectedEvent],
                                                  );

                                                  return MultiDayEventGroupWidget<
                                                      T>(
                                                    multiDayEventGroup:
                                                        multiDayEventGroup,
                                                    visibleDateRange:
                                                        weekDateRange,
                                                    horizontalStep:
                                                        horizontalStep,
                                                    horizontalStepDuration:
                                                        horizontalStepDuration,
                                                    verticalStep: verticalStep,
                                                    verticalStepDuration:
                                                        verticalStepDuration,
                                                    isChanging: true,
                                                    multiDayTileHeight:
                                                        multiDayTileHeight,
                                                    rescheduleDateRange:
                                                        visibleDateRange,
                                                  );
                                                } else {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}