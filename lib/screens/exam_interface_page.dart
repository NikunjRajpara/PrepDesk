import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamInterfacePage extends StatefulWidget {
  final String examTitle;
  final String examDuration;

  const ExamInterfacePage({
    super.key,
    required this.examTitle,
    required this.examDuration,
  });

  @override
  State<ExamInterfacePage> createState() => _ExamInterfacePageState();
}

class _ExamInterfacePageState extends State<ExamInterfacePage> {
  late List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  List<int?> _userAnswers = List.filled(30, null);
  late Duration _remainingTime;
  late Timer _timer;
  bool _isLoading = true;
  bool _hasAnswered = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = const Duration(minutes: 30);
    _initializeExam();
    _startTimer();
  }

  Future<void> _initializeExam() async {
    try {
      final subject = widget.examTitle.toLowerCase().replaceAll(' ', '_');

      final jsonString = await rootBundle.loadString(
        'assets/${subject}_mcqs.json',
      );
      final jsonData = json.decode(jsonString);
      final allQuestions = List<Map<String, dynamic>>.from(
        jsonData['questions'],
      );

      if (allQuestions.length < 30) {
        throw Exception(
          'Question bank contains only ${allQuestions.length} questions',
        );
      }

      final shuffled = List<Map<String, dynamic>>.from(allQuestions)..shuffle();
      _questions = shuffled.sublist(0, 30);

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      _showErrorDialog('Exam initialization failed: ${e.toString()}');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingTime.inSeconds == 0) {
        _timer.cancel();
        _submitExam();
      } else {
        setState(() => _remainingTime -= const Duration(seconds: 1));
      }
    });
  }

  void _handleAnswerSelection(int selectedIndex) {
    if (_userAnswers[_currentQuestionIndex] != null) return;

    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _userAnswers[_currentQuestionIndex] = selectedIndex;
      _hasAnswered = true;
    });
  }

  void _navigateQuestion(int direction) {
    if (!mounted) return;
    setState(() {
      _currentQuestionIndex += direction;
      _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
      _hasAnswered = _selectedAnswerIndex != null;
    });
  }

  Future<void> _submitExam() async {
    _timer.cancel();
    final score = _calculateScore();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Securely saving your results...'),
              ],
            ),
          ),
    );

    try {
      await _saveResult(score);
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showCompletionDialog(score);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showErrorDialog('Result save failed: ${e.toString()}');
      }
    }
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < 30; i++) {
      if (_userAnswers[i] == _questions[i]['correctAnswer']) score++;
    }
    return score;
  }

  Future<void> _saveResult(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User authentication failed');

    await FirebaseFirestore.instance.collection('exam_results').add({
      'userId': user.uid,
      'email': user.email,
      'exam': widget.examTitle,
      'score': score,
      'total': 30,
      'timestamp': FieldValue.serverTimestamp(),
      'attemptId': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  void _showCompletionDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Exam Submitted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Score: $score/30', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: score / 30,
                  backgroundColor: Colors.grey[200],
                  minHeight: 10,
                  color: _getScoreColor(score / 30),
                ),
                const SizedBox(height: 15),
                Text(
                  'Accuracy: ${(score / 30 * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Return Home'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Color _getScoreColor(double ratio) {
    if (ratio >= 0.75) return Colors.green;
    if (ratio >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Preparing Your Exam...',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.examTitle} • 30 minutes',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.examTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                '${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / 30,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              color: Colors.blue.shade800,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${_currentQuestionIndex + 1}. ${currentQuestion['questionText']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ...currentQuestion['options'].asMap().entries.map(
                      (entry) => _buildOptionTile(entry.key, entry.value),
                    ),
                  ],
                ),
              ),
            ),
            _buildNavigationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int index, String option) {
    final correctIndex = _questions[_currentQuestionIndex]['correctAnswer'];
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == correctIndex;
    final isUserAnswered = _userAnswers[_currentQuestionIndex] != null;

    Color? tileColor;
    if (isUserAnswered) {
      if (isSelected && isCorrect) {
        tileColor = Colors.green.shade100;
      } else if (isSelected && !isCorrect) {
        tileColor = Colors.red.shade100;
      } else if (!isSelected && isCorrect) {
        tileColor = Colors.green.shade100;
      } else {
        tileColor = Colors.transparent;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: tileColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => _handleAnswerSelection(index),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.blue.shade800 : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color:
                      isSelected ? Colors.blue.shade800 : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed:
                _currentQuestionIndex > 0 ? () => _navigateQuestion(-1) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Previous',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Text(
            '${_currentQuestionIndex + 1}/30',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentQuestionIndex < 29) {
                _navigateQuestion(1);
              } else {
                _submitExam();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _currentQuestionIndex < 29 ? 'Next' : 'Submit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
