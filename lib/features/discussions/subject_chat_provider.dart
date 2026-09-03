import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'socratic_cards_page.dart';

/// Provider de la matière actuellement filtrée pour les discussions (null = Général / Toutes).
final activeSubjectProvider = StateProvider<String?>((ref) => null);

/// Entrée d'historique sérialisable par matière
class SerializedDiscussionSession {
  SerializedDiscussionSession({
    required this.id,
    required this.title,
    required this.subject,
    required this.messages,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? subject;
  final List<SerializedChatMessage> messages;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'messages': messages.map((m) => m.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SerializedDiscussionSession.fromJson(Map<String, dynamic> json) =>
      SerializedDiscussionSession(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Discussion',
        subject: json['subject'] as String?,
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((m) => SerializedChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  DiscussionSession toDiscussionSession() => DiscussionSession(
        id: id,
        title: title,
        messages: messages
            .map((m) => ChatMessage(
                  isUser: m.isUser,
                  text: m.text,
                  timestamp: m.timestamp,
                ))
            .toList(),
        updatedAt: updatedAt,
      );

  static SerializedDiscussionSession fromDiscussionSession(
    DiscussionSession session,
    String? subject,
  ) =>
      SerializedDiscussionSession(
        id: session.id,
        title: session.title,
        subject: subject,
        messages: session.messages
            .map((m) => SerializedChatMessage(
                  isUser: m.isUser,
                  text: m.text,
                  timestamp: m.timestamp,
                ))
            .toList(),
        updatedAt: session.updatedAt,
      );
}

class SerializedChatMessage {
  SerializedChatMessage({
    required this.isUser,
    required this.text,
    required this.timestamp,
  });

  final bool isUser;
  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'isUser': isUser,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SerializedChatMessage.fromJson(Map<String, dynamic> json) =>
      SerializedChatMessage(
        isUser: json['isUser'] as bool? ?? false,
        text: json['text'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Gestionnaire de persistance locale de l'historique par matière
class SubjectChatHistoryManager {
  static const String _keyPrefix = 'alternia_chat_history_';

  static String _storageKey(String? subject) {
    if (subject == null || subject.trim().isEmpty || subject.toLowerCase() == 'toutes') {
      return '${_keyPrefix}general';
    }
    final clean = subject.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return '$_keyPrefix$clean';
  }

  /// Charge les sessions pour une matière donnée
  static Future<List<DiscussionSession>> loadSessions(String? subject) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey(subject);
      final rawJson = prefs.getString(key);
      if (rawJson == null || rawJson.isEmpty) return [];

      final list = jsonDecode(rawJson) as List<dynamic>;
      return list
          .map((item) => SerializedDiscussionSession.fromJson(item as Map<String, dynamic>).toDiscussionSession())
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Sauvegarde une liste de sessions pour une matière donnée
  static Future<void> saveSessions(String? subject, List<DiscussionSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey(subject);
      final serialized = sessions
          .map((s) => SerializedDiscussionSession.fromDiscussionSession(s, subject).toJson())
          .toList();
      await prefs.setString(key, jsonEncode(serialized));
    } catch (_) {}
  }

  /// Sauvegarde ou met à jour une session individuelle
  static Future<void> saveSingleSession(String? subject, DiscussionSession session) async {
    if (session.messages.isEmpty) return;
    final currentList = await loadSessions(subject);
    final idx = currentList.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      currentList[idx] = session;
    } else {
      currentList.insert(0, session);
    }
    // Conserver un maximum de 25 sessions par matière pour optimiser le stockage
    if (currentList.length > 25) {
      currentList.removeRange(25, currentList.length);
    }
    await saveSessions(subject, currentList);
  }

  /// Supprime une session pour une matière
  static Future<void> deleteSession(String? subject, String sessionId) async {
    final currentList = await loadSessions(subject);
    currentList.removeWhere((s) => s.id == sessionId);
    await saveSessions(subject, currentList);
  }
}
