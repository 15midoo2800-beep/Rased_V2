import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SheekhaFullEngine {
  static Map<String, Map<String, String>> _learnedMappings = {};

  // قائمة الحروف المعتمدة نظامياً في اللوحات السعودية
  static const List<String> standardPlateLetters = [
    'أ', 'ب', 'ح', 'د', 'ر', 'س', 'ص', 'ط', 'ع', 'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ى'
  ];

  // قاموس المخارج الصوتية والبدائل التنبؤية للحروف
  static final Map<String, String> _phoneticLetterMap = {
    'الف': 'أ', 'ألف': 'أ', 'ا': 'أ', 'همزه': 'أ', 'همزة': 'أ', 'آ': 'أ', 'إ': 'أ',
    'با': 'ب', 'باء': 'ب', 'بي': 'ب', 'ب': 'ب',
    'حا': 'ح', 'حاء': 'ح', 'حي': 'ح', 'ح': 'ح',
    'دا': 'د', 'دال': 'د', 'دي': 'د', 'د': 'د',
    'را': 'ر', 'راء': 'ر', 'ري': 'ر', 'ر': 'ر',
    'سا': 'س', 'سين': 'س', 'سي': 'س', 'س': 'س',
    'صا': 'ص', 'صاد': 'ص', 'صي': 'ص', 'ص': 'ص',
    'طا': 'ط', 'طاء': 'ط', 'طي': 'ط', 'ط': 'ط',
    'عا': 'ع', 'عين': 'ع', 'عي': 'ع', 'ع': 'ع',
    'قا': 'ق', 'قاف': 'ق', 'قي': 'ق', 'ق': 'ق', 'كاف': 'ك',
    'كا': 'ك', 'ك': 'ك',
    'لا': 'ل', 'لام': 'ل', 'لي': 'ل', 'ل': 'ل',
    'ما': 'م', 'ميم': 'م', 'مي': 'م', 'م': 'م',
    'نا': 'ن', 'نون': 'ن', 'ني': 'ن', 'ن': 'ن',
    'ها': 'هـ', 'هاء': 'هـ', 'هي': 'هـ', 'ه': 'هـ', 'هـ': 'هـ',
    'وا': 'و', 'واو': 'و', 'وي': 'و', 'و': 'و',
    'يا': 'ى', 'ياء': 'ى', 'ي': 'ى', 'ى': 'ى',
  };

  // قاموس الموديلات والأنواع الميدانية للرصد
  static final List<String> _carTypes = [
    'كامري', 'كورولا', 'هايلوكس', 'شاص', 'لاندكروزر', 'برادو', 'فورتشنر', 'يارس', 'راف فور', 'افالون', 'انوفا', 'اف جي',
    'النترا', 'أكسنت', 'اكسنت', 'سوناتا', 'ازيرا', 'توسان', 'سنتافي', 'كريتا', 'سبورتاج', 'اوبتما', 'كادينزا', 'سيراتو', 'بيجاس', 'سورينتو', 'تيلورايد', 'ك5',
    'صني', 'التيما', 'ماكسيما', 'باترول', 'ددسن', 'نافارا', 'اكستيرا', 'كيكس', 'باثفايندر',
    'توروس', 'اكسبلورر', 'تاهو', 'يوكن', 'سييرا', 'سلفرادو', 'كابرس', 'لومينا', 'ماليبو', 'امبالا',
    'هافال', 'شانجان', 'ام جي', 'جيلي', 'شيري', 'جيتور',
    'دينا', 'باص', 'نقل', 'وايت', 'سطحة', 'تريلا', 'قلاب', 'وانيت', 'ملاكي', 'جيب', 'لكزس'
  ];

  // أرقام النطق العامية
  static final Map<String, String> _spokenNumbers = {
    'صفر': '0', 'زيرو': '0', 'واحد': '1', 'واحده': '1',
    'اثنين': '2', 'اتنين': '2', 'تنين': '2',
    'ثلاثة': '3', 'تلاتة': '3', 'تلاته': '3', 'ثلاثه': '3',
    'اربعة': '4', 'أربعة': '4', 'اربعه': '4', 'أربعه': '4',
    'خمسة': '5', 'خمسه': '5', 'ستة': '6', 'سته': '6',
    'سبعة': '7', 'سبعه': '7', 'ثمانية': '8', 'تمانية': '8', 'ثمانيه': '8', 'تمانيه': '8',
    'تسعة': '9', 'تسعه': '9', 'عشرة': '10', 'عشره': '10',
    'حداشر': '11', 'احداعش': '11', 'اتناشر': '12', 'اطنعش': '12',
    'تلاتاشر': '13', 'اربعتاشر': '14', 'خمستاشر': '15', 'ستاشر': '16',
    'سبعتاشر': '17', 'تمنتاشر': '18', 'تسعتاشر': '19',
    'عشرين': '20', 'ثلاثين': '30', 'تلاتين': '30', 'اربعين': '40', 'خمسين': '50',
    'ستين': '60', 'سبعين': '70', 'ثمانين': '80', 'تمانين': '80', 'تسعين': '90',
    'مية': '100', 'ميه': '100', 'ميتين': '200', 'خمسمية': '500', 'سبعمية': '700', 'تسعمية': '900', 'الف': '1000'
  };

  // ==========================================
  // خوارزمية الذكاء الاصطناعي لقياس التقارب اللغوي (Levenshtein Distance)
  // ==========================================
  static int _computeLevenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1.codeUnitAt(i) == s2.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  // مطابقة ذكية للكلمة مع الحرف الأقرب صوتياً بدقة احتمالية
  static String? _predictClosestLetter(String rawWord) {
    String clean = normalizeFlexible(rawWord);
    if (_phoneticLetterMap.containsKey(clean)) {
      return _phoneticLetterMap[clean];
    }

    // إذا كانت الكلمة حرفاً واحداً صحيحاً
    if (clean.length == 1 && standardPlateLetters.contains(clean)) {
      return clean;
    }

    // مطابقة ذكية مع قاموس الحروف
    String? bestMatch;
    int minDistance = 999;
    for (var entry in _phoneticLetterMap.entries) {
      int dist = _computeLevenshteinDistance(clean, entry.key);
      if (dist < minDistance && dist <= 1) { // سماح بـ 1 خطأ إملائي من محرك جوجل
        minDistance = dist;
        bestMatch = entry.value;
      }
    }
    return bestMatch;
  }

  // مطابقة ذكية لماركة السيارة حتى لو التقطها جوجل بلكنة مختلفة
  static String? extractVehicleType(String text) {
    String clean = normalizeFlexible(text);
    for (String car in _carTypes) {
      if (clean.contains(normalizeFlexible(car))) {
        return car;
      }
    }
    // فحص تقارب ذكي للكلمات المنفردة
    List<String> tokens = clean.split(' ');
    for (String token in tokens) {
      if (token.length < 3) continue;
      for (String car in _carTypes) {
        int dist = _computeLevenshteinDistance(token, normalizeFlexible(car));
        if (dist <= 1) {
          return car;
        }
      }
    }
    return null;
  }

  static Future<void> loadLearnedDictionary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('rased_ai_learned_voice');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        Map<String, dynamic> decoded = json.decode(jsonStr);
        _learnedMappings = decoded.map((k, v) => MapEntry(k, Map<String, String>.from(v)));
      }
    } catch (_) {}
  }

  static Future<void> saveLearnedMapping(String spoken, String letters, String digits, String type) async {
    try {
      String cleanSpoken = normalizeFlexible(spoken);
      if (cleanSpoken.isEmpty) return;
      _learnedMappings[cleanSpoken] = {
        'letters': letters,
        'digits': digits,
        'type': type,
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rased_ai_learned_voice', json.encode(_learnedMappings));
    } catch (_) {}
  }

  static String normalizeFlexible(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  static String normalizeDigits(String text) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const englishDigits = '0123456789';
    for (int i = 0; i < arabicDigits.length; i++) {
      text = text.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return text;
  }

  static String convertSpokenWordsToNumbers(String text) {
    String output = text;
    _spokenNumbers.forEach((word, digit) {
      output = output.replaceAll(RegExp('\\b$word\\b'), digit);
    });
    return output;
  }

  // ==========================================
  // المحرك التحليلي للوحة ومطابقتها اللحظية
  // ==========================================
  static Map<String, dynamic>? parsePlateAndType(String spokenText, {bool isFinalResult = false}) {
    String cleanText = normalizeFlexible(spokenText);

    // 1. استرجاع سريع من قاعدة البيانات العصبية التراكمية إذا تم تدريبها سابقاً
    if (_learnedMappings.containsKey(cleanText)) {
      var item = _learnedMappings[cleanText]!;
      return {
        'letters': item['letters']!,
        'digits': item['digits']!,
        'type': item['type']!,
        'hasExplicitType': item['type'] != '-',
        'startsWithAlefOrBaa': item['letters']!.startsWith('أ') || item['letters']!.startsWith('ب'),
      };
    }

    // 2. استخراج النوع بالذكاء اللغوي
    String detectedType = extractVehicleType(spokenText) ?? '-';

    // 3. تحويل واستخراج الأرقام
    String textWithConvertedNumbers = convertSpokenWordsToNumbers(spokenText);
    String normalizedAllDigits = normalizeDigits(textWithConvertedNumbers);

    RegExp digitRegex = RegExp(r'\d{1,4}');
    Iterable<Match> digitMatches = digitRegex.allMatches(normalizedAllDigits);
    String extractedDigits = '';
    if (digitMatches.isNotEmpty) {
      for (var m in digitMatches) {
        String matchStr = m.group(0)!;
        if (matchStr.length > extractedDigits.length) {
          extractedDigits = matchStr;
        }
      }
    }

    // 4. استخراج الحروف عبر الذكاء الاحتمالي (Phonetic Probability)
    List<String> words = spokenText.split(RegExp(r'\s+'));
    List<String> matchedLetters = [];

    for (String word in words) {
      String cleanWord = word.replaceAll(RegExp(r'[^\u0621-\u064A]'), '').trim();
      if (cleanWord.isEmpty) continue;

      String? predicted = _predictClosestLetter(cleanWord);
      if (predicted != null) {
        matchedLetters.add(predicted);
      } else if (cleanWord.length <= 3) {
        // تفكيك الحروف الملتصقة إن وجدت
        for (var char in cleanWord.split('')) {
          String? subPredicted = _predictClosestLetter(char);
          if (subPredicted != null) matchedLetters.add(subPredicted);
        }
      }

      if (matchedLetters.length == 3) break;
    }

    if (matchedLetters.isNotEmpty && extractedDigits.isNotEmpty && extractedDigits.length >= 2) {
      String formattedLetters = matchedLetters.take(3).join(' ');
      bool startsWithAlefOrBaa = formattedLetters.startsWith('أ') || formattedLetters.startsWith('ب');

      return {
        'letters': formattedLetters,
        'digits': extractedDigits,
        'type': detectedType,
        'hasExplicitType': detectedType != '-',
        'startsWithAlefOrBaa': startsWithAlefOrBaa,
      };
    }

    return null;
  }
}
