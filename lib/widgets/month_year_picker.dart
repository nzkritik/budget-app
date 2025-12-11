import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class MonthYearPicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const MonthYearPicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  void _previousMonth() {
    final newDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    onDateChanged(newDate);
  }

  void _nextMonth() {
    final newDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    onDateChanged(newDate);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onDateChanged(DateTime(picked.year, picked.month, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = selectedDate.year == now.year && 
                          selectedDate.month == now.month;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
            ),
            InkWell(
              onTap: () => _pickDate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      Helpers.formatMonthYear(selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: isCurrentMonth ? null : _nextMonth,
            ),
          ],
        ),
      ),
    );
  }
}
