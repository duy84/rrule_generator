import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rrule_generator/localizations/text_delegate.dart';
import 'package:rrule_generator/src/rrule_generator_config.dart';

class ExcludeDates extends StatefulWidget {
  final RRuleGeneratorConfig config;
  final RRuleTextDelegate textDelegate;
  final void Function() onChange;
  final String initialRRule;
  final DateTime initialDate;
  final List<DateTime> excludeDates;

  const ExcludeDates(
    this.config,
    this.textDelegate,
    this.onChange,
    this.initialRRule,
    this.initialDate,
    this.excludeDates, {
    super.key,
  });

  String getRRule() {
    if (excludeDates.isEmpty) return '';
    String rrule = ';EXDATE=';
    for (int i = 0; i < excludeDates.length; i++) {
      rrule += excludeDates[i]
          .toIso8601String()
          .substring(0, 19)
          .replaceAll('-', '')
          .replaceAll(':', '');
      if (i != excludeDates.length - 1) rrule += ',';
    }
    return rrule;
  }

  @override
  State<ExcludeDates> createState() => _ExcludeDatesState();
}

class _ExcludeDatesState extends State<ExcludeDates> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.textDelegate.excludeDate,
              style: widget.config.labelStyle,
            ),
            IconButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: widget.initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null && !widget.excludeDates.contains(date)) {
                  widget.excludeDates.add(date);
                  widget.onChange();
                  setState(() {});
                }
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        Column(
          children: [
            for (final date in widget.excludeDates)
              ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: Text(
                  DateFormat.yMMMd(widget.textDelegate.locale).format(date),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    widget.excludeDates.remove(date);
                    widget.onChange();
                    setState(() {});
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
