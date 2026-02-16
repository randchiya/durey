import 'package:flutter/material.dart';
import 'package:durey/screens/home_screen.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    
    // Setup rotation animation for dots
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
    
    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for animation and initialization
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.92),
                Colors.black.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100, left: 15),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // KGD Studio Logo
                          Image.asset(
                            'assets/images/studio/kgd.png',
                            height: 320,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 40),
                        
                          // Wave bars loading animation
                          SizedBox(
                            width: 70,
                            height: 50,
                            child: AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _WaveBarsLoader(
                                    progress: _rotationController.value,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for wave bars loader
class _WaveBarsLoader extends CustomPainter {
  final double progress;
  
  _WaveBarsLoader({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 5.0; // Thinner bars
    final spacing = 12.0; // More spacing
    final maxHeight = size.height;
    final minHeight = 8.0; // Minimum bar height
    final centerY = size.height / 2;
    
    // Three bars with KGD colors
    final bars = [
      const Color(0xFFED1C24), // Red (K)
      const Color(0xFFFDB913), // Yellow (G)
      const Color(0xFF00A650), // Green (D)
    ];
    
    for (int i = 0; i < 3; i++) {
      final x = (size.width / 2) - (barWidth * 1.5 + spacing) + (i * (barWidth + spacing));
      
      // Calculate wave height with phase offset and easing
      // Negative phase offset makes wave flow left to right
      final phase = (progress * 2 * pi) - (i * pi / 2.5);
      final easedProgress = Curves.easeInOutSine.transform((sin(phase) * 0.5 + 0.5));
      final barHeight = minHeight + (easedProgress * (maxHeight - minHeight));
      
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          centerY - barHeight / 2,
          barWidth,
          barHeight,
        ),
        const Radius.circular(2.5),
      );
      
      // Draw subtle outer glow
      final outerGlowPaint = Paint()
        ..color = bars[i].withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - 2,
            centerY - barHeight / 2 - 2,
            barWidth + 4,
            barHeight + 4,
          ),
          const Radius.circular(4),
        ),
        outerGlowPaint,
      );
      
      // Draw inner glow
      final innerGlowPaint = Paint()
        ..color = bars[i].withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(barRect, innerGlowPaint);
      
      // Draw bar with refined gradient
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bars[i].withValues(alpha: 0.7),
            bars[i].withValues(alpha: 0.95),
            bars[i],
            bars[i].withValues(alpha: 0.95),
            bars[i].withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        ).createShader(barRect.outerRect);
      canvas.drawRRect(barRect, barPaint);
      
      // Draw subtle edge highlight
      final edgePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRRect(barRect, edgePaint);
      
      // Draw refined highlight
      final highlightRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + 1,
          centerY - barHeight / 2 + 4,
          1.5,
          barHeight * 0.25,
        ),
        const Radius.circular(1),
      );
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(highlightRect.outerRect);
      canvas.drawRRect(highlightRect, highlightPaint);
      
      // Draw reflection at bottom
      final reflectionRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + 1,
          centerY + barHeight / 2 - (barHeight * 0.15),
          1.5,
          barHeight * 0.1,
        ),
        const Radius.circular(1),
      );
      final reflectionPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1);
      canvas.drawRRect(reflectionRect, reflectionPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
