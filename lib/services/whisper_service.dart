import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_flutter_plus/whisper_flutter_plus.dart';

class WhisperAudioEngine {
  static Whisper? _whisper;
  static String? _modelPath;
  static bool _isModelReady = false;

  static bool get isReady => _isModelReady;

  // تهيئة النموذج ونسخه من الأصول لذاكرة الهاتف السريعة
  static Future<bool> initWhisper() async {
    if (_isModelReady) return true;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${docDir.path}/ggml-tiny.bin');

      // إذا لم يكن النموذج منسوخاً من قبل، نقوم بنسخه أو تحميله
      if (!await modelFile.exists()) {
        try {
          ByteData data = await rootBundle.load('assets/models/ggml-tiny.bin');
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await modelFile.writeAsBytes(bytes, flush: true);
        } catch (_) {
          // في حال عدم تضمينه في الأصول، يمكن استخدام مسار مباشر
          return false;
        }
      }

      _modelPath = modelFile.path;
      _whisper = Whisper(model: _modelPath!);
      _isModelReady = true;
      return true;
    } catch (e) {
      _isModelReady = false;
      return false;
    }
  }

  // تحويل ملف صوتي (WAV) تم تسجيله من المايكروفون إلى نص دقيق
  static Future<String> transcribeAudioFile(String audioFilePath) async {
    if (!_isModelReady || _whisper == null) return '';
    try {
      final res = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioFilePath,
          language: 'ar', // حصر التعرف باللغة العربية بجميع لهجاتها
          isTranslate: false,
          threads: 4,
          isNoTimestamps: true,
        ),
      );
      return res.text.trim();
    } catch (e) {
      return '';
    }
  }
}

