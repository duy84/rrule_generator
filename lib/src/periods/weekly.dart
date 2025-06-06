import 'package:flutter/material.dart';
import 'package:rrule_generator/localizations/text_delegate.dart';
import 'package:rrule_generator/src/pickers/interval.dart';
import 'package:rrule_generator/src/periods/period.dart';
import 'package:rrule_generator/src/pickers/weekday.dart';

import '../pickers/helpers.dart';
import '../rrule_generator_config.dart';

class Weekly extends StatelessWidget implements Period {
  @override
  final RRuleGeneratorConfig config;
  @override
  final RRuleTextDelegate textDelegate;
  @override
  final void Function() onChange;
  @override
  final String initialRRule;
  @override
  final DateTime initialDate;

  final intervalController = TextEditingController(text: '1');
  final weekdayNotifiers = List.generate(
    7,
    (index) => ValueNotifier(false),
  );

  Weekly(this.config, this.textDelegate, this.onChange, this.initialRRule,
      this.initialDate,
      {super.key}) {
    if (initialRRule.contains('WEEKLY')) {
      handleInitialRRule();
    } else {
      weekdayNotifiers[initialDate.weekday - 1].value = true;
    }
  }

  @override
  void handleInitialRRule() {
    if (initialRRule.contains('INTERVAL=')) {
      final intervalIndex = initialRRule.indexOf('INTERVAL=') + 9;
      int intervalEnd = initialRRule.indexOf(';', intervalIndex);
      intervalEnd = intervalEnd == -1 ? initialRRule.length : intervalEnd;
      final interval = initialRRule.substring(
          intervalIndex, intervalEnd == -1 ? initialRRule.length : intervalEnd);
      intervalController.text = interval;
    }

    if (initialRRule.contains('BYDAY=')) {
      final weekdayIndex = initialRRule.indexOf('BYDAY=') + 6;
      int weekdayEnd = initialRRule.indexOf(';', weekdayIndex);
      weekdayEnd = weekdayEnd == -1 ? initialRRule.length : weekdayEnd;
      final weekdays = initialRRule.substring(
          weekdayIndex, weekdayEnd == -1 ? initialRRule.length : weekdayEnd);
      for (int i = 0; i < 7; i++) {
        if (weekdays.contains(weekdaysShort[i])) {
          weekdayNotifiers[i].value = true;
        }
      }
    }
  }

  @override
  String getRRule() {
    final interval = int.tryParse(intervalController.text) ?? 0;
    List<String> weekdayList = [];
    for (int i = 0; i < 7; i++) {
      if (weekdayNotifiers[i].value) weekdayList.add(weekdaysShort[i]);
    }

    return weekdayList.isEmpty
        ? 'FREQ=WEEKLY;INTERVAL=${interval > 0 ? interval : 1}'
        : 'FREQ=WEEKLY;INTERVAL=${interval > 0 ? interval : 1};'
            'BYDAY=${weekdayList.join(",")}';
  }

  @override
  Widget build(BuildContext context) => buildElement(
        title: textDelegate.every,
        style: config.headerTextStyle,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: IntervalPicker(
                    intervalController,
                    onChange,
                    config: config,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.zero,
                  child: Text(
                    textDelegate.weeks,
                    style: config.labelStyle,
                  ),
                ),
              ],
            ),
            WeekdayPicker(
              weekdayNotifiers,
              textDelegate,
              onChange,
              config: config,
            ),
          ],
        ),
      );
}
