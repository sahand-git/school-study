import 'package:flutter/material.dart';

enum SubjectType {
  physics,
  math,
  chemistry,
  biology,
  kurdish,
  english,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

class Subject {
  final String id;
  final SubjectType type;
  final String nameKu;
  final String nameEn;
  final IconData icon;
  final Color color;
  final int totalQuestions;
  final String descriptionKu;

  const Subject({
    required this.id,
    required this.type,
    required this.nameKu,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.totalQuestions,
    required this.descriptionKu,
  });
}

class Question {
  final String id;
  final SubjectType subject;
  final String chapterNameKu;
  final String questionTextKu;
  final Map<String, String> options; // {'A': '...', 'B': '...', 'C': '...', 'D': '...'}
  final String correctOption;
  final String simpleExplanationKu; // شیکاری بە سادەیی
  final String examTrickKu;          // فێڵی وزاری بۆ وەڵامدانەوەی خێرا
  final String commonTrapKu;         // تەڵەی وزاری و هەڵەی باوی قوتابییان
  final int wezariYear;
  final int wezariRound;
  final Difficulty difficulty;

  const Question({
    required this.id,
    required this.subject,
    required this.chapterNameKu,
    required this.questionTextKu,
    required this.options,
    required this.correctOption,
    required this.simpleExplanationKu,
    required this.examTrickKu,
    required this.commonTrapKu,
    required this.wezariYear,
    required this.wezariRound,
    this.difficulty = Difficulty.medium,
  });
}

class BiteSizedLesson {
  final String id;
  final SubjectType subject;
  final String titleKu;
  final String coreRuleKu;           // یاسای سەرەکی
  final String simplifiedAnalogyKu;  // نموونەی ژیانی ڕۆژانە بۆ تێگەیشتنی خێرا
  final List<String> keyPointsKu;    // ٣ خاڵی زێڕین بۆ لەبەرکردن
  final String examAdviceKu;         // ئامۆژگاری بۆ هۆڵی تاقیکردنەوە

  const BiteSizedLesson({
    required this.id,
    required this.subject,
    required this.titleKu,
    required this.coreRuleKu,
    required this.simplifiedAnalogyKu,
    required this.keyPointsKu,
    required this.examAdviceKu,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
