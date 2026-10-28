
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SheekhaFullEngine {
  static Map<String, dynamic> userLearnedMap = {};
  static Map<String, String> userWordMap = {};

  static Future<void> loadLearnedDictionary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString('rased_user_learned_v8');
      if (saved != null && saved.isNotEmpty) {
        userLearnedMap = json.decode(saved);
      }
      final String? savedWords = prefs.getString('rased_user_words_v8');
      if (savedWords != null && savedWords.isNotEmpty) {
        Map<String, dynamic> dec = json.decode(savedWords);
        userWordMap = dec.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
  }

  static Future<void> saveLearnedMapping(
    String rawSpoken,
    String correctLetters,
    String correctDigits,
    String correctType, {
    String? wrongSingleWord,
    String? targetSingleFix,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    String cleanSpoken = normalizeFlexible(rawSpoken);
    if (cleanSpoken.isNotEmpty) {
      userLearnedMap[cleanSpoken] = {
        'letters': correctLetters.trim(),
        'digits': correctDigits.trim(),
        'type': correctType.trim(),
      };
      await prefs.setString('rased_user_learned_v8', json.encode(userLearnedMap));
    }

    if (wrongSingleWord != null && wrongSingleWord.trim().isNotEmpty && targetSingleFix != null && targetSingleFix.trim().isNotEmpty) {
      userWordMap[wrongSingleWord.trim()] = targetSingleFix.trim();
      await prefs.setString('rased_user_words_v8', json.encode(userWordMap));
    }
  }

  static final Map<String, String> lettersMap = {
    'الف': 'أ', 'ألف': 'أ', 'إلف': 'أ', 'ا': 'أ', 'أ': 'أ', 'إ': 'أ', 'آ': 'أ',
    'باء': 'ب', 'به': 'ب', 'بة': 'ب', 'با': 'ب', 'بي': 'ب', 'ب': 'ب',
    'تاء': 'ت', 'ته': 'ت', 'تا': 'ت', 'ت': 'ت',
    'ثاء': 'ث', 'ثه': 'ث', 'ثا': 'ث', 'ث': 'ث',
    'جيم': 'ج', 'جه': 'ج', 'جا': 'ج', 'ج': 'ج',
    'حاء': 'ح', 'حه': 'ح', 'حة': 'ح', 'حا': 'ح', 'ح': 'ح',
    'خاء': 'خ', 'خه': 'خ', 'خا': 'خ', 'خ': 'خ',
    'دال': 'د', 'ده': 'د', 'دا': 'د', 'د': 'د',
    'ذال': 'ذ', 'ذه': 'ذ', 'ذا': 'ذ', 'ذ': 'ذ',
    'راء': 'ر', 'ره': 'ر', 'رة': 'ر', 'را': 'ر', 'ر': 'ر',
    'زين': 'ز', 'زه': 'ز', 'زا': 'ز', 'زاي': 'ز', 'ز': 'ز',
    'سين': 'س', 'سه': 'س', 'سا': 'س', 'س': 'س',
    'شين': 'ش', 'شه': 'ش', 'شا': 'ش', 'ش': 'ش',
    'صاد': 'ص', 'صاه': 'ص', 'صه': 'ص', 'صا': 'ص', 'ص': 'ص',
    'ضاد': 'ض', 'ضه': 'ض', 'ضا': 'ض', 'ض': 'ض',
    'طاء': 'ط', 'طه': 'ط', 'طا': 'ط', 'ط': 'ط',
    'ظاء': 'ظ', 'ظه': 'ظ', 'ظا': 'ظ', 'ظ': 'ظ',
    'عين': 'ع', 'عه': 'ع', 'عا': 'ع', 'عن': 'ع', 'ع': 'ع',
    'غين': 'غ', 'غه': 'غ', 'غا': 'غ', 'غ': 'غ',
    'فاء': 'ف', 'فه': 'ف', 'فة': 'ف', 'فا': 'ف', 'ف': 'ف',
    'قاف': 'q', 'قه': 'q', 'قا': 'q', 'ق': 'q', 'كاف': 'ك', 'كه': 'ك', 'كا': 'ك', 'ك': 'ك',
    'لام': 'ل', 'له': 'ل', 'لا': 'ل', 'ل': 'ل',
    'ميم': 'م', 'مه': 'م', 'ما': 'م', 'م': 'م',
    'نون': 'ن', 'نه': 'ن', 'نا': 'ن', 'ن': 'ن',
    'هاء': 'ه', 'هه': 'ه', 'ها': 'ه', 'ه': 'ه',
    'واو': 'و', 'وه': 'و', 'وا': 'و', 'و': 'و',
    'ياء': 'ي', 'يه': 'ي', 'ية': 'ي', 'يا': 'ي', 'ى': 'ي', 'ي': 'ي',
  };

  static final Map<String, List<String>> compounds = {
    'واويه': ['و', 'ي'], 'واوية': ['و', 'ي'], 'واوياء': ['و', 'ي'],
    'واودال': ['و', 'د'], 'واوقاف': ['و', 'q'], 'أوقاف': ['و', 'q'],
    'اوصاد': ['أ', 'و', 'ص'], 'أوصاد': ['أ', 'و', 'ص'],
    'راهدال': ['ر', 'د'], 'رادال': ['ر', 'د'], 'رهدال': ['ر', 'د'],
    'عينرا': ['ع', 'ر'], 'عينره': ['ع', 'ر'],
    'الفنون': ['أ', 'ن'], 'ألفنون': ['أ', 'ن'],
    'بهلام': ['ب', 'ل'], 'بالام': ['ب', 'ل'], 'بلام': ['ب', 'ل'],
    'نونواو': ['ن', 'و'], 'نونواوه': ['ن', 'و', 'ي'],
    'يهبه': ['ي', 'ب'], 'يهدال': ['ي', 'د'],
    'نوعين': ['ن', 'ع'], 'نهاء': ['ن', 'ه'],
  };

  static final Map<String, String> digitsMap = {
    'صفر': '0', 'صِفر': '0', 'زيرو': '0', 'واحد': '1', 'واحده': '1', 'واحدة': '1', 'وحد': '1',
    'اتنين': '2', 'اثنين': '2', 'إثنين': '2', 'تنين': '2', 'اثنان': '2', 'اتنان': '2',
    'تلاته': '3', 'ثلاثة': '3', 'تلات': '3', 'تلاتة': '3', 'ثلاثه': '3', 'ثلاث': '3',
    'اربعة': '4', 'اربعه': '4', 'أربعة': '4', 'أربعه': '4', 'اربع': '4', 'أربع': '4',
    'خمسه': '5', 'خمسة': '5', 'خمس': '5', 'سته': '6', 'ستة': '6', 'ست': '6',
    'سبعه': '7', 'سبعة': '7', 'سبع': '7', 'تمانيه': '8', 'ثمانية': '8', 'ثمانيه': '8', 'تمانية': '8', 'تمن': '8',
    'تسعه': '9', 'تسعة': '9', 'تسع': '9',
  };

  static final Map<String, List<String>> vehicleTypesMap = {
    'نقل عام': ['نقل عام', 'نقلي عام'], 'جراند ماكس': ['جراند ماكس', 'قراند ماكس', 'جراند مكس', 'جراند', 'قراند'],
    'تلاجة كبيرة': ['تلاجة كبيرة', 'تلاجه كبيره', 'ثلاجة كبيرة', 'ثلاجه كبيره', 'تلاجه', 'ثلاجة'],
    'هاي اس': ['هاي اس', 'هايس', 'هاي آيس', 'هايسن', 'هاي ايس', 'هاي إس'], 'فان': ['فان', 'فن', 'بان'],
    'نقل': ['نقل', 'ناقل'], 'بيك اب': ['بيك اب', 'بيك آب', 'بيكب', 'دباب'],
    'اتوبيس': ['اتوبيس', 'أتوبيس', 'باص', 'ميكروباص'], 'تويوتا': ['تويوتا', 'تيوتا', 'تايوتا'],
    'نيسان': ['نيسان', 'نسان'], 'مازدا': ['مازدا', 'مزدا'], 'هوندا': ['هوندا', 'هندا'],
    'لكزس': ['لكزس', 'لكزيس', 'لكسز'], 'سوزوكي': ['سوزوكي', 'سزوكي'],
    'هيونداي': ['هيونداي', 'هونداي', 'هينداي'], 'كيا': ['كيا'], 'جينيسيس': ['جينيسيس', 'جنسس', 'جينسس'],
    'فورد': ['فورد'], 'شيفروليه': ['شيفروليه', 'شفروليه', 'شفر'], 'جي إم سي': ['جي إم سي', 'جي ام سي', 'جيمس', 'جمس'],
    'كاديلاك': ['كاديلاك', 'كديلاك'], 'رام': ['رام'], 'هافال': ['هافال'], 'شانجان': ['شانجان', 'شنجان'],
    'جيلي': ['جيلي', 'جلي'], 'جيتور': ['جيتور'], 'إم جي': ['إم جي', 'ام جي', 'امجي'], 'شيري': ['شيري', 'شري'],
    'بي واي دي': ['بي واي دي', 'بي وايدي'], 'مرسيدس-بنز': ['مرسيدس بنز', 'مرسيدس-بنز', 'مرسيدس', 'بنز'],
    'بي إم دبليو': ['بي إم دبليو', 'بي ام دبليو', 'بي ام'], 'أودي': ['أودي', 'اودي'],
    'فولكس فاجن': ['فولكس فاجن', 'فولكس واجن', 'فولكس'], 'لاند روفر': ['لاند روفر', 'لاندروفر', 'رنج روفر'],
    'بورش': ['بورش', 'بورشه'], 'ملاكي': ['ملاكي', 'خصوصي'],
  };

  static String? extractVehicleType(String text) {
    String clean = text.trim();
    if (clean.isEmpty) return null;
    for (var entry in userWordMap.entries) {
      if (vehicleTypesMap.containsKey(entry.value) && clean.contains(entry.key)) return entry.value;
    }
    for (var entry in vehicleTypesMap.entries) {
      for (String synonym in entry.value) {
        if (clean.contains(synonym)) return entry.key;
      }
    }
    return null;
  }

  static Map<String, dynamic>? parsePlateAndType(String activeSegment, {bool isFinalResult = false}) {
    if (activeSegment.trim().isEmpty) return null;

    String normalizedVoice = normalizeFlexible(activeSegment);
    if (userLearnedMap.containsKey(normalizedVoice)) {
      var learned = userLearnedMap[normalizedVoice];
      return {
        'letters': learned['letters'],
        'digits': learned['digits'],
        'type': learned['type'] ?? '-',
        'hasExplicitType': (learned['type'] ?? '-') != '-',
        'startsWithAlefOrBaa': false,
      };
    }

    String normalized = normalizeDigits(activeSegment);
    String? detectedType = extractVehicleType(normalized);

    String textForPlate = normalized;
    if (detectedType != null && vehicleTypesMap.containsKey(detectedType)) {
      for (String syn in vehicleTypesMap[detectedType]!) textForPlate = textForPlate.replaceAll(syn, ' ');
    }

    compounds.forEach((k, v) => textForPlate = textForPlate.replaceAll(k, ' ${v.join(' ')} '));
    List<String> rawTokens = textForPlate.split(RegExp(r'\s+'));
    List<String> stream = [];

    for (String token in rawTokens) {
      String w = token.replaceAll(RegExp(r'[^\u0621-\u064A0-9a-zA-Z]'), '');
      if (w.isEmpty) continue;

      if (userWordMap.containsKey(w)) {
        String fixed = userWordMap[w]!;
        if (RegExp(r'^\d+$').hasMatch(fixed)) {
          for (int i = 0; i < fixed.length; i++) stream.add(fixed[i]);
          continue;
        } else if (lettersMap.containsKey(fixed)) {
          stream.add(lettersMap[fixed]!);
          continue;
        } else if (fixed.length == 1) {
          stream.add(fixed);
          continue;
        }
      }

      if (digitsMap.containsKey(w)) {
        stream.add(digitsMap[w]!);
      } else if (RegExp(r'^\d+$').hasMatch(w)) {
        for (int i = 0; i < w.length; i++) stream.add(w[i]);
      } else if (lettersMap.containsKey(w)) {
        stream.add(lettersMap[w]!);
      } else if (w.length == 1 && RegExp(r'[\u0621-\u064Aa-zA-Z]').hasMatch(w)) {
        stream.add(w);
      }
    }

    for (int i = stream.length - 1; i >= 0; i--) {
      if (RegExp(r'^\d$').hasMatch(stream[i])) {
        int dEnd = i;
        int dStart = i;
        while (dStart - 1 >= 0 && RegExp(r'^\d$').hasMatch(stream[dStart - 1])) dStart--;

        int numDigits = dEnd - dStart + 1;
        int minRequiredDigits = isFinalResult ? 3 : 4;

        if (numDigits >= minRequiredDigits) {
          String digitsStr = stream.sublist(dStart, dStart + (numDigits > 4 ? 4 : numDigits)).join('');
          List<String> lettersFound = [];
          for (int j = dStart - 1; j >= 0 && lettersFound.length < 3; j--) {
            if (RegExp(r'^[a-zA-Z\u0621-\u064A]$').hasMatch(stream[j])) {
              String l = stream[j];
              lettersFound.insert(0, l == 'q' ? 'ق' : l);
            } else break;
          }

          int minRequiredLetters = isFinalResult ? 2 : 3;
          if (lettersFound.length >= minRequiredLetters) {
            String firstL = lettersFound.first;
            bool startsWithAorB = (firstL == 'أ' || firstL == 'ا' || firstL == 'إ' || firstL == 'ب');
            return {
              'letters': lettersFound.join(' '),
              'digits': digitsStr,
              'type': detectedType ?? '-',
              'hasExplicitType': detectedType != null,
              'startsWithAlefOrBaa': startsWithAorB,
            };
          }
        }
        i = dStart;
      }
    }
    return null;
  }

  static String normalizeDigits(String input) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) input = input.replaceAll(ar[i], en[i]);
    return input;
  }

  static String normalizeFlexible(String input) {
    String res = normalizeDigits(input.trim());
    res = res.replaceAll(RegExp(r'[أإآا]'), 'ا');
    res = res.replaceAll(RegExp(r'[يى]'), 'ي');
    res = res.replaceAll(RegExp(r'[ةه]'), 'ه');
    res = res.replaceAll(RegExp(r'\s+'), '');
    return res;
  }
}
