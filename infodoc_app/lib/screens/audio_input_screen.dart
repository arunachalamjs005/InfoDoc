import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../models/input_type.dart';
import '../services/audio_transcription_service.dart';
import 'loading_screen.dart';

class AudioInputScreen extends StatefulWidget {
  const AudioInputScreen({super.key});

  @override
  State<AudioInputScreen> createState() => _AudioInputScreenState();
}

class _AudioInputScreenState extends State<AudioInputScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  
  bool _isListening = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcribedText = '';
  double _confidence = 0.0;
  bool _available = false;
  String? _recordedAudioPath;
  bool _recorderInitialized = false;
  
  // Mode: 'record' or 'upload'
  String _selectedMode = 'record';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initRecorder();
  }
  
  Future<void> _initRecorder() async {
    try {
      await _audioRecorder.openRecorder();
      setState(() => _recorderInitialized = true);
    } catch (e) {
      print('Failed to initialize recorder: $e');
    }
  }
  
  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (s) {
        // debug
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech error: ${e.errorMsg}')),
        );
      },
    );
    if (mounted) setState(() => _available = available);
  }

  Future<void> _startRecording() async {
    // Request microphone permission first
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required to record.')),
      );
      return;
    }

    if (!_recorderInitialized) {
      await _initRecorder();
    }

    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      
      // Start recording
      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      
      setState(() {
        _isRecording = true;
        _recordedAudioPath = path;
        _transcribedText = '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      
      setState(() {
        _isRecording = false;
      });
      
      if (_recordedAudioPath != null) {
        await _transcribeRecordedAudio(_recordedAudioPath!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }
  
  Future<void> _transcribeRecordedAudio(String audioPath) async {
    setState(() => _isProcessing = true);
    
    try {
      final transcription = await AudioTranscriptionService.transcribeAudioFile(audioPath);
      
      if (!mounted) return;
      
      if (transcription != null && transcription.isNotEmpty) {
        setState(() {
          _transcribedText = transcription;
          _confidence = 0.85; // Estimated confidence
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio transcribed successfully!')),
        );
      } else {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No speech detected in audio')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription failed: $e')),
      );
    }
  }

  void _proceed() {
    if (_transcribedText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No speech captured. Please try again.')),
      );
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, a, b) => LoadingScreen(
          inputType: InputType.audio,
          // pass the already extracted text, so loading screen can skip OCR
          preExtractedText: _transcribedText.trim(),
        ),
        transitionsBuilder: (c, a, sA, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      // Request storage permission
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to pick audio files.')),
        );
        return;
      }

      // Pick audio file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final audioPath = result.files.single.path!;
        
        setState(() {
          _recordedAudioPath = audioPath;
          _transcribedText = '';
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transcribing audio file...')),
        );
        
        await _transcribeRecordedAudio(audioPath);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick audio file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Audio Input',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mode selection tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        backgroundColor: _selectedMode == 'record' ? Colors.blue : Colors.white,
                        opacity: _selectedMode == 'record' ? 0.35 : 0.15,
                        onTap: () => setState(() => _selectedMode = 'record'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Record',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        backgroundColor: _selectedMode == 'upload' ? Colors.blue : Colors.white,
                        opacity: _selectedMode == 'upload' ? 0.35 : 0.15,
                        onTap: () => setState(() => _selectedMode = 'upload'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Upload',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action button based on selected mode
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _selectedMode == 'record'
                    ? GlassButton(
                        backgroundColor: _isRecording ? Colors.red : Colors.green,
                        opacity: 0.3,
                        onTap: _isProcessing ? null : (_isRecording ? _stopRecording : _startRecording),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isProcessing)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              else
                                Icon(
                                  _isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              const SizedBox(width: 12),
                              Text(
                                _isProcessing
                                    ? 'Transcribing...'
                                    : _isRecording
                                        ? 'Stop Recording'
                                        : 'Start Recording',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GlassButton(
                        backgroundColor: Colors.purple,
                        opacity: 0.3,
                        onTap: _isProcessing ? null : _pickAudioFile,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isProcessing)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              else
                                const Icon(Icons.folder_open, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                _isProcessing ? 'Transcribing...' : 'Pick Audio File',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    opacity: 0.15,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Transcription Preview',
                                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              if (_isRecording)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Recording',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _transcribedText.isEmpty
                                ? (_selectedMode == 'record'
                                    ? 'Record audio to see transcription here...'
                                    : 'Upload an audio file to see transcription here...')
                                : _transcribedText,
                            style: TextStyle(
                              color: _transcribedText.isEmpty ? Colors.white54 : Colors.white,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_confidence > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          if (_recordedAudioPath != null && _transcribedText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.audio_file, color: Colors.blue, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _recordedAudioPath!.split('/').last,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: GlassButton(
                  backgroundColor: Colors.white,
                  opacity: 0.25,
                  onTap: _proceed,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Proceed', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
