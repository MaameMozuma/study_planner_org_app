import 'package:flutter/material.dart';
import 'package:study_master/controller/studyhour_controller.dart';
import 'package:study_master/controller/studytimer_controller.dart';
import 'package:study_master/model/studyhour_model.dart';
import 'package:study_master/model/studytimer_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsCard extends StatefulWidget {
  final String value;
  final String email;

  const StatsCard({
    super.key,
    required this.value,
    required this.email,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  final StudyhourController _studyhourController = StudyhourController();
  final StudytimerController _studytimerController = StudytimerController();

  Future<Map<String, double>> fetchData() async {
    List<StudyHour> studyHours = [];
    List<Studytimer> studyTimers = [];
    Map<String, double> courseTotals = {};

    try {
      final studyHourResponse =
          await _studyhourController.getAllStudyhours(widget.email);
      studyHours.addAll(studyHourResponse);

      final studyTimerResponse =
          await _studytimerController.getAllStudytimers(widget.email);
      studyTimers.addAll(studyTimerResponse);

      // Filter data based on the value (today or week)
      if (widget.value == 'today') {
        studyHours = studyHours
            .where((hour) => isToday(parseDate(hour.loggedDate)))
            .toList();
        studyTimers = studyTimers
            .where((timer) => isToday(parseDate(timer.date)))
            .toList();
      } else if (widget.value == 'week') {
        DateTime now = DateTime.now();
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

        studyHours = studyHours
            .where((hour) => isInWeek(parseDate(hour.loggedDate), startOfWeek, endOfWeek))
            .toList();
        studyTimers = studyTimers
            .where((timer) => isInWeek(parseDate(timer.date), startOfWeek, endOfWeek))
            .toList();
      }

      courseTotals = calculateCourseTotals(studyHours, studyTimers);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }

    return courseTotals;
  }

  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool isInWeek(DateTime date, DateTime startOfWeek, DateTime endOfWeek) {
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  DateTime parseDate(String dateString) {
    // Assumes the date string is in 'yyyy-MM-dd' format. Adjust if necessary.
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  Map<String, double> calculateCourseTotals(
      List<StudyHour> studyHours, List<Studytimer> studyTimers) {
    Map<String, double> totals = {};

    for (var timer in studyTimers) {
      String course = timer.course.toLowerCase();
      double duration = calculateDuration(timer.startTime, timer.endTime);
      if (totals.containsKey(course)) {
        totals[course] = totals[course]! + duration;
      } else {
        totals[course] = duration;
      }
    }

    for (var hour in studyHours) {
      String course = hour.course.toLowerCase();
      if (totals.containsKey(course)) {
        totals[course] =
            totals[course]! + parseHoursLogged(hour.hoursLogged);
      } else {
        totals[course] = parseHoursLogged(hour.hoursLogged);
      }
    }

    return totals;
  }

  double calculateDuration(String startTime, String endTime) {
    try {
      DateFormat dateFormat = DateFormat('HH:mm'); // 'h:mm a' pattern
      DateTime start = dateFormat.parse(startTime.trim());
      DateTime end = dateFormat.parse(endTime.trim());

      Duration duration = end.difference(start);
      return duration.inMinutes / 60.0;
    } catch (e) {
      print('Failed to parse time: $startTime - $endTime. Error: $e');
      return 0.0;
    }
  }

  double parseHoursLogged(String hoursLogged) {
    final parts = hoursLogged.split('h ');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1].replaceAll('m', ''));

    return hours + minutes / 60.0;
  }

  List<PieChartSectionData> _createChartData(Map<String, double> courseTotals) {
    double totalHours = courseTotals.values.fold(0.0, (a, b) => a + b);
    return courseTotals.entries.map((entry) {
      final percentage = (entry.value / totalHours) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: Colors.primaries[courseTotals.keys.toList().indexOf(entry.key) %
            Colors.primaries.length],
        radius: 10,
        titleStyle: const TextStyle(
        fontSize: 15, // Adjust font size as needed
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(29, 29, 29, 0.2),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Hours Studied',
                style: TextStyle(fontSize: 20, color: Colors.white)),
            Expanded(
              child: FutureBuilder<Map<String, double>>(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    return Row(
                      children: [
                        Expanded(
                            child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                              sections: _createChartData(snapshot.data!),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 4,
                              centerSpaceRadius: 35,
                            ),
                          ),
                        )),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: snapshot.data!.entries.map((entry) {
                              final color = Colors.primaries[snapshot.data!.keys
                                      .toList()
                                      .indexOf(entry.key) %
                                  Colors.primaries.length];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
