import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/bite_sized_lessons.dart';
import '../widgets/lesson_flashcard.dart';
import 'quiz_screen.dart';

class LearnBasicsScreen extends StatefulWidget {
  const LearnBasicsScreen({super.key});

  @override
  State<LearnBasicsScreen> createState() => _LearnBasicsScreenState();
}

class _LearnBasicsScreenState extends State<LearnBasicsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'فێرکاری بنەماکان بە سادەیی',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'یاسا سەرەکییەکان بە نموونەی ڕۆژانە',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'وانەی ${_currentPage + 1} لە ${biteSizedLessonsList.length}',
                    style: const TextStyle(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Page View of Lessons
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: biteSizedLessonsList.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  return LessonFlashcard(lesson: biteSizedLessonsList[index]);
                },
              ),
            ),

            // Bottom Navigation & Practice Trigger
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(
                      biteSizedLessonsList.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == index ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.amber : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Direct Practice Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('ڕاهێنانی وزاری لەسەر ئەمە'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
