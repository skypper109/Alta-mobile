import 'package:flutter/material.dart';

class MalianClass {
  const MalianClass({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.level,
    required this.emoji,
    required this.description,
    required this.subjects,
    required this.suggestedQuestions,
    required this.color,
    required this.iconData,
  });

  final String id;
  final String label;
  final String shortLabel;
  final String level;
  final String emoji;
  final String description;
  final List<String> subjects;
  final List<String> suggestedQuestions;
  final int color;
  final IconData iconData;
}
