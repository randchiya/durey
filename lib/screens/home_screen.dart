import 'package:flutter/material.dart';
import 'package:durey/services/question_service.dart';
import 'package:durey/screens/question_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuestionService _service = QuestionService();
  
  // Available categories
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'هەموو',
      'icon': Icons.grid_view_outlined,
      'color': const Color(0xFFFFD700),
      'gradient': [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      'english': 'All',
    },
    {
      'name': 'ژیان',
      'icon': Icons.spa_outlined,
      'color': const Color(0xFF66BB6A),
      'gradient': [const Color(0xFF66BB6A), const Color(0xFF388E3C)],
      'english': 'Life',
    },
    {
      'name': 'گشتی',
      'icon': Icons.language_outlined,
      'color': const Color(0xFF42A5F5),
      'gradient': [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
      'english': 'General',
    },
    {
      'name': 'تەکنەلۆژیا',
      'icon': Icons.devices_outlined,
      'color': const Color(0xFFAB47BC),
      'gradient': [const Color(0xFFAB47BC), const Color(0xFF7B1FA2)],
      'english': 'Technology',
    },
    {
      'name': 'پەیوەندی',
      'icon': Icons.favorite_border_outlined,
      'color': const Color(0xFFEF5350),
      'gradient': [const Color(0xFFEF5350), const Color(0xFFD32F2F)],
      'english': 'Relationship',
    },
    {
      'name': 'بەهرە',
      'icon': Icons.auto_awesome_outlined,
      'color': const Color(0xFFFFA726),
      'gradient': [const Color(0xFFFFA726), const Color(0xFFF57C00)],
      'english': 'Talent',
    },
  ];

  void _selectCategory(String category) async {
    // Find the English name for database query
    final categoryData = _categories.firstWhere(
      (cat) => cat['name'] == category,
      orElse: () => {'english': category},
    );
    final englishName = categoryData['english'] ?? category;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF0F0F0F).withValues(alpha: 0.95),
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
              ),
              const SizedBox(height: 20),
              Text(
                'پرسیار دەهێنرێت...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Fetch question from selected category
      final question = englishName == 'All'
          ? await _service.fetchRandomQuestion()
          : await _service.fetchQuestionByCategory(englishName);
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (question == null) {
        // No questions in this category
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('هیچ پرسیارێک نییە لە $category'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Navigate directly to voting screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuestionScreen(question: question),
        ),
      );

      // After voting, reset to category selection
      if (mounted) {
        // If vote was successful, optionally show another question from same category
        if (result == true) {
          _selectCategory(category);
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('هەڵە لە هێنانی پرسیار: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: _buildCategorySelection(),
    );
  }

  Widget _buildCategorySelection() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgrounds/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Category List with Logo and Subtitle inside
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 40),
                    // Logo Section
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          // Logo image
                          Image.asset(
                            'assets/images/logos/logo1.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          // Subtitle - lower opacity
                          Text(
                            'جۆری پرسیارەکان هەڵبژێرە',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Decorative line - lower opacity
                          Container(
                            width: 80,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Categories
                    ..._categories.map((category) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildCategoryCard(category),
                    )),
                    const SizedBox(height: 20),
                    
                    // Version and Credits - scrollable at bottom
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'V1.0',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.3),
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'by ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.25),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'K',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFED1C24).withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFDB913).withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'D',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF00A650).withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Banner Ad Placeholder - adaptive height (60-90dp)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate adaptive banner height based on screen width
                  // Increased for phones but capped at 90dp
                  final screenWidth = constraints.maxWidth;
                  double bannerHeight = 70.0; // Increased default for phones
                  
                  if (screenWidth >= 728) {
                    bannerHeight = 90.0; // Tablets (max)
                  } else if (screenWidth >= 468) {
                    bannerHeight = 80.0; // Large phones
                  }
                  
                  return Container(
                    width: double.infinity,
                    height: bannerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '#ad',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _selectCategory(category['name']),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: category['color'].withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: category['color'].withValues(alpha: 0.2),
            highlightColor: category['color'].withValues(alpha: 0.1),
            onTap: () => _selectCategory(category['name']),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Accent line (left side)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: category['gradient'],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category name (RTL text)
                  Expanded(
                    child: Text(
                      category['name'],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Icon with gradient background (right side)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: category['gradient'],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: category['color'].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      category['icon'],
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
