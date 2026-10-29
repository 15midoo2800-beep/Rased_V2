import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SheekhaFullEngine {
  static Map<String, Map<String, String>> _learnedMappings = {};

  // الحروف الـ 17 المعتمدة رسمياً في اللوحات السعودية
  static const Set<String> validPlateChars = {
    'أ', 'ب', 'ح', 'د', 'ر', 'س', 'ص', 'ط', 'ع', 'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ى'
  };

  // 1. خريطة تفكيك الأسماء الصوتية والمخارج الشائعة إلى أحرف اللوحة النظامية
  static final Map<String, String> _phoneticToChar = {
    // الألف
    'ألف': 'أ', 'الف': 'أ', 'ا': 'أ', 'آ': 'أ', 'إ': 'أ', 'همزة': 'أ', 'همزه': 'أ',
    // الباء
    'باء': 'ب', 'با': 'ب', 'بي': 'ب', 'ب': 'ب', 'به': 'ب',
    // الحاء
    'حاء': 'ح', 'حا': 'ح', 'حي': 'ح', 'ح': 'ح', 'حه': 'ح',
    // الدال
    'دال': 'د', 'دا': 'د', 'دي': 'د', 'د': 'د', 'ده': 'د',
    // الراء
    'راء': 'ر', 'را': 'ر', 'ري': 'ر', 'ر': 'ر', 'ره': 'ر',
    // السين
    'سا': 'س', 'سين': 'س', 'سي': 'س', 'س': 'س', 'سه': 'س',
    // الصاد
    'صاد': 'ص', 'صا': 'ص', 'صي': 'ص', 'ص': 'ص', 'صه': 'ص',
    // الطاء
    'طاء': 'ط', 'طا': 'ط', 'طي': 'ط', 'ط': 'ط', 'طه': 'ط',
    // العين
    'عين': 'ع', 'عا': 'ع', 'عي': 'ع', 'ع': 'ع', 'عه': 'ع',
    // القاف
    'قاف': 'ق', 'قا': 'ق', 'قي': 'ق', 'ق': 'ق', 'قه': 'ق',
    // الكاف
    'كاف': 'ك', 'كا': 'ك', 'كي': 'ك', 'ك': 'ك', 'كه': 'ك',
    // اللام
    'لام': 'ل', 'لا': 'ل', 'لي': 'ل', 'ل': 'ل', 'له': 'ل',
    // الميم
    'ميم': 'م', 'ما': 'م', 'مي': 'م', 'م': 'م', 'مه': 'م',
    // النون
    'نون': 'ن', 'نا': 'ن', 'ني': 'ن', 'ن': 'ن', 'نه': 'ن',
    // الهاء
    'هاء': 'هـ', 'ها': 'هـ', 'هي': 'هـ', 'ه': 'هـ', 'هـ': 'هـ', 'هو': 'هـ',
    // الواو
    'واو': 'و', 'وا': 'و', 'وي': 'و', 'و': 'و', 'وه': 'و',
    // الياء
    'ياء': 'ى', 'يا': 'ى', 'ي': 'ى', 'ى': 'ى', 'يه': 'ى',
  };

  // 2. قائمة أنواع وماركات وموديلات السيارات للرصد
  static final List<String> _carBrands = [
    'كامري', 'كورولا', 'هايلوكس', 'شاص', 'لاندكروزر', 'برادو', 'فورتشنر', 'يارس', 'راف فور', 'افالون', 'انوفا', 'اف جي',
    'النترا', 'أكسنت', 'اكسنت', 'سوناتا', 'ازيرا', 'توسان', 'سنتافي', 'كريتا', 'سبورتاج', 'اوبتما', 'كادينزا', 'سيراتو', 'بيجاس', 'سورينتو', 'تيلورايد', 'ك5',
    'صني', 'التيما', 'ماكسيما', 'باترول', 'ددسن', 'نافارا', 'اكستيرا', 'كيكس', 'باثفايندر',
    'توروس', 'اكسبلورر', 'تاهو', 'يوكن', 'سييرا', 'سلفرادو', 'كابرس', 'لومينا', 'ماليبو', 'امبالا',
    'هافال', 'شانجان', 'ام جي', 'جيلي', 'شيري', 'جيتور',
    'دينا', 'باص', 'نقل', 'وايت', 'سطحة', 'تريلا', 'قلاب', 'وانيت', 'ملاكي', 'جيب', 'لكزس'
  ];

  // 3. قاموس الأرقام المنطوقة بالمصري والخليجي
  static final Map<String, String> _spokenNumbers = {
    'صفر': '0', 'زيرو': '0', 'واحد': '1', 'واحده': '1', 'اثنين': '2', 'اتنين': '2',
    'ثلاثة': '3', 'تلاتة': '3', 'تلاته': '3', 'ثلاثه': '3', 'اربعة': '4', 'أربعة': '4', 'اربعه': '4',
    'خمسة': '5', 'خمسه': '5', 'ستة': '6', 'سته': '6', 'سبعة': '7', 'سبعه': '7',
    'ثمانية': '8', 'تمانية': '8', 'ثمانيه': '8', 'تمانيه': '8', 'تسعة': '9', 'تسعه': '9', 'عشرة': '10',
    'حداشر': '11', 'احداعش': '11', 'اتناشر': '12', 'اطنعش': '12', 'تلاتاشر': '13', 'اربعتاشر': '14',
    'خمستاشر': '15', 'ستاشر': '16', 'سبعتاشر': '17', 'تمنتاشر': '18', 'تسعتاشر': '19',
    'عشرين': '20', 'ثلاثين': '30', 'تلاتين': '30', 'اربعين': '40', 'خمسين': '50',
    'ستين': '60', 'سبعين': '70', 'ثمانين': '80', 'تمانين': '80', 'تسعين': '90',
    'مية': '100', 'ميه': '100', 'مائة': '100', 'ميتين': '200', 'خمسمية': '500', 'خمسمائة': '500',
    'سبعمية': '700', 'سبعمائة': '700', 'تسعمية': '900', 'تسعمائة': '900', 'الف': '1000'
  };

  // الدالة المطلوبة التي كان يشتكي منها المترجم
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

  // توحيد الحروف إلى الصيغة المعتمدة نظامياً
  static String _unifyLetter(String char) {
    if (char == 'ا' || char == 'أ' || char == 'إ' || char == 'آ' || char == 'ء') return 'أ';
    if (char == 'ه' || char == 'هـ' || char == 'ة') return 'هـ';
    if (char == 'ي' || char == 'ى') return 'ى';
    return char;
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
    String clean = text.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), ' ').toLowerCase();
    for (String brand in _carBrands) {
      if (clean.contains(brand)) return brand;
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

  // استخراج وتفكيك الحروف الذكي
  static List<String> _extractLettersNeuralContext(String rawSpoken, String carType) {
    String text = rawSpoken;
    if (carType.isNotEmpty && carType != '-') {
      text = text.replaceAll(carType, ' ');
    }

    text = convertSpokenWordsToNumbers(text);
    text = text.replaceAll(RegExp(r'\d+'), ' ');

    List<String> tokens = text.split(RegExp(r'\s+'));
    List<String> collectedLetters = [];

    for (String token in tokens) {
      String clean = token.replaceAll(RegExp(r'[^\u0621-\u064A]'), '').trim();
      if (clean.isEmpty) continue;

      if (_phoneticToChar.containsKey(clean)) {
        collectedLetters.add(_phoneticToChar[clean]!);
      } else if (clean.length == 1) {
        String unified = _unifyLetter(clean);
        if (validPlateChars.contains(unified)) {
          collectedLetters.add(unified);
        }
      } else {
        for (int i = 0; i < clean.length; i++) {
          String char = _unifyLetter(clean[i]);
          if (validPlateChars.contains(char)) {
            collectedLetters.add(char);
          }
          if (collectedLetters.length >= 3) break;
        }
      }

      if (collectedLetters.length >= 3) break;
    }

    return collectedLetters.take(3).toList();
  }

  // المعالج الشامل الفوري
  static Map<String, dynamic>? parsePlateAndType(String spokenText, {bool isFinalResult = false}) {
    String cleanSpoken = normalizeFlexible(spokenText);

    if (_learnedMappings.containsKey(cleanSpoken)) {
      var item = _learnedMappings[cleanSpoken]!;
      return {
        'letters': item['letters']!,
        'digits': item['digits']!,
        'type': item['type']!,
        'hasExplicitType': item['type'] != '-',
        'startsWithAlefOrBaa': item['letters']!.startsWith('أ') || item['letters']!.startsWith('ب'),
      };
    }

    String detectedType = extractVehicleType(spokenText) ?? '-';

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

    List<String> lettersList = _extractLettersNeuralContext(spokenText, detectedType);

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
