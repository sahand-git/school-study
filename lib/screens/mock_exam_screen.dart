import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/question_model.dart';
import '../data/wezari_database.dart';

class MockExamScreen extends StatefulWidget {
  const MockExamScreen({super.key});

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  bool _isExamActive = false;
  bool _isCompleted = false;
  int _secondsLeft = 12 * 60; // 12 minutes
  Timer? _timer;
  int _currentIndex = 0;
  final Map<String, String> _selectedAnswers = {};
  late List<Question> _examQuestions;

  @override
  void initState() {
    super.initState();
    _examQuestions = List.from(wezariQuestionsList)..shuffle();
  }

  void _startExam() {
    setState(() {
      _isExamActive = true;
      _isCompleted = false;
      _secondsLeft = 12 * 60;
      _currentIndex = 0;
      _selectedAnswers.clear();
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _submitExam();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _submitExam() {
    _timer?.cancel();
    setState(() {
      _isExamActive = false;
      _isCompleted = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      // Results View
      int correct = 0;
      for (var q in _examQuestions) {
        if (_selectedAnswers[q.id] == q.correctOption) correct++;
      }
      final percentage = ((correct / _examQuestions.length) * 100).round();

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('ئەنجامی تاقیکردنەوەی وزاری'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: AppColors.amber, size: 54),
                    const SizedBox(height: 10),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: AppColors.emerald,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'کۆنمرەی بەدەستهاتوو',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ResultStat(label: 'ڕاست', value: '$correct', color: AppColors.emerald),
                        _ResultStat(label: 'هەڵە / بەتاڵ', value: '${_examQuestions.length - correct}', color: AppColors.crimson),
                        _ResultStat(label: 'کۆی پرسیار', value: '${_examQuestions.length}', color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _startExam,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('دووبارەکردنەوەی تاقیکردنەوە'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Question review list
              ..._examQuestions.map((q) {
                final isRight = _selectedAnswers[q.id] == q.correctOption;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isRight ? AppColors.emerald.withOpacity(0.4) : AppColors.crimson.withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            q.chapterNameKu,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                          Icon(
                            isRight ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isRight ? AppColors.emerald : AppColors.crimson,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        q.questionTextKu,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'وەڵامی تۆ: ${_selectedAnswers[q.id] ?? "بەتاڵ"} • وەڵامی ڕاست: ${q.correctOption} (${q.options[q.correctOption]})',
                        style: TextStyle(
                          color: isRight ? AppColors.emerald : AppColors.crimson,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '💡 شیکاری: ${q.simpleExplanationKu}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    if (_isExamActive) {
      final currentQ = _examQuestions[_currentIndex];

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text('پرسیاری ${_currentIndex + 1} لە ${_examQuestions.length}'),
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _secondsLeft < 120 ? AppColors.crimson.withOpacity(0.2) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _secondsLeft < 120 ? AppColors.crimson : AppColors.amber,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.alarm_rounded,
                    color: _secondsLeft < 120 ? AppColors.crimson : AppColors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_secondsLeft),
                    style: TextStyle(
                      color: _secondsLeft < 120 ? AppColors.crimson : AppColors.amber,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Palette row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_examQuestions.length, (idx) {
                      final q = _examQuestions[idx];
                      final isAnswered = _selectedAnswers.containsKey(q.id);
                      final isCurrent = idx == _currentIndex;

                      return InkWell(
                        onTap: () => setState(() => _currentIndex = idx),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.indigo
                                : isAnswered
                                    ? AppColors.emerald.withOpacity(0.3)
                                    : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent ? AppColors.indigo : AppColors.cardBorder,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // Question Box
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentQ.chapterNameKu,
                          style: const TextStyle(color: AppColors.indigo, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentQ.questionTextKu,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView(
                            children: currentQ.options.entries.map((entry) {
                              final isSelected = _selectedAnswers[currentQ.id] == entry.key;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedAnswers[currentQ.id] = entry.key;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.indigo.withOpacity(0.25) : AppColors.surfaceLight.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.indigo : AppColors.cardBorder,
                                        width: 1.3,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.indigo : AppColors.surfaceLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            entry.key,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Navigation controls
                Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentIndex--),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('پێشوو'),
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentIndex < _examQuestions.length - 1
                            ? () => setState(() => _currentIndex++)
                            : _submitExam,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentIndex < _examQuestions.length - 1 ? AppColors.indigo : AppColors.emerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _currentIndex < _examQuestions.length - 1 ? 'دواتر' : 'تەواوکردن و ناردن',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Pre-Exam Screen
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('تاقیکردنەوەی خولی وزاری'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.assignment_turned_in_rounded, color: AppColors.indigo, size: 58),
                const SizedBox(height: 16),
                const Text(
                  'تاقیکردنەوەی خولی وزاری',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                ),
                const SizedBox(height: 8),
                const Text(
                  'پرسیاری تێکەڵاو لە ساڵانی ڕابردوو، بە کاتژمێری فەرمی و بێ پیشاندانی شیکاری تاوەکو کاتی کۆتاییهێنان.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _startExam,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('دەستپێکردنی تاقیکردنەوە (١٢ خولەک)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
