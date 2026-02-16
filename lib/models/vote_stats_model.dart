/// Vote statistics model for DuRey game
class VoteStatsModel {
  final String questionId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String category;
  final int totalVotes;
  final int votesA;
  final int votesB;
  final double percentageA;
  final double percentageB;

  VoteStatsModel({
    required this.questionId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.category,
    required this.totalVotes,
    required this.votesA,
    required this.votesB,
    required this.percentageA,
    required this.percentageB,
  });

  factory VoteStatsModel.fromJson(Map<String, dynamic> json) {
    return VoteStatsModel(
      questionId: json['question_id'] as String,
      questionText: json['question_text'] as String,
      optionA: json['option_a'] as String,
      optionB: json['option_b'] as String,
      category: json['category'] as String,
      totalVotes: json['total_votes'] as int,
      votesA: json['votes_a'] as int,
      votesB: json['votes_b'] as int,
      percentageA: (json['percentage_a'] as num).toDouble(),
      percentageB: (json['percentage_b'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'category': category,
      'total_votes': totalVotes,
      'votes_a': votesA,
      'votes_b': votesB,
      'percentage_a': percentageA,
      'percentage_b': percentageB,
    };
  }

  /// Get the winning option ('A' or 'B')
  String get winningOption => votesA > votesB ? 'A' : 'B';

  /// Get the winning option text
  String get winningOptionText => votesA > votesB ? optionA : optionB;

  /// Check if the vote is close (within 10% difference)
  bool get isCloseVote => (percentageA - percentageB).abs() <= 10;
}
