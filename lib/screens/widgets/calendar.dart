import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  const CustomCalendar({super.key, required this.onDateSelected});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
            29, 29, 29, 1), // Set the background color to white
        borderRadius: BorderRadius.circular(0), // Rounded edges
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0), // Shadow color
            blurRadius: 0, // Shadow blur
            offset: const Offset(0, 1), // Shadow position
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              DateFormat.yMMMM()
                  .format(_focusedDay), // Display today's full date
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 13.0),
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected(selectedDay);
            },
            headerVisible: false,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false, // Hide the format button
            ),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color.fromRGBO(255, 63, 23, 0.3),
                shape: BoxShape.circle,
              ),
              weekendDecoration: BoxDecoration(
                color: Color.fromRGBO(29, 29, 29, 1),
                shape: BoxShape.circle,
              ),
              defaultDecoration: BoxDecoration(
                color: Color.fromRGBO(29, 29, 29, 1),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle, // Rounded rectangle
                color: Color.fromRGBO(255, 63, 23, 1), // White background color
              ),
              todayTextStyle: TextStyle(
                color: Colors.white, // Text color for today's date
                fontWeight: FontWeight.normal, // Optional: make the text bold
              ),
              outsideDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.white),
              defaultTextStyle: TextStyle(color: Colors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.white),
              weekdayStyle: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
