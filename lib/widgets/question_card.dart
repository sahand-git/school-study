import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../constants/app_colors.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(String selectedOption, bool isCorrect) onAnswered;
  final VoidCallback onAskTutor;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onAnswered,
    required this.onAskTutor,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> with SingleTickerProviderStateMixin {
  String? _selectedOption;
  bool _showExplanation = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _selectedOption = null;
        _showExplanation = false;
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleOptionTap(String optionKey) {
    if (_selectedOption != null) return; // Prevent re-selection
    setState(() {
      _selectedOption = optionKey;
      _showExplanation = true;
    });

    final isCorrect = optionKey == widget.question.correctOption;
    if (!isCorrect) {
      _shakeController.forward(from: 0);
    }
    widget.onAnswered(optionKey, isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = (_shakeController.value > 0)
            ? (6 * (1 - _shakeController.value) * (2 * (_shakeController.value * 4).floor().isEven ? 1 : -1))
            : 0.0;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Meta: Year + Chapter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.indigo.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.indigo.withOpacity(0.3)),
                      ),
                      child: Text(
                        'وزاری ${widget.question.wezariYear} • خولی ${widget.question.wezariRound}',
                        style: const TextStyle(
                          color: AppColors.indigo,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.question.chapterNameKu,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question Text
                Text(
                  widget.question.questionTextKu,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Options List
                ...widget.question.options.entries.map((entry) {
                  final key = entry.key;
                  final text = entry.value;
                  final isSelected = _selectedOption == key;
                  final isCorrectOption = widget.question.correctOption == key;

                  Color bgColor = AppColors.surfaceLight.withOpacity(0.5);
                  Color borderColor = AppColors.cardBorder;
                  Color textColor = AppColors.textPrimary;
                  Widget? statusIcon;

                  if (_selectedOption != null) {
                    if (isCorrectOption) {
                      bgColor = AppColors.emerald.withOpacity(0.2);
                      borderColor = AppColors.emerald;
                      textColor = AppColors.emerald;
                      statusIcon = const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20);
                    } else if (isSelected) {
                      bgColor = AppColors.crimson.withOpacity(0.2);
                      borderColor = AppColors.crimson;
                      textColor = AppColors.crimson;
                      statusIcon = const Icon(Icons.cancel_rounded, color: AppColors.crimson, size: 20);
                    } else {
                      bgColor = AppColors.surfaceLight.withOpacity(0.2);
                      borderColor = AppColors.cardBorder.withOpacity(0.3);
                      textColor = AppColors.textMuted;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: InkWell(
                      onTap: () => _handleOptionTap(key),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isSelected && !isCorrectOption
                                    ? AppColors.crimson
                                    : isCorrectOption && _selectedOption != null
                                        ? AppColors.emerald
                                        : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (statusIcon != null) statusIcon,
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Simplified Explanation Drawer
                if (_showExplanation) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.indigo.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_rounded, color: AppColors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'شیکاری بە زمانی کوردی سادە:',
                              style: TextStyle(
                                color: AppColors.amber,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.question.simpleExplanationKu,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Exam Trick
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                          ),
                          child: Text(
                            widget.question.examTrickKu,
                            style: const TextStyle(
                              color: AppColors.emerald,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Common Trap
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.crimson.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.crimson.withOpacity(0.3)),
                          ),
                          child: Text(
                            widget.question.commonTrapKu,
                            style: const TextStyle(
                              color: Color(0xFFFCA5A5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Ask AI Tutor to simplify more
                        InkWell(
                          onTap: widget.onAskTutor,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'تێنەگەیشتم! بە سادەتر ڕوونی بکەرەوە',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
