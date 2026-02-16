import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:durey/models/question_model.dart';
import 'package:durey/services/device_service.dart';
import 'package:durey/services/question_service.dart';

class QuestionScreen extends StatefulWidget {
  final QuestionModel question;

  const QuestionScreen({
    super.key,
    required this.question,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool _isVoting = false;
  bool _showResults = false;
  String? _deviceId;
  String? _selectedOption;
  
  int _countA = 0;
  int _countB = 0;
  double _percentA = 0.0;
  double _percentB = 0.0;

  final QuestionService _questionService = QuestionService();

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final deviceId = await DeviceService.getDeviceId();
    setState(() {
      _deviceId = deviceId;
    });
  }

  Future<void> _vote(String option) async {
    if (_isVoting || _showResults) return;
    if (_deviceId == null) {
      _showSnackBar('Device ID not loaded', Colors.red);
      return;
    }

    setState(() {
      _isVoting = true;
      _selectedOption = option;
    });

    bool voteWasAlreadyCast = false;

    try {
      final supabase = Supabase.instance.client;

      // 1. Try to insert vote into Supabase
      await supabase.from('votes').insert({
        'question_id': widget.question.id,
        'device_id': _deviceId,
        'option_selected': option,
      });

      // Vote was successfully inserted (first time voting)
    } on PostgrestException catch (e) {
      // Check for duplicate vote error
      if (e.code == '23505' || e.message.contains('duplicate')) {
        // User already voted - this is OK, we'll still show results
        voteWasAlreadyCast = true;
      } else {
        // Other database error - show error and exit
        if (mounted) {
          _showSnackBar('Vote failed: ${e.message}', Colors.red);
          setState(() {
            _isVoting = false;
          });
        }
        return;
      }
    } catch (e) {
      // Unexpected error - show error and exit
      if (mounted) {
        _showSnackBar('Unexpected error occurred', Colors.red);
        setState(() {
          _isVoting = false;
        });
      }
      return;
    }

    // 2. Fetch real vote counts (whether vote was new or duplicate)
    try {
      final counts = await _questionService.fetchVoteCounts(widget.question.id);
      
      // 3. Calculate percentages
      _countA = counts['A'] ?? 0;
      _countB = counts['B'] ?? 0;
      final total = _countA + _countB;
      
      _percentA = total == 0 ? 0 : (_countA / total) * 100;
      _percentB = total == 0 ? 0 : (_countB / total) * 100;

      // 4. Show animated results overlay
      if (mounted) {
        setState(() {
          _isVoting = false;
          _showResults = true;
        });

        // Show message if vote was already cast
        if (voteWasAlreadyCast) {
          _showSnackBar('You already voted on this question', Colors.orange);
        }

        // 5. Auto-dismiss after 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      // Error fetching counts
      if (mounted) {
        _showSnackBar('Failed to load results', Colors.red);
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main split screen
          Column(
            children: [
              // TOP HALF - BLUE (Option A)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: (_isVoting || _showResults) ? null : () => _vote('A'),
                  child: Container(
                    color: const Color(0xFF1976D2),
                    width: double.infinity,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          widget.question.optionA,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // BOTTOM HALF - RED (Option B)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: (_isVoting || _showResults) ? null : () => _vote('B'),
                  child: Container(
                    color: const Color(0xFFD32F2F),
                    width: double.infinity,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          widget.question.optionB,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Question text overlay at center
          if (!_showResults)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.question.questionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Category badge at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.question.category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Animated Results Overlay
          if (_showResults)
            AnimatedOpacity(
              opacity: _showResults ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Results title
                      const Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Option A result
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedOption == 'A'
                                ? Colors.yellowAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.question.optionA,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: _percentA),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return Text(
                                  '${value.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_countA votes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // VS divider
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Option B result
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedOption == 'B'
                                ? Colors.yellowAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.question.optionB,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: _percentB),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return Text(
                                  '${value.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_countB votes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Loading next question indicator
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Loading next question...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading overlay (during vote submission)
          if (_isVoting && !_showResults)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
              onPressed: (_isVoting || _showResults)
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
            ),
          ),
        ],
      ),
    );
  }
}
