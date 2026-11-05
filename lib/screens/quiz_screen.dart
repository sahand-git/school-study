import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/question_model.dart';
import '../services/exam_service.dart';
import '../data/wezari_database.dart';
import '../widgets/question_card.dart';
import '../widgets/confetti_overlay.dart';
import 'tutor_chat_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _triggerConfetti = false;

  @override
  Widget build(BuildContext context) {
    final examService = context.watch<ExamService>();
    final filterSubject = examService.selectedFilterSubject;

    final filteredList = wezariQuestionsList.where((q) {
      if (filterSubject == null) return true;
      return q.subject == filterSubject;
    }).toList();

    if (_currentIndex >= filteredList.length) {
      _currentIndex = 0;
    }

    final currentQuestion = filteredList.isNotEmpty ? filteredList[_currentIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          filterSubject != null
              ? appSubjects.firstWhere((s) => s.type == filterSubject).nameKu
              : 'بانکی پرسیارە وزارییەکان',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_rounded, color: AppColors.amber),
            tooltip: 'پرسیار لە مامۆستا بکە',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TutorChatScreen()),
              );
            },
          ),
        ],
      ),
      body: ConfettiOverlay(
        trigger: _triggerConfetti,
        child: SafeArea(
          child: Column(
            children: [
              // Subject Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    _FilterTab(
                      label: 'هەموو وانەکان',
                      isSelected: filterSubject == null,
                      onTap: () {
                        examService.setFilterSubject(null);
                        setState(() => _currentIndex = 0);
                      },
                    ),
                    ...appSubjects.map(
                      (subj) => _FilterTab(
                        label: subj.nameKu,
                        isSelected: filterSubject == subj.type,
                        onTap: () {
                          examService.setFilterSubject(subj.type);
                          setState(() => _currentIndex = 0);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar & Counter
              if (filteredList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'پرسیاری ${_currentIndex + 1} لە ${filteredList.length}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        '${((_currentIndex + 1) / filteredList.length * 100).round()}% تەواو بووە',
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Main Question Card
              Expanded(
                child: currentQuestion != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: QuestionCard(
                          question: currentQuestion,
                          onAnswered: (selectedOption, isCorrect) {
                            examService.recordAnswer(currentQuestion.id, isCorrect);
                            if (isCorrect) {
                              setState(() => _triggerConfetti = true);
                              Future.delayed(const Duration(milliseconds: 1200), () {
                                if (mounted) setState(() => _triggerConfetti = false);
                              });
                            }
                          },
                          onAskTutor: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TutorChatScreen(
                                  initialPrompt: 'تکایە ئەم پرسیارەی ${currentQuestion.chapterNameKu} بە زمانی سادە بۆم ڕوون بکەرەوە: "${currentQuestion.questionTextKu}"',
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Text(
                          'هیچ پرسیارێک نەدۆزرایەوە',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
              ),

              // Bottom Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _currentIndex > 0
                            ? () => setState(() => _currentIndex--)
                            : null,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('پێشوو'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _currentIndex < filteredList.length - 1
                            ? () => setState(() => _currentIndex++)
                            : null,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('دواتر'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.indigo : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.indigo : AppColors.cardBorder,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}
