import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SheekhaFullEngine {
  static Map<String, Map<String, String>> _learnedMappings = {};

  // 1. قاموس الحروف العربية الميدانية والبدائل الشائعة التي يلتقطها محرك الصوت
  static final Map<String, String> _letterEquivalents = {
    // الألف
    'ألف': 'أ', 'الف': 'أ', 'ا': 'أ', 'إ': 'أ', 'آ': 'أ', 'ء': 'أ', 'همزة': 'أ', 'أ': 'أ',
    // الباء
    'باء': 'ب', 'با': 'ب', 'بي': 'ب', 'ب': 'ب',
    // الحاء
    'حاء': 'ح', 'حا': 'ح', 'ح': 'ح',
    // الدال
    'دال': 'د', 'دا': 'د', 'دي': 'د', 'د': 'د',
    // الراء
    'راء': 'ر', 'را': 'ر', 'ري': 'ر', 'ر': 'ر',
    // السين
    'سين': 'س', 'سا': 'س', 'سي': 'س', 'س': 'س',
    // الصاد
    'صاد': 'ص', 'صا': 'ص', 'ص': 'ص',
    // الطاء
    'طاء': 'ط', 'طا': 'ط', 'ط': 'ط',
    // العين
    'عين': 'ع', 'عا': 'ع', 'ع': 'ع',
    // القاف
    'قاف': 'ق', 'قا': 'ق', 'قي': 'ق', 'ق': 'ق', 'كاف': 'ك',
    // الكاف
    'ك': 'ك', 'كا': 'ك',
    // اللام
    'لام': 'ل', 'لا': 'ل', 'ل': 'ل',
    // الميم
    'ميم': 'م', 'ما': 'م', 'مي': 'م', 'م': 'م',
    // النون
    'نون': 'ن', 'نا': 'ن', 'ني': 'ن', 'ن': 'ن',
    // الهاء
    'هاء': 'هـ', 'ها': 'هـ', 'هه': 'هـ', 'ه': 'هـ', 'هـ': 'هـ',
    // الواو
    'واو': 'و', 'وا': 'و', 'و': 'و',
    // الياء
    'ياء': 'ى', 'يا': 'ى', 'ي': 'ى', 'ى': 'ى',
  };

  // قائمة الحروف المسموحة نظامياً في اللوحات السعودية
  static const Set<String> validPlateLetters = {
    'أ', 'ب', 'ح', 'د', 'ر', 'س', 'ص', 'ط', 'ع', 'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ى'
  };

  // 2. قاموس أنواع وموديلات وماركات السيارات الشائعة في الرصد الميداني
  static final List<String> _carTypesList = [
    // تويوتا
    'كامري', 'كورولا', 'هايلوكس', 'شاص', 'لاندكروزر', 'برادو', 'فورتشنر', 'يارس', 'راف فور', 'افالون', 'انوفا', 'شيلك', 'اف جي',
    // هيونداي وكيا
    'النترا', 'أكسنت', 'اكسنت', 'سوناتا', 'ازيرا', 'توسان', 'سنتافي', 'كريتا', 'سبورتاج', 'اوبتما', 'كادينزا', 'سيراتو', 'بيجاس', 'كارينز', 'سورينتو', 'تيلورايد', 'ك5', 'k5',
    // نيسان
    'صني', 'التيما', 'ماكسيما', 'باترول', 'ددسن', 'نافارا', 'اكستيرا', 'كيكس', 'باثفايندر',
    // فورد وشيفروليه وجي ام سي
    'فورد', 'توروس', 'اكسبلورر', 'اف 150', 'f150', 'تاهو', 'يوكن', 'سييرا', 'سلفرادو', 'كابرس', 'لومينا', 'ماليبو', 'امبالا', 'سوبربان',
    // ماركات وشركات صينية
    'هافال', 'شانجان', 'ام جي', 'mg', 'جيلي', 'شيري', 'بايك', 'جيتور',
    // سيارات النقل والمهام
    'دينا', 'باص', 'نقل', 'وايت', 'سطحة', 'تريلا', 'قلاب', 'وانيت', 'ملاكي', 'جيب', 'لكزس'
  ];

  // 3. قاموس الأرقام المنطوقة بالعامية والفصحى وتحويلها إلى خانات رقمية
  static final Map<String, String> _spokenNumbers = {
    'صفر': '0', 'زيرو': '0',
    'واحد': '1', 'واحده': '1', 'الاول': '1',
    'اثنين': '2', 'اتنين': '2', 'تنين': '2', 'تانى': '2',
    'ثلاثة': '3', 'تلاتة': '3', 'تلاته': '3', 'ثلاثه': '3',
    'اربعة': '4', 'أربعة': '4', 'اربعه': '4', 'أربعه': '4',
    'خمسة': '5', 'خمسه': '5',
    'ستة': '6', 'سته': '6',
    'سبعة': '7', 'سبعه': '7',
    'ثمانية': '8', 'تمانية': '8', 'ثمانيه': '8', 'تمانيه': '8',
    'تسعة': '9', 'تسعه': '9',
    'عشرة': '10', 'عشره': '10',
    'حداشر': '11', 'أحد عشر': '11', 'احداعش': '11',
    'اثنا عشر': '12', 'اتناشر': '12', 'اطنعش': '12',
    'تلاتاشر': '13', 'ثلاثة عشر': '13', 'تلطاش': '13',
    'اربعتاشر': '14', 'أربعة عشر': '14', 'اربعطاش': '14',
    'خمستاشر': '15', 'خمسة عشر': '15', 'خمسطاش': '15',
    'ستاشر': '16', 'ستة عشر': '16', 'سطاش': '16',
    'سبعتاشر': '17', 'سبعة عشر': '17', 'سبعطاش': '17',
    'تمنتاشر': '18', 'ثمانية عشر': '18', 'تمنطاش': '18',
    'تسعتاشر': '19', 'تسعة عشر': '19', 'تسعطاش': '19',
    'عشرين': '20', 'ثلاثين': '30', 'تلاتين': '30', 'اربعين': '40', 'خمسين': '50',
    'ستين': '60', 'سبعين': '70', 'ثمانين': '80', 'تمانين': '80', 'تسعين': '90',
    'مية': '100', 'ميه': '100', 'مائة': '100', 'ميتين': '200', 'مائتان': '200',
    'تلمية': '300', 'ثلاثمائة': '300', 'اربعمية': '400', 'أربعمائة': '400',
    'خمسمية': '500', 'خمسمائة': '500', 'ستمية': '600', 'ستمائة': '600',
    'سبعمية': '700', 'سبعمائة': '700', 'تمنمية': '800', 'ثمانمائة': '800',
    'تسعمية': '900', 'تسعمائة': '900', 'الف': '1000', 'ألف': '1000'
  };

  // تحميل الذاكرة التعليمية التراكمية
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

  // حفظ تصحيحك للكلمات لكي يتعلم المحرك تلقائياً
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

  // تنظيف وتوحيد النصوص
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

  // توحيد الأرقام (عربي هندي إلى إنجليزي قياسي)
  static String normalizeDigits(String text) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const englishDigits = '0123456789';
    for (int i = 0; i < arabicDigits.length; i++) {
      text = text.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return text;
  }

  // استخراج نوع وماركة السيارة من الكلام
  static String? extractVehicleType(String text) {
    String clean = normalizeFlexible(text);
    for (String car in _carTypesList) {
      if (clean.contains(normalizeFlexible(car))) {
        return car;
      }
    }
    return null;
  }

  // معالجة الأرقام المنطوقة بالعامية داخل النص وتحويلها لأرقام حسابية
  static String convertSpokenWordsToNumbers(String text) {
    String output = text;
    // استبدال الأرقام المركبة أولاً
    _spokenNumbers.forEach((word, digit) {
      output = output.replaceAll(RegExp('\\b$word\\b'), digit);
    });
    return output;
  }

  // ========================================================
  // المحرك الرئيسي: استخراج الحروف واللوحة والنوع بدقة متناهية
  // ========================================================
  static Map<String, dynamic>? parsePlateAndType(String spokenText, {bool isFinalResult = false}) {
    String cleanText = normalizeFlexible(spokenText);

    // 1. فحص الذاكرة الذاتية التراكمية أولاً (هل نطق المستخدم هذه الكلمة سابقاً وصححها؟)
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

    // 2. استخراج نوع السيارة إن وجد في الجملة
    String detectedType = extractVehicleType(spokenText) ?? '-';

    // 3. تحويل الكلمات إلى أرقام
    String textWithConvertedNumbers = convertSpokenWordsToNumbers(spokenText);
    String normalizedAllDigits = normalizeDigits(textWithConvertedNumbers);

    // 4. استخراج الأرقام (من 1 إلى 4 خانات)
    RegExp digitRegex = RegExp(r'\d{1,4}');
    Iterable<Match> digitMatches = digitRegex.allMatches(normalizedAllDigits);
    String extractedDigits = '';
    if (digitMatches.isNotEmpty) {
      // نأخذ أطول تسلسل رقمي تم التقاطه
      for (var m in digitMatches) {
        String matchStr = m.group(0)!;
        if (matchStr.length > extractedDigits.length) {
          extractedDigits = matchStr;
        }
      }
    }

    // 5. استخراج الحروف الميدانية
    List<String> words = spokenText.split(RegExp(r'\s+'));
    List<String> matchedLetters = [];

    for (String word in words) {
      String cleanWord = word.replaceAll(RegExp(r'[^\u0621-\u064A]'), '').trim();
      if (cleanWord.isEmpty) continue;

      // هل الكلمة مطابقة لقاموس الحروف المباشر؟
      if (_letterEquivalents.containsKey(cleanWord)) {
        matchedLetters.add(_letterEquivalents[cleanWord]!);
      } else if (cleanWord.length == 1 && validPlateLetters.contains(cleanWord)) {
        matchedLetters.add(cleanWord);
      } else if (cleanWord.length <= 3) {
        // فحص الحروف إذا نطقها متصلة مثل (قجد)
        List<String> chars = cleanWord.split('');
        if (chars.every((c) => validPlateLetters.contains(_letterEquivalents[c] ?? c))) {
          matchedLetters.addAll(chars.map((c) => _letterEquivalents[c] ?? c));
        }
      }

      if (matchedLetters.length == 3) break;
    }

    // إذا تم التقاط حروف كافية (من حرفين إلى 3) وأرقام (من خانتين إلى 4)
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
