import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exam_instruction_page.dart';
import 'results_page.dart';
import 'history_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final List<Map<String, dynamic>> exams = [
      {
        'subject': 'Java',
        'date': 'April 15, 2024',
        'duration': '30 Minutes',
        'status': 'Ongoing',
      },
      {
        'subject': 'Operating System',
        'date': 'April 17, 2024',
        'duration': '30 Minutes',
        'status': 'Upcoming',
      },
      {
        'subject': 'Cloud Computing',
        'date': 'April 19, 2024',
        'duration': '30 Minutes',
        'status': 'Upcoming',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PrepDesk',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading profile: ${snapshot.error}',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'User data not found',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['username'] as String?;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(username),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upcoming Exams',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: exams.length,
                          itemBuilder:
                              (context, index) => _buildExamCard(
                                context,
                                subject: exams[index]['subject'],
                                date: exams[index]['date'],
                                duration: exams[index]['duration'],
                                status: exams[index]['status'],
                              ),
                        ),
                        const SizedBox(height: 20),
                        _buildQuickActions(context),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String? username) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 35, color: Colors.blue),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username != null ? 'Welcome, $username!' : 'Welcome!',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Ready for your next exam?',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(
    BuildContext context, {
    required String subject,
    required String date,
    required String duration,
    required String status,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  backgroundColor:
                      status == 'Ongoing'
                          ? Colors.orange.shade100
                          : Colors.blue.shade100,
                  label: Text(
                    status,
                    style: TextStyle(
                      color:
                          status == 'Ongoing'
                              ? Colors.orange.shade800
                              : Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildExamDetail(Icons.calendar_today, date),
            const SizedBox(height: 8),
            _buildExamDetail(Icons.timer, duration),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ExamInstructionsPage(
                            examTitle: subject,
                            examDuration: duration,
                            rules: const [
                              'The exam contains 30 multiple-choice questions',
                              'No going back to previous questions',
                              'Results available immediately after submission',
                              'Any malpractice will cancel your exam',
                            ],
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      status == 'Ongoing'
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  status == 'Ongoing' ? 'Continue Exam' : 'Start Exam',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // _buildActionButton(Icons.quiz, 'All Exams', Colors.blue.shade700, () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const StartExamPage()),
        //   );
        // }),
        _buildActionButton(Icons.history, 'Result', Colors.green.shade700, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResultsPage(),
            ), // Changed from ResultsPage
          );
        }),
        _buildActionButton(
          Icons.history_edu,
          'History',
          Colors.purple.shade700,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 32),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
