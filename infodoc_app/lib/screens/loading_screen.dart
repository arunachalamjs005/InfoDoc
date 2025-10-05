import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';
import '../models/input_type.dart';
import '../services/ocr_service.dart';
import 'results_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String? imagePath;
  final InputType? inputType;

  const LoadingScreen({
    super.key,
    this.imagePath,
    this.inputType,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _progressController;
  String _statusText = "Initializing...";
  String? _extractedText;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _textController.forward();
    _progressController.forward();

    // Start OCR processing if image path is provided
    _processImage();
  }

  Future<void> _processImage() async {
    if (widget.imagePath != null && 
        (widget.inputType == InputType.camera || widget.inputType == InputType.upload)) {
      try {
        setState(() {
          _statusText = "Extracting text from image...";
        });

        // Perform OCR
        final extractedText = await OCRService.extractTextWithProgress(
          widget.imagePath!,
          (status) {
            if (mounted) {
              setState(() {
                _statusText = status;
              });
            }
          },
        );

        setState(() {
          _extractedText = extractedText;
          _statusText = "Text extraction complete!";
          _isProcessing = false;
        });

        // Wait a bit before navigating
        await Future.delayed(const Duration(milliseconds: 1500));

        // Navigate to results
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ResultsScreen(extractedText: _extractedText),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _statusText = "Error: ${e.toString()}";
          _isProcessing = false;
        });
      }
    } else {
      // No image to process, just show loading and navigate
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ResultsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GlassButton(
                      width: 50,
                      height: 50,
                      isCircular: true,
                      backgroundColor: Colors.white,
                      opacity: 0.2,
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Verifying Content",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main loading content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lottie loading animation
                      Container(
                            width: 300,
                            height: 300,
                            child: Lottie.asset(
                              'assets/animations/loading_animation.json',
                              fit: BoxFit.contain,
                              repeat: true,
                            ),
                          )
                          .animate(controller: _textController)
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 800.ms),

                      const SizedBox(height: 40),

                      // Loading text
                      Text(
                            "Analyzing your content...",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                          .animate(controller: _textController)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          )
                          .fadeIn(delay: 300.ms),

                      const SizedBox(height: 15),

                      Text(
                            _statusText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate(controller: _textController)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          )
                          .fadeIn(delay: 500.ms),

                      const SizedBox(height: 40),

                      // Progress bar
                      Container(
                            width: 250,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 250 * _progressController.value,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.purple,
                                          Colors.green,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          .animate(controller: _textController)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          )
                          .fadeIn(delay: 700.ms),

                      const SizedBox(height: 20),

                      // Progress percentage
                      AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return Text(
                                "${(_progressController.value * 100).toInt()}%",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                          .animate(controller: _textController)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          )
                          .fadeIn(delay: 900.ms),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
