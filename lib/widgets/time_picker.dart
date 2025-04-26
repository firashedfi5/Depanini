import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final Function(String) onTimeSelected;

  const TimePicker({super.key, required this.onTimeSelected});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  final List<String> time = [
    "09:00",
    "10:00",
    "11:00",
    "15:00",
    "16:00",
    "17:00",
  ];
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: time.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onTimeSelected(time[index]);
            },
            child: Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Center(
                child: Text(
                  time[index],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
