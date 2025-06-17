import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  // *Méthode traja3lek String (temp sélectionné)
  final Function(String) onTimeSelected;
  final List<String> bookedTimes;
  final DateTime? selectedDate;

  const TimePicker({
    super.key,
    required this.onTimeSelected,
    required this.bookedTimes,
    this.selectedDate,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  final List<String> time = [
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
  ];
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.5,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: time.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;

          // *Condition bech tafichi les heures indisponibles bel a7mer w non cliquable
          if (widget.bookedTimes.contains(time[index])) {
            return Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red),
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
            );
          }

          // *Condition mat5likch ta5tar heure 9bal date
          if (widget.selectedDate == null) {
            return Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
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
            );
          }

          // *Ken yabda me5tar date ynajem ya5tar l'heure
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
