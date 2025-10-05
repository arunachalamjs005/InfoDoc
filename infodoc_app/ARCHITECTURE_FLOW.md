# InfoDoc OCR Architecture & Data Flow

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        InfoDoc App                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐      ┌──────────────┐                   │
│  │ Home Screen  │──────│ Input Preview│                   │
│  │              │      │   Screen     │                   │
│  └──────┬───────┘      └──────┬───────┘                   │
│         │                     │                            │
│         │ Camera/Upload       │ Image Path                 │
│         ▼                     ▼                            │
│  ┌──────────────────────────────────┐                     │
│  │      Loading Screen               │                     │
│  │  ┌─────────────────────────┐     │                     │
│  │  │   OCR Service           │     │                     │
│  │  │  (Tesseract OCR)        │     │                     │
│  │  └─────────────────────────┘     │                     │
│  └──────────────┬───────────────────┘                     │
│                 │ Extracted Text                           │
│                 ▼                                          │
│  ┌──────────────────────────────────┐                     │
│  │      Results Screen               │                     │
│  │  (Display Extracted Text)         │                     │
│  └──────────────────────────────────┘                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Diagram

### Camera Flow:
```
┌──────────────┐
│ User Action  │
│ Tap Camera   │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│  home_screen.dart    │
│  _navigateToInput()  │
│                      │
│  ImagePicker.        │
│  pickImage(camera)   │
└──────┬───────────────┘
       │ imagePath
       ▼
┌──────────────────────────┐
│ input_preview_screen.dart│
│                          │
│ Display actual image:    │
│ Image.file(imagePath)    │
└──────┬───────────────────┘
       │ User taps "Proceed"
       ▼
┌──────────────────────────┐
│  loading_screen.dart     │
│  _processImage()         │
│                          │
│  OCRService.             │
│  extractTextWithProgress │
│  (imagePath)             │
└──────┬───────────────────┘
       │ extractedText
       ▼
┌──────────────────────────┐
│  results_screen.dart     │
│                          │
│  Display in Claim:       │
│  widget.extractedText    │
└──────────────────────────┘
```

### Upload Flow:
```
┌──────────────┐
│ User Action  │
│ Tap Upload   │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│  home_screen.dart    │
│  _navigateToInput()  │
│                      │
│  FilePicker.         │
│  pickFiles(image)    │
└──────┬───────────────┘
       │ imagePath
       ▼
┌──────────────────────────┐
│ input_preview_screen.dart│
│                          │
│ Display actual image:    │
│ Image.file(imagePath)    │
└──────┬───────────────────┘
       │ User taps "Proceed"
       ▼
┌──────────────────────────┐
│  loading_screen.dart     │
│  _processImage()         │
│                          │
│  OCRService.             │
│  extractTextWithProgress │
│  (imagePath)             │
└──────┬───────────────────┘
       │ extractedText
       ▼
┌──────────────────────────┐
│  results_screen.dart     │
│                          │
│  Display in Claim:       │
│  widget.extractedText    │
└──────────────────────────┘
```

---

## 🔄 State Management Flow

```
┌─────────────────────────────────────────────────────────┐
│                    State Changes                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Home Screen                                            │
│  ├─ _isMenuOpen: bool                                  │
│  └─ Navigation → Input Preview                         │
│                                                         │
│  Input Preview Screen                                   │
│  ├─ imagePath: String?                                 │
│  ├─ inputType: InputType                               │
│  └─ Navigation → Loading Screen                        │
│                                                         │
│  Loading Screen                                         │
│  ├─ _statusText: String                                │
│  ├─ _extractedText: String?                            │
│  ├─ _isProcessing: bool                                │
│  └─ Navigation → Results Screen                        │
│                                                         │
│  Results Screen                                         │
│  ├─ extractedText: String?                             │
│  └─ _result: VerificationResult                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Component Interaction

```
┌──────────────────────────────────────────────────────────┐
│                  Component Diagram                       │
└──────────────────────────────────────────────────────────┘

┌─────────────────┐
│  HomeScreen     │
│                 │
│  Components:    │
│  • InputOption  │◄─── Radial menu with 4 options
│  • HistoryItem  │
│  • GlassButton  │
└────────┬────────┘
         │
         │ navigateToInput(InputType)
         ▼
┌─────────────────────────┐
│  InputPreviewScreen     │
│                         │
│  Components:            │
│  • _buildImagePreview() │◄─── Shows actual image
│  • _buildUploadPreview()│
│  • GlassButton (Proceed)│
└────────┬────────────────┘
         │
         │ proceedToVerification()
         ▼
┌─────────────────────────┐
│  LoadingScreen          │
│                         │
│  Components:            │
│  • Lottie Animation     │
│  • Progress Bar         │
│  • Status Text          │◄─── Dynamic OCR status
│                         │
│  Services:              │
│  • OCRService           │◄─── Tesseract OCR
└────────┬────────────────┘
         │
         │ extractedText
         ▼
┌─────────────────────────┐
│  ResultsScreen          │
│                         │
│  Components:            │
│  • Source Card          │
│  • Claim Card           │◄─── Shows extracted text
│  • Analysis Card        │
│  • References Card      │
│  • Verdict Card         │
└─────────────────────────┘
```

---

## 🗂️ Data Models

### InputType Enum
```dart
enum InputType {
  camera,   // Capture from camera
  audio,    // Record audio
  text,     // Text input
  video,    // Record video
  upload    // Upload from gallery
}
```

### VerificationResult Class
```dart
class VerificationResult {
  final String source;           // "InfoDoc OCR"
  final String sourceLogo;       // "📄"
  final String claim;            // ← Extracted text goes here
  final Verdict verdict;         // true_, false_, misleading
  final int confidence;          // 0-100
  final String explanation;      // OCR description
  final Color color;             // Result color
  final int probability;         // 0-100
  final String truthfulness;     // "High", "Medium", "Low"
  final List<String> trustworthyLinks;
  final String helplineNumber;
}
```

### Verdict Enum
```dart
enum Verdict {
  true_,
  false_,
  misleading
}
```

---

## 🔌 Service Layer

### OCR Service Architecture
```
┌──────────────────────────────────────────────┐
│           OCRService (Static)                │
├──────────────────────────────────────────────┤
│                                              │
│  extractTextFromImage(imagePath)             │
│  ├─ Input: String imagePath                 │
│  ├─ Process: Tesseract OCR                  │
│  ├─ Output: String extractedText            │
│  └─ Error: Returns error message            │
│                                              │
│  extractTextWithProgress(imagePath, callback)│
│  ├─ Input: String imagePath                 │
│  ├─ Input: Function(String) onProgress      │
│  ├─ Process: Tesseract OCR + callbacks      │
│  ├─ Output: String extractedText            │
│  └─ Callbacks: Progress updates             │
│                                              │
└──────────────────────────────────────────────┘
         │
         │ Uses
         ▼
┌──────────────────────────────────────────────┐
│      flutter_tesseract_ocr Package           │
├──────────────────────────────────────────────┤
│                                              │
│  FlutterTesseractOcr.extractText()           │
│  ├─ Language: 'eng'                          │
│  ├─ PSM: "4" (single column)                │
│  └─ preserve_interword_spaces: "1"          │
│                                              │
└──────────────────────────────────────────────┘
```

---

## 📱 Screen Lifecycle

### Loading Screen Lifecycle
```
initState()
    │
    ├─ Initialize controllers
    ├─ Start animations
    └─ Call _processImage()
         │
         ├─ Check if imagePath exists
         │
         ├─ YES: Perform OCR
         │   │
         │   ├─ Update status: "Extracting text..."
         │   ├─ Call OCRService.extractTextWithProgress()
         │   ├─ Update status: "Processing..."
         │   ├─ Get extracted text
         │   ├─ Update status: "Complete!"
         │   └─ Navigate to Results
         │
         └─ NO: Show default loading
             └─ Navigate to Results (no OCR)

dispose()
    │
    └─ Dispose controllers
```

---

## 🎨 UI Component Hierarchy

```
MaterialApp
└── WelcomeScreen
    └── HomeScreen
        ├── AnimatedGradientBackground
        ├── Header (InfoDoc title)
        ├── Central Floating Button (+)
        │   └── Radial Menu
        │       ├── Text Input
        │       ├── Camera Input ──────┐
        │       ├── Audio Input        │
        │       └── Upload Input ───┐  │
        │                           │  │
        │                           ▼  ▼
        └── InputPreviewScreen
            ├── AnimatedGradientBackground
            ├── Header (Back button)
            ├── Image Preview ◄─── Shows actual image
            │   ├── Camera preview
            │   └── Upload preview
            └── Action Buttons
                ├── Retake
                └── Proceed ──────┐
                                  │
                                  ▼
                    LoadingScreen
                    ├── AnimatedGradientBackground
                    ├── Lottie Animation
                    ├── Status Text ◄─── OCR progress
                    ├── Progress Bar
                    └── [Auto-navigate] ──────┐
                                              │
                                              ▼
                            ResultsScreen
                            ├── AnimatedGradientBackground
                            ├── Header
                            ├── Source Card
                            ├── Claim Card ◄─── Extracted text
                            ├── Analysis Card
                            ├── References Card
                            ├── Helpline Card
                            ├── Verdict Card
                            └── Action Buttons
```

---

## 🔐 Permission Flow

```
App Launch
    │
    ▼
User taps Camera/Upload
    │
    ▼
Check Permission
    │
    ├─ Granted ──────────────► Proceed
    │
    └─ Not Granted
         │
         ▼
    Request Permission
         │
         ├─ User Grants ─────► Proceed
         │
         └─ User Denies ─────► Show Error/Return
```

### Required Permissions:
- ✅ `CAMERA` - For camera capture
- ✅ `READ_EXTERNAL_STORAGE` - For gallery access
- ✅ `WRITE_EXTERNAL_STORAGE` - For saving images
- ✅ `INTERNET` - For downloading OCR data

---

## 🚀 Execution Flow Timeline

```
Time    Event                           Screen              Action
─────────────────────────────────────────────────────────────────────
0ms     App Launch                      WelcomeScreen       Show onboarding
3000ms  Navigate                        HomeScreen          Show menu
        User taps Camera                HomeScreen          Open camera
        User captures image             Camera              Return image path
        
0ms     Navigate                        InputPreviewScreen  Show image
        Display image                   InputPreviewScreen  Image.file(path)
        User taps Proceed               InputPreviewScreen  Navigate
        
0ms     Navigate                        LoadingScreen       Start OCR
100ms   OCR Start                       LoadingScreen       "Initializing..."
500ms   OCR Processing                  LoadingScreen       "Extracting text..."
2000ms  OCR Processing                  LoadingScreen       "Processing..."
5000ms  OCR Complete                    LoadingScreen       "Complete!"
6500ms  Navigate                        ResultsScreen       Show results
        Display text                    ResultsScreen       Show in Claim
```

---

## 📦 Package Dependencies Graph

```
InfoDoc App
    │
    ├── flutter (SDK)
    │
    ├── UI Packages
    │   ├── animated_text_kit
    │   ├── lottie
    │   ├── flutter_staggered_animations
    │   ├── glassmorphism
    │   ├── flutter_animate
    │   └── google_fonts
    │
    ├── File Handling
    │   ├── file_picker ◄───── Upload images
    │   └── image_picker ◄──── Camera capture
    │
    └── OCR & Permissions
        ├── flutter_tesseract_ocr ◄─── Text extraction
        └── permission_handler ◄────── Camera/Storage permissions
```

---

## 🎯 Key Integration Points

### 1. Home → Preview
```dart
// home_screen.dart
Navigator.push(
  InputPreviewScreen(
    inputType: type,
    imagePath: pickedFile.path  // ← Integration point
  )
);
```

### 2. Preview → Loading
```dart
// input_preview_screen.dart
Navigator.push(
  LoadingScreen(
    imagePath: widget.imagePath,  // ← Integration point
    inputType: widget.inputType   // ← Integration point
  )
);
```

### 3. Loading → OCR Service
```dart
// loading_screen.dart
final extractedText = await OCRService.extractTextWithProgress(
  widget.imagePath!,  // ← Integration point
  (status) => setState(() => _statusText = status)
);
```

### 4. Loading → Results
```dart
// loading_screen.dart
Navigator.pushReplacement(
  ResultsScreen(
    extractedText: _extractedText  // ← Integration point
  )
);
```

### 5. Results → Display
```dart
// results_screen.dart
_result = VerificationResult(
  claim: widget.extractedText ?? "Default",  // ← Integration point
  // ...
);
```

---

## 🔍 Error Handling Flow

```
OCR Process
    │
    ├─ Try
    │   ├─ Check imagePath exists
    │   ├─ Call Tesseract OCR
    │   ├─ Get extracted text
    │   └─ Navigate to Results ✅
    │
    └─ Catch
        ├─ Log error
        ├─ Update status: "Error: ..."
        ├─ Set _isProcessing = false
        └─ Show error message ❌
```

---

This architecture ensures a clean, maintainable, and scalable OCR implementation! 🎉
