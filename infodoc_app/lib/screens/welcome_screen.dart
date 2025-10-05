import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _logoController;
  late AnimationController _buttonController;
  late AnimationController _blurController;
  late AnimationController _carouselController;
  int _currentPage = 0;

  final List<OnboardingCard> _onboardingCards = [
    OnboardingCard(
      icon: Icons.verified_user,
      title: "Verify Before You Trust",
      description: "Get instant fact-checking for any content you encounter",
      color: Colors.blue,
    ),
    OnboardingCard(
      icon: Icons.camera_alt,
      title: "Multiple Input Types",
      description: "Upload images, videos, text, or audio for verification",
      color: Colors.green,
    ),
    OnboardingCard(
      icon: Icons.speed,
      title: "Lightning Fast",
      description: "Get results in seconds with our advanced AI technology",
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 3000), () {
      _blurController.forward();
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      _carouselController.forward();
    });
    Future.delayed(const Duration(milliseconds: 4000), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoController.dispose();
    _buttonController.dispose();
    _blurController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Main content with logo and title
              SafeArea(
                child: SizedBox.expand(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with checkmark - Enhanced animations
                      GlassCard(
                            width: 120,
                            height: 120,
                            isCircular: true,
                            backgroundColor: Colors.white,
                            opacity: 0.3,
                            child: Icon(
                              Icons.verified_user,
                              size: 60,
                              color: Colors.white,
                            ),
                          )
                          .animate(controller: _logoController)
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 800.ms)
                          .then()
                          .shimmer(
                            duration: 2000.ms,
                            color: Colors.white.withOpacity(0.3),
                          )
                          .then()
                          .rotate(duration: 1000.ms, curve: Curves.easeInOut),

                      const SizedBox(height: 30),

                      // App name - Enhanced animations
                      Text(
                            "InfoDoc",
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          )
                          .animate(controller: _logoController)
                          .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack)
                          .fadeIn(delay: 300.ms)
                          .then()
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withOpacity(0.3),
                          )
                          .then()
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 500.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.05, 1.05),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                            "Verify Before You Trust",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                          .animate(controller: _logoController)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          )
                          .fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),

              // iOS-like blur overlay
              AnimatedBuilder(
                animation: _blurController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 15 * _blurController.value,
                        sigmaY: 15 * _blurController.value,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(
                          0.4 * _blurController.value,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Carousel sliding from bottom - occupies half screen
              AnimatedBuilder(
                animation: _carouselController,
                builder: (context, child) {
                  return Positioned(
                    bottom:
                        -MediaQuery.of(context).size.height *
                        0.5 *
                        (1 - _carouselController.value),
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Handle bar
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Page indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _onboardingCards.length,
                              (index) =>
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: _currentPage == index ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentPage == index
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ).animate().scale(
                                    duration: 300.ms,
                                    curve: Curves.easeInOut,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // PageView content
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: _onboardingCards.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 800),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        child: _onboardingCards[index],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Dynamic button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child:
                                GlassButton(
                                      width: double.infinity,
                                      height: 70, // Increased height
                                      backgroundColor: Colors.white,
                                      opacity: 0.3,
                                      onTap: () {
                                        if (_currentPage ==
                                            _onboardingCards.length - 1) {
                                          // Last page - navigate to home screen
                                          Navigator.of(context).pushReplacement(
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) => HomeScreen(),
                                              transitionsBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SlideTransition(
                                                        position:
                                                            Tween<Offset>(
                                                              begin:
                                                                  const Offset(
                                                                    0,
                                                                    1,
                                                                  ),
                                                              end: Offset.zero,
                                                            ).animate(
                                                              CurvedAnimation(
                                                                parent:
                                                                    animation,
                                                                curve: Curves
                                                                    .easeInOutCubic,
                                                              ),
                                                            ),
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 800,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          // Not last page - go to next page
                                          _pageController.nextPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      child: Text(
                                        _currentPage ==
                                                _onboardingCards.length - 1
                                            ? "Start Verifying"
                                            : "Next",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    )
                                    .animate(controller: _buttonController)
                                    .slideY(
                                      begin: 0.5,
                                      end: 0,
                                      curve: Curves.easeOutBack,
                                    )
                                    .fadeIn(delay: 200.ms)
                                    .shimmer(
                                      duration: 2000.ms,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                          ),
                        ],
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
}

class OnboardingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
