import 'package:flutter/material.dart';
import 'exam_instruction_page.dart';

class StartExamPage extends StatelessWidget {
  const StartExamPage({super.key});

  final List<Map<String, dynamic>> exams = const [
    {
      'subject': 'Java Programming',
      'date': 'April 25, 2024',
      'duration': '45 Minutes',
      'questions': 30,
      'status': 'Available',
    },
    {
      'subject': 'Operating Systems',
      'date': 'April 26, 2024',
      'duration': '45 Minutes',
      'questions': 30,
      'status': 'Available',
    },
    {
      'subject': 'Cloud Computing',
      'date': 'April 27, 2024',
      'duration': '45 Minutes',
      'questions': 30,
      'status': 'Upcoming',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Exams',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          itemBuilder:
              (context, index) => _buildExamCard(context, exams[index]),
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Map<String, dynamic> exam) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ExamInstructionsPage(
                    examTitle: exam['subject'],
                    examDuration: exam['duration'],
                    rules: [
                      'Total questions: 30 (selected from 100)',
                      'Duration: ${exam['duration']}',
                      'Questions shuffle on every attempt',
                      'No negative marking',
                    ],
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam['subject'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    backgroundColor:
                        exam['status'] == 'Available'
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                    label: Text(
                      exam['status'],
                      style: TextStyle(
                        color:
                            exam['status'] == 'Available'
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildExamDetail(Icons.calendar_today, exam['date']),
              const SizedBox(height: 8),
              _buildExamDetail(Icons.timer, exam['duration']),
              const SizedBox(height: 8),
              _buildExamDetail(
                Icons.help_outline,
                '${exam['questions']} Questions',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ExamInstructionsPage(
                              examTitle: exam['subject'],
                              examDuration: exam['duration'],
                              rules: [
                                'Total questions: ${exam['questions']}',
                                'Duration: ${exam['duration']}',
                                'No negative marking',
                                'All questions are mandatory',
                              ],
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Start Exam',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
      ],
    );
  }
}
