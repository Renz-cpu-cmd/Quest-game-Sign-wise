import 'dart:math';

/// ASL Sign data model
/// Fetches sign images from online repository
class AslSign {
  final String letter;

  const AslSign(this.letter);

  /// Get the asset path for the ASL sign GIF image
  String get assetPath => 'assets/images/asl/${letter.toLowerCase()}.gif';

  // Removed _getASLImageUrl as we now use local assets

  /// All available ASL signs (A-Z)
  static const List<AslSign> allSigns = [
    AslSign('A'),
    AslSign('B'),
    AslSign('C'),
    AslSign('D'),
    AslSign('E'),
    AslSign('F'),
    AslSign('G'),
    AslSign('H'),
    AslSign('I'),
    AslSign('J'),
    AslSign('K'),
    AslSign('L'),
    AslSign('M'),
    AslSign('N'),
    AslSign('O'),
    AslSign('P'),
    AslSign('Q'),
    AslSign('R'),
    AslSign('S'),
    AslSign('T'),
    AslSign('U'),
    AslSign('V'),
    AslSign('W'),
    AslSign('X'),
    AslSign('Y'),
    AslSign('Z'),
  ];

  /// Get a random ASL sign
  static AslSign random() {
    final random = Random();
    return allSigns[random.nextInt(allSigns.length)];
  }

  /// Get distractor letters (wrong answers) for a quiz
  /// Returns [count] unique letters that are different from [correctLetter]
  static List<String> getDistractors(String correctLetter, int count) {
    final random = Random();
    final availableLetters = allSigns
        .map((sign) => sign.letter)
        .where((letter) => letter != correctLetter.toUpperCase())
        .toList();

    availableLetters.shuffle(random);
    return availableLetters.take(count).toList();
  }

  /// Generate a complete quiz with correct answer and distractors
  /// Returns a shuffled list of 4 letters including the correct one
  static List<String> generateQuizChoices(String correctLetter) {
    final distractors = getDistractors(correctLetter, 3);
    final choices = [correctLetter.toUpperCase(), ...distractors];
    choices.shuffle(Random());
    return choices;
  }

  @override
  String toString() => 'AslSign($letter)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AslSign &&
          runtimeType == other.runtimeType &&
          letter == other.letter;

  @override
  int get hashCode => letter.hashCode;
}
