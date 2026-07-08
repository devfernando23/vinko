import 'dart:convert';

/// Perfil del niño, persistido en shared_preferences.
class ChildProfile {
  const ChildProfile({
    required this.name,
    required this.age,
    this.challenges = const [],
  });

  final String name;
  final int age;

  /// Ids de situaciones que más le cuestan (elegidas en onboarding).
  final List<String> challenges;

  ChildProfile copyWith({String? name, int? age, List<String>? challenges}) =>
      ChildProfile(
        name: name ?? this.name,
        age: age ?? this.age,
        challenges: challenges ?? this.challenges,
      );

  Map<String, dynamic> toMap() =>
      {'name': name, 'age': age, 'challenges': challenges};

  static ChildProfile? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ChildProfile(
      name: map['name'] as String,
      age: map['age'] as int,
      challenges:
          (map['challenges'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  String toJson() => jsonEncode(toMap());
}
