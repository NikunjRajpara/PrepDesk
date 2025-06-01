import 'package:flutter/material.dart';
import 'exam_interface_page.dart';

class ExamInstructionsPage extends StatelessWidget {
  final String examTitle;
  final String examDuration; // This will be ignored
  final List<String> rules;

  const ExamInstructionsPage({
    super.key,
    required this.examTitle,
    required this.examDuration,
    required this.rules,
  });

  @override
  Widget build(BuildContext context) {
    const fixedDuration = "30 minutes";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$examTitle Instructions',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExamHeader(fixedDuration),
              const SizedBox(height: 20),
              _buildInstructionsCard(),
              const SizedBox(height: 30),
              _buildStartButton(context, fixedDuration),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamHeader(String fixedDuration) {
    return Card(
      elevation: 3,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              examTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.timer, size: 20, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                Text(
                  'Duration: $fixedDuration',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Important Instructions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 15),
            ...rules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, String fixedDuration) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text(
          'Start Exam Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ExamInterfacePage(
                    examTitle: examTitle,
                    examDuration: fixedDuration,
                  ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
