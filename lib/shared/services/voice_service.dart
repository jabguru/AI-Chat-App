import 'dart:developer';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static VoiceService? _instance;
  static VoiceService get instance {
    _instance ??= VoiceService._();
    return _instance!;
  }

  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isTtsInitialized = false;

  VoiceService._() {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    if (_isTtsInitialized) return;

    try {
      log('Initializing TTS...');

      // iOS specific settings
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      }

      // Check available voices
      final List voices = await _flutterTts.getVoices;
      log('Available voices count: ${voices.length}');

      if (voices.isEmpty) {
        log('WARNING: No TTS voices available!');
        if (Platform.isAndroid) {
          log('Android: Install Google Text-to-Speech from Play Store');
        } else if (Platform.isIOS) {
          log(
            'iOS: Download a voice in Settings > Accessibility > Spoken Content > Voices',
          );
        }
      } else {
        log('First available voice: ${voices.first}');
        // Try to set a voice if available
        try {
          await _flutterTts.setVoice({
            "name": voices.first["name"],
            "locale": voices.first["locale"],
          });
        } catch (e) {
          log('Could not set voice: $e');
        }
      }

      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Android specific: ensure immediate playback without queueing
      if (Platform.isAndroid) {
        try {
          await _flutterTts.setQueueMode(0);
        } catch (_) {}
      }

      // Set up handlers
      _flutterTts.setStartHandler(() {
        log('TTS started speaking');
      });

      _flutterTts.setCompletionHandler(() {
        log('TTS completed speaking');
      });

      _flutterTts.setErrorHandler((msg) {
        log('TTS error: $msg');
      });

      _isTtsInitialized = true;
      log('TTS initialized successfully');
    } catch (e) {
      log('TTS initialization error: $e');
      // Don't mark as initialized so it can retry
    }
  }

  Future<void> speak(String text) async {
    try {
      log('Attempting to speak: "$text"');
      await _initializeTts();

      // Ensure we are not listening when speaking to avoid audio focus conflicts
      if (_speechToText.isListening) {
        log('Stopping STT before speaking');
        await _speechToText.stop();
      }

      // Flush any previous utterances
      if (Platform.isAndroid) {
        try {
          await _flutterTts.setQueueMode(0);
        } catch (_) {}
      }

      log('Calling TTS speak...');
      final result = await _flutterTts.speak(text);
      log('TTS speak result: $result');
    } catch (e) {
      log('Error in speak: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function() onComplete,
  }) async {
    try {
      // Ensure TTS isn't speaking when we start listening
      await _flutterTts.stop();

      // Check if running on simulator
      if (Platform.isIOS) {
        log(
          'Running on iOS - Note: Speech recognition does not work on iOS Simulator, use a physical device',
        );
      }

      // speech_to_text handles permissions internally during initialize
      final isAvailable = await _speechToText.initialize(
        onError: (error) {
          log('Speech recognition error: ${error.errorMsg}');
          if (error.errorMsg == 'error_listen_failed') {
            log(
              'Listen failed - this is common on iOS Simulator. Please test on a physical device.',
            );
          }
        },
        onStatus: (status) {
          log('Speech recognition status: $status');
          if (status == 'done') onComplete();
        },
      );

      if (!isAvailable) {
        log('Speech recognition not available - likely running on simulator');
        throw Exception(
          'Speech recognition not available. Please use a physical device for voice input.',
        );
      }

      log('Starting speech recognition listener...');
      await _speechToText.listen(
        onResult: (result) {
          log("STT Result: ${result.recognizedWords}");
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 90),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
        localeId: 'en_US',
      );
    } catch (e) {
      log('Error in startListening: $e');
      rethrow;
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;

  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
  }
}
