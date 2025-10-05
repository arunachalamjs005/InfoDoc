import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  /// Extract text from an image using Google ML Kit
  /// 
  /// [imagePath] - Path to the image file
  /// Returns extracted text as a String
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      
      String extractedText = recognizedText.text.trim();

      if (extractedText.isEmpty) {
        return "No text detected in the image.";
      }

      return extractedText;
    } catch (e) {
      print('OCR Error: $e');
      return "Error extracting text. Please try with a clearer image.";
    }
  }

  /// Extract text with progress callback
  /// 
  /// [imagePath] - Path to the image file
  /// [onProgress] - Callback function to report progress
  /// Returns extracted text as a String
  static Future<String> extractTextWithProgress(
    String imagePath,
    Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call("Initializing OCR...");
      
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      onProgress?.call("Processing image...");
      
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      onProgress?.call("Finalizing...");
      
      await textRecognizer.close();
      
      String extractedText = recognizedText.text.trim();

      if (extractedText.isEmpty) {
        return "No text detected in the image.";
      }

      return extractedText;
    } catch (e) {
      print('OCR Error: $e');
      onProgress?.call("Error occurred");
      return "Error extracting text. Please try with a clearer image.";
    }
  }
}
