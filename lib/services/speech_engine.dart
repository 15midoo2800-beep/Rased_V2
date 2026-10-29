import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SheekhaFullEngine {
  static Map<String, Map<String, String>> _learnedMappings = {};

  // حروف اللوحات الرسمية المعتمدة
  static const List<String> standardPlateLetters = [
    'أ', 'ب', 'ح', 'د', 'ر', 'س', 'ص', 'ط', 'ع', 'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ى'
  ];

  // شبكة الحروف المسموح باستخراجها من الكلمات المندمجة
  static const Set<String> _validCharSet = {
    'ا', 'أ', 'إ', 'آ', 'ب', 'ح', 'د', 'ر', 'س', 'ص', 'ط', 'ع', 'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي', 'ى'
  };

  // مصفوفة التحويل الصوتي للأحرف المنفصلة والبدائل
  static final Map<String, String> _phoneticMap = {
    'الف': 'أ', 'ألف': 'أ', 'ا': 'أ', 'همزه': 'أ', 'همزة': 'أ', 'آ': 'أ', 'إ': 'أ',
    'با': 'ب', 'باء': 'ب', 'بي': 'ب', 'ب': 'ب', 'به': 'ب',
    'حا': 'ح', 'حاء': 'ح', 'حي': 'ح', 'ح': 'ح', 'حه': 'ح',
    'دا': 'د', 'دال': 'د', 'دي': 'د', 'د': 'د', 'ده': 'د',
    'را': 'ر', 'راء': 'ر', 'ري': 'ر', 'ر': 'ر', 'ره': 'ر',
    'سا': 'س', 'سين': 'س', 'سي': 'س', 'س': 'س', 'سه': 'س',
    'صا': 'ص', 'صاد': 'ص', 'صي': 'ص', 'ص': 'ص', 'صه': 'ص',
    'طا': 'ط', 'طاء': 'ط', 'طي': 'ط', 'ط': 'ط', 'طه': 'ط',
    'عا': 'ع', 'عين': 'ع', 'عي': 'ع', 'ع': 'ع', 'عه': 'ع',
    'قا': 'ق', 'قاف': 'ق', 'قي': 'ق', 'ق': 'ق', 'قه': 'ق',
    'كا': 'ك', 'كاف': 'ك', 'كي': 'ك', 'ك': 'ك', 'كه': 'ك',
    'لا': 'ل', 'لام': 'ل', 'لي': 'ل', 'ل': 'ل', 'له': 'ل',
    'ما': 'م', 'ميم': 'م', 'مي': 'م', 'م': 'م', 'مه': 'م',
    'نا': 'ن', 'نون': 'ن', 'ني': 'ن', 'ن': 'ن', 'نه': 'ن',
    'ها': 'هـ', 'هاء': 'هـ', 'هي': 'هـ', 'ه': 'هـ', 'هـ': 'هـ',
    'وا': 'و', 'واو': 'و', 'وي': 'و', 'و': 'و', 'وه': 'و',
    'يا': 'ى', 'ياء': 'ى', 'ي': 'ى', 'ى': 'ى', 'يه': 'ى',
  };

  // خريطة لتوحيد أشكال الحروف
  static String _canonicalLetter(String char) {
    if (char == 'ا' || char == 'أ' || char == 'إ' || char == 'آ') return 'أ';
    if (char == 'ه' || char == 'هـ') return 'هـ';
    if (char == 'ي' || char == 'ى') return 'ى';
    return char;
  }

  // أنواع وموديلات السيارات الشائعة
  static final List<String> _carTypes = [
    'كامري', 'كورولا', 'هايلوكس', 'شاص', 'لاندكروزر', 'برادو', 'فورتشنر', 'يارس', 'راف فور', 'افالون', 'انوفا', 'اف جي',
    'النترا', 'أكسنت', 'اكسنت', 'سوناتا', 'ازيرا', 'توسان', 'سنتافي', 'كريتا', 'سبورتاج', 'اوبتما', 'كادينزا', 'سيراتو', 'بيجاس', 'سورينتو', 'تيلورايد', 'ك5',
    'صني', 'التيما', 'ماكسيما', 'باترول', 'ددسن', 'نافارا', 'اكستيرا', 'كيكس', 'باثفايندر',
    'توروس', 'اكسبلورر', 'تاهو', 'يوكن', 'سييرا', 'سلفرادو', 'كابرس', 'لومينا', 'ماليبو', 'امبالا',
    'هافال', 'شانجان', 'ام جي', 'جيلي', 'شيري', 'جيتور',
    'دينا', 'باص', 'نقل', 'وايت', 'سطحة', 'تريلا', 'قلاب', 'وانيت', 'ملاكي', 'جيب', 'لكزس'
  ];

  static final Map<String, String> _spokenNumbers = {
    'صفر': '0', 'زيرو': '0', 'واحد': '1', 'واحده': '1', 'اثنين': '2', 'اتنين': '2',
    'ثلاثة': '3', 'تلاتة': '3', 'تلاته': '3', 'اربعة': '4', 'أربعة': '4', 'اربعه': '4',
    'خمسة': '5', 'خمسه': '5', 'ستة': '6', 'سته': '6', 'سبعة': '7', 'سبعه': '7',
    'ثمانية': '8', 'تمانية': '8', 'ثمانيه': '8', 'تسعة': '9', 'تسعه': '9', 'عشرة': '10',
    'حداشر': '11', 'اتناشر': '12', 'تلاتاشر': '13', 'اربعتاشر': '14', 'خمستاشر': '15',
    'ستاشر': '16', 'سبعتاشر': '17', 'تمنتاشر': '18', 'تسعتاشر': '19',
    'عشرين': '20', 'ثلاثين': '30', 'تلاتين': '30', 'اربعين': '40', 'خمسين': '50',
    'ستين': '60', 'سبعين': '70', 'ثمانين': '80', 'تسعين': '90',
    'مية': '100', 'ميتين': '200', 'خمسمية': '500', 'سبعمية': '700', 'تسعمية': '900', 'الف': '1000'
  };

  static String normalizeFlexible(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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

  static String? extractVehicleType(String text) {
    String clean = normalizeFlexible(text).toLowerCase();
    for (String car in _carTypes) {
      if (clean.contains(car)) return car;
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

  // ========================================================
  // خوارزمية الذكاء الاصطناعي لتشريح وتفكيك الحروف السريعة
  // ========================================================
  static List<String> _smartExtractPlateLetters(String rawInput, String excludedCarType) {
    List<String> result = [];
    String textWithoutCar = rawInput;
    if (excludedCarType.isNotEmpty && excludedCarType != '-') {
      textWithoutCar = textWithoutCar.replaceAll(excludedCarType, ' ');
    }

    // إزالة الأرقام المنطوقة والمكتوبة للتركيز فقط على المقطع الصوتي للحروف
    textWithoutCar = convertSpokenWordsToNumbers(textWithoutCar);
    textWithoutCar = textWithoutCar.replaceAll(RegExp(r'\d+'), ' ');

    List<String> tokens = textWithoutCar.split(RegExp(r'\s+'));

    for (String token in tokens) {
      String cleanToken = token.replaceAll(RegExp(r'[^\u0621-\u064A]'), '').trim();
      if (cleanToken.isEmpty) continue;

      // أ) إذا نُطق الحرف كاسم حرف مستقل (قاف، جيم، دال، باء..)
      if (_phoneticMap.containsKey(cleanToken)) {
        result.add(_phoneticMap[cleanToken]!);
      } 
      // ب) إذا كان الحرف مفرداً وصحيحاً
      else if (cleanToken.length == 1 && _validCharSet.contains(cleanToken)) {
        result.add(_canonicalLetter(cleanToken));
      } 
      // ج) التفكيك الذكي للكلمات السريعة (إذا اعتبر جوجل الحروف كلمة واحدة مثل: "قجد" أو "صقر")
      else if (cleanToken.length >= 2 && cleanToken.length <= 4) {
        List<String> subLetters = [];
        for (int i = 0; i < cleanToken.length; i++) {
          String char = cleanToken[i];
          if (_validCharSet.contains(char)) {
            subLetters.add(_canonicalLetter(char));
          }
        }
        if (subLetters.isNotEmpty && subLetters.length <= 3) {
          result.addAll(subLetters);
        }
      }

      if (result.length >= 3) break;
    }

    return result.take(3).toList();
  }

  // ========================================================
  // المحلل الميداني الفوري
  // ========================================================
  static Map<String, dynamic>? parsePlateAndType(String spokenText, {bool isFinalResult = false}) {
    String cleanText = normalizeFlexible(spokenText);

    // 1. فحص الذاكرة التعليمية الذاتية أولاً
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

    // 2. استخراج نوع السيارة
    String detectedType = extractVehicleType(spokenText) ?? '-';

    // 3. استخراج الأرقام (أعلى تسلسل رقمي)
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

    // 4. استخراج الحروف عبر الخوارزمية التفكيكية
    List<String> lettersList = _smartExtractPlateLetters(spokenText, detectedType);

    // اعتماد اللوحة عند توفر رقم صحيح (من خانتين إلى 4) وحرفين إلى 3 أحرف
    if (lettersList.isNotEmpty && extractedDigits.isNotEmpty && extractedDigits.length >= 2) {
      String formattedLetters = lettersList.join(' ');
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
