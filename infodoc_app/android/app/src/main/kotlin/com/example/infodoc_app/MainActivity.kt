package com.example.infodoc_app

import android.content.Intent
import android.media.MediaPlayer
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.infodoc_app/transcription"
    private var speechRecognizer: SpeechRecognizer? = null
    private var methodResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "transcribeAudio" -> {
                    val audioPath = call.argument<String>("audioPath")
                    if (audioPath != null) {
                        transcribeAudioFile(audioPath, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Audio path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun transcribeAudioFile(audioPath: String, result: MethodChannel.Result) {
        try {
            val audioFile = File(audioPath)
            if (!audioFile.exists()) {
                result.error("FILE_NOT_FOUND", "Audio file not found at path: $audioPath", null)
                return
            }

            methodResult = result
            
            // Initialize speech recognizer
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
            
            val recognitionListener = object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) {}
                override fun onBeginningOfSpeech() {}
                override fun onRmsChanged(rmsdB: Float) {}
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() {}
                
                override fun onError(error: Int) {
                    val errorMessage = when (error) {
                        SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
                        SpeechRecognizer.ERROR_CLIENT -> "Client side error"
                        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Insufficient permissions"
                        SpeechRecognizer.ERROR_NETWORK -> "Network error"
                        SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Network timeout"
                        SpeechRecognizer.ERROR_NO_MATCH -> "No speech match found"
                        SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "Recognition service busy"
                        SpeechRecognizer.ERROR_SERVER -> "Server error"
                        SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "No speech input"
                        else -> "Unknown error"
                    }
                    methodResult?.error("TRANSCRIPTION_ERROR", errorMessage, null)
                    methodResult = null
                    speechRecognizer?.destroy()
                }
                
                override fun onResults(results: Bundle?) {
                    val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    if (matches != null && matches.isNotEmpty()) {
                        methodResult?.success(matches[0])
                    } else {
                        methodResult?.error("NO_RESULTS", "No transcription results", null)
                    }
                    methodResult = null
                    speechRecognizer?.destroy()
                }
                
                override fun onPartialResults(partialResults: Bundle?) {}
                override fun onEvent(eventType: Int, params: Bundle?) {}
            }
            
            speechRecognizer?.setRecognitionListener(recognitionListener)
            
            // Create intent for speech recognition
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            }
            
            // Play audio file and recognize
            playAudioAndRecognize(audioPath, intent)
            
        } catch (e: Exception) {
            result.error("TRANSCRIPTION_FAILED", "Failed to transcribe: ${e.message}", null)
        }
    }
    
    private fun playAudioAndRecognize(audioPath: String, intent: Intent) {
        try {
            // Start speech recognition
            // Note: Android's SpeechRecognizer doesn't directly support file input
            // This is a workaround that plays the audio and tries to recognize it
            // For production, consider using Google Cloud Speech-to-Text API or similar
            
            val mediaPlayer = MediaPlayer().apply {
                setDataSource(audioPath)
                prepare()
            }
            
            // Start recognition when audio starts playing
            mediaPlayer.setOnPreparedListener {
                speechRecognizer?.startListening(intent)
                it.start()
            }
            
            mediaPlayer.setOnCompletionListener {
                it.release()
            }
            
        } catch (e: Exception) {
            methodResult?.error("PLAYBACK_ERROR", "Error playing audio: ${e.message}", null)
            methodResult = null
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        speechRecognizer?.destroy()
    }
}
