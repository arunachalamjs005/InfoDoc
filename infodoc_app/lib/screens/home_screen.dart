import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';
import '../models/input_type.dart';
import 'input_preview_screen.dart';
import 'text_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _menuController;
  late AnimationController _historyController;
  late AnimationController _plusButtonController;
  bool _isMenuOpen = false;

  List<InputOption> get _inputOptions => [
    InputOption(
      icon: Icons.keyboard,
      label: "Text",
      color: Colors.blue,
      onTap: () => _navigateToInput(InputType.text),
    ),
    InputOption(
      icon: Icons.camera_alt,
      label: "Camera",
      color: Colors.green,
      onTap: () => _navigateToInput(InputType.camera),
    ),
    InputOption(
      icon: Icons.mic,
      label: "Audio",
      color: Colors.orange,
      onTap: () => _navigateToInput(InputType.audio),
    ),
    InputOption(
      icon: Icons.upload_file,
      label: "Upload",
      color: Colors.purple,
      onTap: () => _navigateToInput(InputType.upload),
    ),
  ];

  final List<HistoryItem> _recentHistory = [
    HistoryItem(
      title: "Climate Change Art...",
      type: "Text",
      result: "Verified",
      time: "2 hours ago",
      color: Colors.green,
    ),
    HistoryItem(
      title: "Viral Video Check",
      type: "Video",
      result: "Misleading",
      time: "1 day ago",
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _historyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _plusButtonController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _historyController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _plusButtonController.forward();
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    _historyController.dispose();
    _plusButtonController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  Future<bool> _requestPermissions(InputType type) async {
    if (type == InputType.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else if (type == InputType.upload) {
      // Request storage permissions
      if (await Permission.photos.isGranted) {
        return true;
      }
      
      final status = await Permission.photos.request();
      if (status.isGranted) {
        return true;
      }
      
      // Fallback to storage permission for older Android versions
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    return true;
  }

  void _navigateToInput(InputType type) async {
    _toggleMenu();
    Future.delayed(const Duration(milliseconds: 300), () async {
      Widget destination;

      switch (type) {
        case InputType.text:
          destination = const TextInputScreen();
          break;
        case InputType.camera:
          // Request camera permission
          if (!await _requestPermissions(InputType.camera)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Camera permission is required'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          
          // Pick image from camera
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          );
          if (pickedFile != null) {
            // Pass the image to your preview screen or handle as needed
            destination = InputPreviewScreen(
              inputType: type,
              imagePath: pickedFile.path,
            );
          } else {
            // User cancelled, do nothing or show a message
            return;
          }
          break;
        case InputType.upload:
          // Request storage permission
          if (!await _requestPermissions(InputType.upload)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Storage permission is required'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          
          // Pick image from gallery using ImagePicker (more reliable)
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
          
          if (pickedFile != null) {
            destination = InputPreviewScreen(
              inputType: type,
              imagePath: pickedFile.path,
            );
          } else {
            // User cancelled
            return;
          }
          break;
        case InputType.audio:
        case InputType.video:
          destination = InputPreviewScreen(inputType: type);
          break;
      }

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "InfoDoc",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "Verify Before You Trust",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    GlassButton(
                      width: 50,
                      height: 50,
                      isCircular: true,
                      backgroundColor: Colors.white,
                      opacity: 0.2,
                      onTap: () {
                        // Profile or settings
                      },
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Central floating button and radial menu
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radial menu options
                          ...List.generate(_inputOptions.length, (index) {
                            final angle = (index * 90.0) * (3.14159 / 180);
                            final radius = 140.0;

                            return AnimatedBuilder(
                              animation: _menuController,
                              builder: (context, child) {
                                final animationValue = Curves.easeOutBack
                                    .transform(_menuController.value);
                                final offset = Offset(
                                  math.cos(angle) * radius * animationValue,
                                  math.sin(angle) * radius * animationValue,
                                );

                                return Transform.translate(
                                  offset: offset,
                                  child: Transform.scale(
                                    scale: animationValue.clamp(0.0, 1.0).toDouble(),
                                    child: Opacity(
                                      opacity: animationValue.clamp(0.0, 1.0).toDouble(),
                                      child: _inputOptions[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                          // Central floating button - Enhanced Design
                          GestureDetector(
                                onTap: _toggleMenu,
                                child: AnimatedBuilder(
                                  animation: _menuController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _menuController.value * 0.5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.blue.withOpacity(0.8),
                                              Colors.blue.withOpacity(0.6),
                                              Colors.blue.withOpacity(0.4),
                                            ],
                                            stops: const [0.0, 0.7, 1.0],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(
                                                (0.4 +
                                                        (_menuController.value *
                                                            0.2))
                                                    .clamp(0.0, 1.0),
                                              ),
                                              blurRadius:
                                                  25 +
                                                  (_menuController.value * 15),
                                              spreadRadius:
                                                  3 +
                                                  (_menuController.value * 4),
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 40,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 60,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.1),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.4,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            transitionBuilder:
                                                (child, animation) {
                                                  return ScaleTransition(
                                                    scale: animation,
                                                    child: child,
                                                  );
                                                },
                                            child: Container(
                                              key: ValueKey(_isMenuOpen),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _isMenuOpen
                                                    ? Colors.red.withOpacity(
                                                        0.8,
                                                      )
                                                    : Colors.white.withOpacity(
                                                        0.9,
                                                      ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _isMenuOpen
                                                    ? Icons.close
                                                    : Icons.add,
                                                size: 48,
                                                color: _isMenuOpen
                                                    ? Colors.white
                                                    : Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    );
                                  },
                                ),
                              )
                              .animate(controller: _plusButtonController)
                              .scale(
                                begin: const Offset(0, 0),
                                end: const Offset(1, 1),
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(duration: 800.ms)
                              .then()
                              .fadeIn(
                                duration: 1000.ms,
                                curve: Curves.easeInOut,
                              ),
                        ],
                      ),
                    ),
                  ],
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

class InputOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const InputOption({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        // HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: GlassCard(
          width: 110, // Increased from 80
          height: 110, // Increased from 80
          isCircular: true,
          backgroundColor: color,
          opacity: 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 36), // Optionally increase icon size
              const SizedBox(height: 8), // Optionally increase spacing
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14, // Optionally increase font size
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .scale(duration: 150.ms, curve: Curves.easeInOut)
    .then()
    .fadeIn(duration: 300.ms, curve: Curves.easeInOut);
  }
}

class HistoryItem extends StatelessWidget {
  final String title;
  final String type;
  final String result;
  final String time;
  final Color color;

  const HistoryItem({
    super.key,
    required this.title,
    required this.type,
    required this.result,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: color,
      opacity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            type,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                result,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
