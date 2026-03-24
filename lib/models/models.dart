import 'dart:convert';
import 'package:uuid/uuid.dart';

// ─── FLASHCARD MODEL ───
class Flashcard {
  final String id;
  final String front;
  final String back;
  final String language;
  int easeFactor;       // SM-2 factor (starts at 2500)
  int interval;         // days until next review
  int repetitions;      // consecutive correct answers
  DateTime? nextReview;
  int totalReviews;
  int correctReviews;

  Flashcard({
    String? id,
    required this.front,
    required this.back,
    required this.language,
    this.easeFactor = 2500,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReview,
    this.totalReviews = 0,
    this.correctReviews = 0,
  }) : id = id ?? const Uuid().v4();

  bool get isDueToday {
    if (nextReview == null) return true;
    final now = DateTime.now();
    return nextReview!.isBefore(now) || 
           (nextReview!.year == now.year && 
            nextReview!.month == now.month && 
            nextReview!.day == now.day);
  }

  double get accuracy => totalReviews > 0 ? correctReviews / totalReviews : 0;

  // SM-2 algorithm rating: 1=Again, 2=Hard, 3=Good, 4=Easy
  void rate(int rating) {
    totalReviews++;
    if (rating >= 3) correctReviews++;

    if (rating < 3) {
      repetitions = 0;
      interval = 1;
    } else {
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor / 1000).round();
      }
      repetitions++;
    }

    easeFactor = (easeFactor + (400 - (5 - rating) * (80 + (5 - rating) * 20))).clamp(1300, 5000);
    nextReview = DateTime.now().add(Duration(days: interval));
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'front': front, 'back': back, 'language': language,
    'easeFactor': easeFactor, 'interval': interval, 'repetitions': repetitions,
    'nextReview': nextReview?.toIso8601String(),
    'totalReviews': totalReviews, 'correctReviews': correctReviews,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    front: json['front'],
    back: json['back'],
    language: json['language'],
    easeFactor: json['easeFactor'] ?? 2500,
    interval: json['interval'] ?? 0,
    repetitions: json['repetitions'] ?? 0,
    nextReview: json['nextReview'] != null ? DateTime.parse(json['nextReview']) : null,
    totalReviews: json['totalReviews'] ?? 0,
    correctReviews: json['correctReviews'] ?? 0,
  );
}

// ─── DECK MODEL ───
class Deck {
  final String id;
  String name;
  String description;
  String language;
  String emoji;
  List<Flashcard> cards;
  DateTime createdAt;

  Deck({
    String? id,
    required this.name,
    required this.description,
    required this.language,
    this.emoji = '📚',
    List<Flashcard>? cards,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       cards = cards ?? [],
       createdAt = createdAt ?? DateTime.now();

  int get totalCards => cards.length;
  int get dueToday => cards.where((c) => c.isDueToday).length;
  int get newCards => cards.where((c) => c.repetitions == 0).length;
  double get accuracy => cards.isEmpty ? 0 : cards.map((c) => c.accuracy).reduce((a, b) => a + b) / cards.length;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'language': language, 'emoji': emoji,
    'cards': cards.map((c) => c.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    language: json['language'],
    emoji: json['emoji'] ?? '📚',
    cards: (json['cards'] as List).map((c) => Flashcard.fromJson(c)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// ─── APP STATE MODEL ───
class AppState {
  String playerName;
  int streak;
  DateTime? lastStudyDate;
  int totalXP;
  int level;
  List<Deck> decks;
  int dailyGoalCards;
  int cardsStudiedToday;

  AppState({
    this.playerName = 'PLAYER_1',
    this.streak = 0,
    this.lastStudyDate,
    this.totalXP = 0,
    this.level = 1,
    List<Deck>? decks,
    this.dailyGoalCards = 20,
    this.cardsStudiedToday = 0,
  }) : decks = decks ?? [];

  int get totalCards => decks.fold(0, (sum, d) => sum + d.totalCards);
  int get totalDue => decks.fold(0, (sum, d) => sum + d.dueToday);

  void addXP(int xp) {
    totalXP += xp;
    level = (totalXP / 500).floor() + 1;
  }

  void updateStreak() {
    final now = DateTime.now();
    if (lastStudyDate == null) {
      streak = 1;
    } else {
      final diff = now.difference(lastStudyDate!).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
    }
    lastStudyDate = now;
  }

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'streak': streak,
    'lastStudyDate': lastStudyDate?.toIso8601String(),
    'totalXP': totalXP,
    'level': level,
    'decks': decks.map((d) => d.toJson()).toList(),
    'dailyGoalCards': dailyGoalCards,
    'cardsStudiedToday': cardsStudiedToday,
  };

  factory AppState.fromJson(Map<String, dynamic> json) => AppState(
    playerName: json['playerName'] ?? 'PLAYER_1',
    streak: json['streak'] ?? 0,
    lastStudyDate: json['lastStudyDate'] != null ? DateTime.parse(json['lastStudyDate']) : null,
    totalXP: json['totalXP'] ?? 0,
    level: json['level'] ?? 1,
    decks: json['decks'] != null ? (json['decks'] as List).map((d) => Deck.fromJson(d)).toList() : [],
    dailyGoalCards: json['dailyGoalCards'] ?? 20,
    cardsStudiedToday: json['cardsStudiedToday'] ?? 0,
  );

  // Sample data for demo
  static AppState demo() {
    final englishCards = [
      Flashcard(front: 'Olá', back: 'Hello', language: 'Inglês', repetitions: 2, totalReviews: 5, correctReviews: 4),
      Flashcard(front: 'Adeus', back: 'Goodbye', language: 'Inglês', repetitions: 1, totalReviews: 3, correctReviews: 2),
      Flashcard(front: 'Obrigado', back: 'Thank you', language: 'Inglês', totalReviews: 0, correctReviews: 0),
      Flashcard(front: 'Por favor', back: 'Please', language: 'Inglês', totalReviews: 0, correctReviews: 0),
      Flashcard(front: 'Desculpe', back: 'Sorry', language: 'Inglês', repetitions: 3, totalReviews: 6, correctReviews: 5),
      Flashcard(front: 'Sim', back: 'Yes', language: 'Inglês', repetitions: 4, totalReviews: 8, correctReviews: 8),
      Flashcard(front: 'Não', back: 'No', language: 'Inglês', repetitions: 2, totalReviews: 4, correctReviews: 3),
      Flashcard(front: 'Água', back: 'Water', language: 'Inglês', totalReviews: 0, correctReviews: 0),
      Flashcard(front: 'Comida', back: 'Food', language: 'Inglês', repetitions: 1, totalReviews: 2, correctReviews: 2),
      Flashcard(front: 'Casa', back: 'House', language: 'Inglês', totalReviews: 0, correctReviews: 0),
    ];

    final japaneseCards = [
      Flashcard(front: 'Olá', back: 'こんにちは', language: 'Japonês', repetitions: 1, totalReviews: 4, correctReviews: 3),
      Flashcard(front: 'Obrigado', back: 'ありがとう', language: 'Japonês', totalReviews: 0, correctReviews: 0),
      Flashcard(front: 'Sim', back: 'はい', language: 'Japonês', repetitions: 2, totalReviews: 5, correctReviews: 4),
      Flashcard(front: 'Não', back: 'いいえ', language: 'Japonês', totalReviews: 0, correctReviews: 0),
      Flashcard(front: 'Água', back: '水', language: 'Japonês', repetitions: 1, totalReviews: 3, correctReviews: 2),
    ];

    final spanishCards = [
      Flashcard(front: 'Olá', back: 'Hola', language: 'Espanhol', repetitions: 3, totalReviews: 7, correctReviews: 6),
      Flashcard(front: 'Obrigado', back: 'Gracias', language: 'Espanhol', repetitions: 2, totalReviews: 5, correctReviews: 4),
      Flashcard(front: 'Por favor', back: 'Por favor', language: 'Espanhol', totalReviews: 0, correctReviews: 0),
      Flashcard(front: 'Amor', back: 'Amor', language: 'Espanhol', repetitions: 1, totalReviews: 3, correctReviews: 3),
      Flashcard(front: 'Trabalho', back: 'Trabajo', language: 'Espanhol', totalReviews: 0, correctReviews: 0),
    ];

    return AppState(
      playerName: 'PLAYER_1',
      streak: 7,
      totalXP: 1250,
      level: 3,
      cardsStudiedToday: 12,
      dailyGoalCards: 20,
      decks: [
        Deck(name: 'Inglês — Básico', description: 'Palavras essenciais', language: 'Inglês', emoji: '🇺🇸', cards: englishCards),
        Deck(name: 'Japonês — Iniciante', description: 'Hiragana e frases', language: 'Japonês', emoji: '🇯🇵', cards: japaneseCards),
        Deck(name: 'Espanhol — Conversação', description: 'Frases do dia a dia', language: 'Espanhol', emoji: '🇪🇸', cards: spanishCards),
      ],
    );
  }
}

// ─── STUDY SESSION ───
class StudySession {
  final Deck deck;
  final List<Flashcard> queue;
  int currentIndex;
  bool isFlipped;
  int correct;
  int wrong;
  int skipped;
  final DateTime startTime;

  StudySession({required this.deck})
      : queue = deck.cards.where((c) => c.isDueToday).toList()..shuffle(),
        currentIndex = 0,
        isFlipped = false,
        correct = 0,
        wrong = 0,
        skipped = 0,
        startTime = DateTime.now();

  Flashcard? get current => currentIndex < queue.length ? queue[currentIndex] : null;
  bool get isComplete => currentIndex >= queue.length;
  int get total => queue.length;
  double get progress => total > 0 ? currentIndex / total : 0;

  void flip() { isFlipped = true; }

  void rate(int rating) {
    if (current == null) return;
    current!.rate(rating);
    if (rating >= 3) correct++; else wrong++;
    currentIndex++;
    isFlipped = false;
  }
}
