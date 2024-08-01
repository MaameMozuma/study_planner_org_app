import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_master/controller/studyhour_controller.dart';
import 'package:study_master/model/studyhour_model.dart';
import 'package:study_master/screens/sub-pages/create_studyHour.dart';
import 'package:study_master/screens/widgets/studyHour_card.dart';

class ViewStudyHourLogs extends StatefulWidget {
  const ViewStudyHourLogs({super.key});

  @override
  State<ViewStudyHourLogs> createState() => _ViewStudyHourLogsState();
}

class _ViewStudyHourLogsState extends State<ViewStudyHourLogs> {
  final StudyhourController _studyhourController = StudyhourController();
  late Future<List<StudyHour>> _studyHours;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _studyHours = _fetchData(_user.email!);
  }

  Future<void> _refreshStudyHours() async {
    setState(() {
      _studyHours = _fetchData(_user.email!);
    });
  }

  void _deleteStudyHour(StudyHour studyHour) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
          title: const Text(
            'Confirm Deletion',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this study hour?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _studyhourController.deleteStudyhour(studyHour.studyhour_id);
        setState(() {
          _studyHours = _fetchData(_user.email!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Successfully deleted study hour',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(255, 63, 23, 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete study hour: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<List<StudyHour>> _fetchData(String email) async {
    return await _studyhourController.getAllStudyhours(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        title: const Text('StudyLogs',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
                context: context,
                builder: (context) => CreateStudyhour(
                  rootContext: context,
                  onStudyHourCreated: _refreshStudyHours,
                ),
              ).whenComplete(() {
                _refreshStudyHours();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<StudyHour>>(
          future: _studyHours,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              List<StudyHour> studyHours = snapshot.data!;
              if (studyHours.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Image.asset('assets/images/DataanalysisCaseStudy.png'),
                        const SizedBox(height: 0),
                        const Text('No Study Logs!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _refreshStudyHours,
                child: ListView.builder(
                  itemCount: studyHours.length,
                  itemBuilder: (context, index) {
                    return StudyHourCard(
                      studyHour: studyHours[index],
                      onDelete: () {
                        _deleteStudyHour(studyHours[index]);
                      },
                      rootContext: context,
                    );
                  },
                ),
              );
            } else {
              return const Text('No data');
            }
          },
        ),
      ),
    );
  }
}
