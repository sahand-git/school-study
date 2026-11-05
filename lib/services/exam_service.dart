import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../data/wezari_database.dart';

class ExamService extends ChangeNotifier {
  int _streakDays = 5;
  int _targetScore = 95;
  final Map<String, bool> _answeredQuestions = {}; // questionId -> isCorrect
  final Set<String> _bookmarkedIds = {};
  SubjectType? _selectedFilterSubject;

  int get streakDays => _streakDays;
  int get targetScore => _targetScore;
  int get totalAnswered => _answeredQuestions.length;
  int get totalCorrect => _answeredQuestions.values.where((v) => v).length;
  SubjectType? get selectedFilterSubject => _selectedFilterSubject;

  double get overallAccuracy {
    if (totalAnswered == 0) return 0.0;
    return (totalCorrect / totalAnswered) * 100;
  }

  int get predictedWezariScore {
    if (totalAnswered < 3) return 86;
    final base = (overallAccuracy * 0.95) + 6;
    return base.clamp(50, 100).round();
  }

  void setFilterSubject(SubjectType? subj) {
    _selectedFilterSubject = subj;
    notifyListeners();
  }

  void recordAnswer(String questionId, bool isCorrect) {
    _answeredQuestions[questionId] = isCorrect;
    notifyListeners();
  }

  bool isQuestionAnswered(String questionId) => _answeredQuestions.containsKey(questionId);
  bool? isAnswerCorrect(String questionId) => _answeredQuestions[questionId];

  void toggleBookmark(String questionId) {
    if (_bookmarkedIds.contains(questionId)) {
      _bookmarkedIds.remove(questionId);
    } else {
      _bookmarkedIds.add(questionId);
    }
    notifyListeners();
  }

  bool isBookmarked(String questionId) => _bookmarkedIds.contains(questionId);

  double getSubjectAccuracy(SubjectType subject) {
    final subQuestions = wezariQuestionsList.where((q) => q.subject == subject).map((q) => q.id).toSet();
    final answeredInSub = _answeredQuestions.entries.where((e) => subQuestions.contains(e.key)).toList();
    if (answeredInSub.isEmpty) return 75.0; // Benchmark baseline
    final correct = answeredInSub.where((e) => e.value).length;
    return (correct / answeredInSub.length) * 100;
  }

  List<Subject> getWeakSubjects() {
    final list = List<Subject>.from(appSubjects);
    list.sort((a, b) => getSubjectAccuracy(a.type).compareTo(getSubjectAccuracy(b.type)));
    return list;
  }

  void resetProgress() {
    _answeredQuestions.clear();
    _streakDays = 1;
    notifyListeners();
  }
}
