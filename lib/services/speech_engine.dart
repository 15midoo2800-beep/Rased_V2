import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SheekhaFullEngine {
  static Map<String, Map<String, String>> _learnedMappings = {};

  // الحروف الـ 17 الرسمية للوحات السعودية
  static const Set<String> validPlateChars = {
    'أ', 'ب', 'ح', 'د', 'ر', 'س', 'ص', 'ط', 'ع', 'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ى'
  };

  // 1. قاموس الكود الصوتي الميداني والبدائل الصوتية الشائعة
  static final Map<String, String> _phoneticToChar = {
    // الألف
    'ألف': 'أ', 'الف': 'أ', 'ا': 'أ', 'آ': 'أ', 'إ': 'أ', 'همزة': 'أ', 'همزه': 'أ', 'أسد': 'أ', 'احمد': 'أ',
    // الباء
    'باء': 'ب', 'با': 'ب', 'بي': 'ب', 'ب': 'ب', 'به': 'ب', 'باب': 'ب', 'برج': 'ب', 'بيت': 'ب', 'بطه': 'ب',
    // الحاء
    'حاء': 'ح', 'حا': 'ح', 'حي': 'ح', 'ح': 'ح', 'حه': 'ح', 'حصان': 'ح', 'حرب': 'ح', 'حوت': 'ح',
    // الدال
    'دال': 'د', 'دا': 'د', 'دي': 'د', 'د': 'د', 'ده': 'د', 'درع': 'د', 'دب': 'د', 'ديك': 'د',
    // الراء
    'راء': 'ر', 'را': 'ر', 'ري': 'ر', 'ر': 'ر', 'ره': 'ر', 'رجل': 'ر', 'رعد': 'ر', 'راس': 'ر',
    // السين
    'سا': 'س', 'سين': 'س', 'سي': 'س', 'س': 'س', 'سه': 'س', 'سيف': 'س', 'سمك': 'س', 'ساعة': 'س',
    // الصاد
    'صاد': 'ص', 'صا': 'ص', 'صي': 'ص', 'ص': 'ص', 'صه': 'ص', 'صقر': 'ص', 'صاروخ': 'ص', 'صخر': 'ص',
    // الطاء
    'طاء': 'ط', 'طا': 'ط', 'طي': 'ط', 'ط': 'ط', 'طه': 'ط', 'طيار': 'ط', 'طير': 'ط', 'طريق': 'ط',
    // العين
    'عين': 'ع', 'عا': 'ع', 'عي': 'ع', 'ع': 'ع', 'عه': 'ع', 'علم': 'ع', 'عين': 'ع', 'عنب': 'ع',
    // القاف (شاملة نطق الكاف أو الجيم المعطشة في الصعيدي)
    'قاف': 'ق', 'قا': 'ق', 'قي': 'ق', 'ق': 'ق', 'قه': 'ق', 'قمر': 'ق', 'قلب': 'ق', 'قرش': 'ق', 'كاف': 'ق', 'غين': 'ق',
    // الكاف المستقلة
    'كا': 'ك', 'كي': 'ك', 'كه': 'ك', 'كتاب': 'ك', 'كلب': 'ك',
    // اللام
    'لام': 'ل', 'لا': 'ل', 'لي': 'ل', 'ل': 'ل', 'له': 'ل', 'ليمون': 'ل', 'لوح': 'ل',
    // الميم
    'ميم': 'م', 'ما': 'م', 'مي': 'م', 'م': 'م', 'مه': 'م', 'مصر': 'م', 'مسجد': 'م', 'موز': 'م',
    // النون
    'نون': 'ن', 'نا': 'ن', 'ني': 'ن', 'ن': 'ن', 'نه': 'ن', 'نمر': 'ن', 'نجم': 'ن', 'نار': 'ن',
    // الهاء
    'هاء': 'هـ', 'ها': 'هـ', 'هي': 'هـ', 'ه': 'هـ', 'هـ': 'هـ', 'هو': 'هـ', 'هرم': 'هـ', 'هلال': 'هـ',
    // الواو
    'واو': 'و', 'وا': 'و', 'وي': 'و', 'و': 'و', 'وه': 'و', 'ورد': 'و', 'وحش': 'و',
    // الياء
    'ياء': 'ى', 'يا': 'ى', 'ي': 'ى', 'ى': 'ى', 'يه': 'ى', 'يد': 'ى', 'يمامة': 'ى',
  };

  // 2. تفكيك الكلمات المشوهة الشائعة التي ينتجها جوجل عند دمج 3 حروف سريعة
  static final Map<String, List<String>> _mergedWordsFixer = {
    'قلم': ['ق', 'ل', 'م'],
    'قعد': ['ق', 'ع', 'د'],
    'نور': ['ن', 'و', 'ر'],
    'صقر': ['ص', 'ق', 'ر'],
    'بحر': ['ب', 'ح', 'ر'],
    'علم': ['ع', 'ل', 'م'],
    'سند': ['س', 'ن', 'د'],
    'وعد': ['و', 'ع', 'د'],
    'حمد': ['ح', 'م', 'د'],
    'بدر': ['ب', 'د', 'ر'],
    'نصر': ['ن', 'ص', 'ر'],
    'رمل': ['ر', 'م', 'ل'],
    'حرم': ['ح', 'ر', 'م'],
    'عمر': ['ع', 'م', 'ر'],
    'هرم': ['هـ', 'ر', 'م'],
    'طير': ['ط', 'ى', 'ر'],
    'سيف': ['س', 'ى', 'ف'],
    'سوق': ['س', 'و', 'ق'],
    'بلد': ['ب', 'ل', 'د'],
  };

  // 3. قائمة ماركات وأنواع السيارات للرصد
  static final List<String> _carBrands = [
    'كامري', 'كورولا', 'هايلوكس', 'شاص', 'لاندكروزر', 'برادو', 'فورتشنر', 'يارس', 'راف فور', 'افالون', 'انوفا', 'اف جي',
    'النترا', 'أكسنت', 'اكسنت', 'سوناتا', 'ازيرا', 'توسان', 'سنتافي', 'كريتا', 'سبورتاج', 'اوبتما', 'كادينزا', 'سيراتو', 'بيجاس', 'سورينتو', 'تيلورايد', 'ك5',
    'صني', 'التيما', 'ماكسيما', 'باترول', 'ددسن', 'نافارا', 'اكستيرا', 'كيكس', 'باثفايندر',
    'توروس', 'اكسبلورر', 'تاهو', 'يوكن', 'سييرا', 'سلفرادو', 'كابرس', 'لومينا', 'ماليبو', 'امبالا',
    'هافال', 'شانجان', 'ام جي', 'جيلي', 'شيري', 'جيتور',
    'دينا', 'باص', 'نقل', 'وايت', 'سطحة', 'تريلا', 'قلاب', 'وانيت', 'ملاكي', 'جيب', 'لكزس'
  ];

  // 4. أرقام النطق العامية والفصحى
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
  static List<String> _extractPlateLettersFast(String rawSpoken, String carType) {
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

      String normalizedToken = normalizeFlexible(clean);

      // 1. فحص قائمة الكلمات المندمجة
      if (_mergedWordsFixer.containsKey(normalizedToken)) {
        collectedLetters.addAll(_mergedWordsFixer[normalizedToken]!);
      }
      // 2. فحص قاموس الكود الصوتي والمخارج
      else if (_phoneticToChar.containsKey(clean)) {
        collectedLetters.add(_phoneticToChar[clean]!);
      }
      // 3. الحرف المفرد الصريح
      else if (clean.length == 1) {
        String unified = _unifyLetter(clean);
        if (validPlateChars.contains(unified)) {
          collectedLetters.add(unified);
        }
      }
      // 4. تفكيك الكلمات السريعة وسحب الأحرف المتوافقة مع النظام المروري
      else {
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

    List<String> lettersList = _extractPlateLettersFast(spokenText, detectedType);

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
