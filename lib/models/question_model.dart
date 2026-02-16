/// Question model for DuRey game
class QuestionModel {
  final String id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String category;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.category,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      questionText: json['question_text'] as String,
      optionA: json['option_a'] as String,
      optionB: json['option_b'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'category': category,
    };
  }
}
