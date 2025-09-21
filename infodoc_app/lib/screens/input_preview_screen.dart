import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';
import '../models/input_type.dart';
import 'loading_screen.dart';

class InputPreviewScreen extends StatefulWidget {
  final InputType inputType;

  const InputPreviewScreen({super.key, required this.inputType});

  @override
  State<InputPreviewScreen> createState() => _InputPreviewScreenState();
}

class _InputPreviewScreenState extends State<InputPreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _previewController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _previewController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _previewController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _proceedToVerification() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoadingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
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
  }

  Widget _buildPreviewContent() {
    switch (widget.inputType) {
      case InputType.camera:
        return _buildImagePreview();
      case InputType.audio:
        return _buildAudioPreview();
      case InputType.text:
        return _buildTextPreview();
      case InputType.video:
        return _buildVideoPreview();
      case InputType.upload:
        return _buildUploadPreview();
    }
  }

  Widget _buildImagePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.asset(
              'assets/template_1.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Image Captured",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap to retake or proceed to verify",
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildAudioPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Audio waveform visualization
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (index) {
            return Container(
                  width: 3,
                  height: 20 + (index % 3) * 10,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
                .animate(delay: (index * 50).ms)
                .scaleY(duration: 1000.ms, curve: Curves.easeInOut);
          }),
        ),
        const SizedBox(height: 30),
        Icon(Icons.mic, size: 60, color: Colors.white.withOpacity(0.8)),
        const SizedBox(height: 20),
        Text(
          "Audio Recorded",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Duration: 0:15",
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildTextPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.text_fields,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              "Text Input",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              "This is a sample text that would be entered by the user for verification. The text can be of any length and will be analyzed for factual accuracy...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Stack(
      children: [
        // Video thumbnail placeholder
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_filled,
                size: 80,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 20),
              Text(
                "Video Recorded",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Duration: 0:30",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // Play button overlay
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.asset(
              'assets/template_2.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "File Uploaded",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Ready for verification",
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
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
                        "Preview ${widget.inputType.name.toUpperCase()}",
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

              // Preview content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child:
                      GlassCard(
                            backgroundColor: Colors.white,
                            opacity: 0.1,
                            child: Container(
                              height: 320,
                              child: _buildPreviewContent(),
                            ),
                          )
                          .animate(controller: _previewController)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(duration: 600.ms),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child:
                    Row(
                          children: [
                            Expanded(
                              child: GlassButton(
                                backgroundColor: Colors.white,
                                opacity: 0.2,
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  "Retake",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: GlassButton(
                                backgroundColor: Colors.green,
                                opacity: 0.3,
                                onTap: _proceedToVerification,
                                child: Text(
                                  "Proceed",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate(controller: _buttonController)
                        .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack)
                        .fadeIn(delay: 200.ms),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
