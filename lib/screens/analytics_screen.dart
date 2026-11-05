import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/exam_service.dart';
import '../widgets/animated_progress_ring.dart';
import 'quiz_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final examService = context.watch<ExamService>();
    final score = examService.predictedWezariScore;
    final weakSubjects = examService.getWeakSubjects();

    String collegeText;
    Color collegeColor;
    if (score >= 95) {
      collegeText = 'کۆلێژی پزیشکی گشتی / پزیشکی ددان / دەرمانسازی 🌟';
      collegeColor = AppColors.emerald;
    } else if (score >= 85) {
      collegeText = 'کۆلێژی ئەندازیاری / زانستی کۆمپیوتەر 🚀';
      collegeColor = AppColors.indigo;
    } else if (score >= 75) {
      collegeText = 'کۆلێژی یاسا / زانست / بەڕێوەبردن و ئابووری 🎯';
      collegeColor = AppColors.amber;
    } else {
      collegeText = 'پەیمانگە تەکنیکییەکان و بەشە مرۆڤایەتییەکان 📚';
      collegeColor = AppColors.textSecondary;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('ئامار و شیکاری کۆنمرە', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Predicted Score Box
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.indigo.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  AnimatedProgressRing(percentage: score.toDouble(), size: 95, label: 'کۆنمرە'),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'کۆنمرەی پێشبینیکراوی پۆلی ١٢',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          collegeText,
                          style: TextStyle(color: collegeColor, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'بەپێی ژیریی دەستکردی شیکاری پرسیارەکانی ئامادەیا',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weak Subjects Section
            const Text(
              'دەستنیشانکردنی خاڵە لاوازەکان (تەرکیزی زیاتریان پێویستە)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 12),

            ...weakSubjects.map((s) {
              final accuracy = examService.getSubjectAccuracy(s.type);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(s.icon, color: s.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.nameKu,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'ئاستی سەرکەوتن: ${accuracy.round()}%',
                                style: TextStyle(
                                  color: accuracy < 70 ? AppColors.crimson : AppColors.emerald,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        examService.setFilterSubject(s.type);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: s.color.withOpacity(0.2),
                        foregroundColor: s.color,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('ڕاهێنانی خێرا', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
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
}
