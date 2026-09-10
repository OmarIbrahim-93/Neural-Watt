import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as developer;

class AdviceTranslator {
  static final Map<String, String> _titleMap = {
    "Reduce Tomorrow's Waste": "تقليل هدر الغد",
    "Reduce This Week's Waste": "تقليل هدر هذا الأسبوع",
    "Reduce This Month's Waste": "تقليل هدر هذا الشهر",
    "Reduce This Quarter's Waste": "تقليل هدر هذا الربع",

    "Reduce Tomorrow's Consumption": "تقليل استهلاك الغد",
    "Reduce This Week's Consumption": "تقليل استهلاك هذا الأسبوع",
    "Reduce This Month's Consumption": "تقليل استهلاك هذا الشهر",
    "Reduce This Quarter's Consumption": "تقليل استهلاك هذا الربع",

    "Maintain Tomorrow's Efficiency": "الحفاظ على كفاءة الغد",
    "Maintain This Week's Efficiency": "الحفاظ على كفاءة هذا الأسبوع",
    "Maintain This Month's Efficiency": "الحفاظ على كفاءة هذا الشهر",
    "Maintain This Quarter's Efficiency": "الحفاظ على كفاءة هذا الربع",

    "Check Your Equipment": "افحص معداتك",

    "Daily Saving Tip": "نصيحة توفير يومية",
    "Weekly Saving Tip": "نصيحة توفير أسبوعية",
    "Monthly Saving Tip": "نصيحة توفير شهرية",
    "Quarterly Saving Tip": "نصيحة توفير ربع سنوية",
  };

  static final Map<String, String> _equipmentMap = {
    "refrigerator": "الثلاجة",
    "deep freezer": "الفريزر",
    "washing machine": "الغسالة",
    "dishwasher": "غسالة الأطباق",
    "electric kettle": "الغلاية الكهربائية",
    "water heater": "سخان المياه",
    "boiler": "الغلاية",
    "air conditioner": "مكيف الهواء",
    "electric oven": "الفرن الكهربائي",
    "microwave": "الميكروويف",
    "television": "التلفزيون",
    "water pump": "مضخة المياه",
    "lighting": "الإضاءة",
    "taps": "الصنابير",
    "shower": "الدش",
    "toilet": "المرحاض",
    "water tank": "خزان المياه",
    "garden irrigation": "ري الحديقة",
    "gas cooker": "بوتاجاز الغاز",
    "gas oven": "فرن الغاز",
    "gas water heater": "سخان مياه غاز",
    "gas boiler": "غلاية غاز",
    "central heating equipment": "معدات التدفئة المركزية",
    "bakery oven": "فرن المخبز",
    "dough mixer": "خلاط العجين",
    "dough kneader": "عجانة العجين",
    "proofing machine": "آلة التخمير",
    "ventilation system": "نظام التهوية",
    "cleaning equipment": "معدات التنظيف",
    "sinks": "الأحواض",
    "dough preparation equipment": "معدات تحضير العجين",
    "dishwashing equipment": "معدات غسيل الأطباق",
    "gas burner": "موقد الغاز",
    "heating equipment": "معدات التدفئة",
    "desktop computers": "أجهزة الكمبيوتر المكتبية",
    "laptops": "أجهزة الكمبيوتر المحمولة",
    "printers": "الطابعات",
    "photocopiers": "آلات التصوير",
    "water cooler": "مبرد المياه",
    "server/network equipment": "معدات الخادم/الشبكة",
    "cleaning systems": "أنظمة التنظيف",
    "dryers": "المجففات",
    "kitchen ovens": "أفران المطبخ",
    "elevators": "المصاعد",
    "swimming-pool systems": "أنظمة حمامات السباحة",
    "irrigation systems": "أنظمة الري",
    "commercial burners": "المواقد التجارية",
    "heating systems": "أنظمة التدفئة",
    "commercial oven": "الفرن التجاري",
    "electric fryer": "القلاية الكهربائية",
    "food warmer": "سخان الطعام",
    "exhaust hood": "شفاط العادم",
    "kitchen sinks": "أحواض المطبخ",
    "food-cleaning stations": "محطات تنظيف الطعام",
    "gas fryer": "قلاية الغاز",
    "projectors": "أجهزة العرض",
    "drinking-water systems": "أنظمة مياه الشرب",
    "kitchen cooker": "طباخ المطبخ",
    "display refrigerators": "ثلاجات العرض",
    "commercial freezers": "المجمدات التجارية",
    "refrigeration systems": "أنظمة التبريد",
    "electric doors": "الأبواب الكهربائية",
    "pos systems": "أنظمة نقاط البيع",
    "food-preparation equipment": "معدات تحضير الطعام",
    "general equipment": "معدات عامة",
  };

  static String translateTitle(BuildContext context, String englishTitle) {
    if (context.locale.languageCode != 'ar') return englishTitle;
    return _titleMap[englishTitle.trim()] ?? englishTitle;
  }

  static String _translateEquipment(String englishEqStr) {
    String translated = englishEqStr;
    _equipmentMap.forEach((eng, ar) {
      translated = translated.replaceAll(eng, ar);
      translated = translated.replaceAll(eng.toUpperCase(), ar);
      // capitalize first letter handle
      final cap = eng[0].toUpperCase() + eng.substring(1);
      translated = translated.replaceAll(cap, ar);
    });
    // translate "and" in the list
    translated = translated.replaceAll(", and ", " و");
    return translated;
  }

  // Regex patterns match the single-line string (with "\n\n" replaced by spaces).
  // The value is the Arabic translation (optionally with \n\n).
  static Map<RegExp, String> get _messageTemplates => {
    RegExp(
      r'No measurable waste is predicted for the (.*?)\. Maintain your current efficiency and keep monitoring your usage to ensure no unnecessary consumption\.',
    ): 'لا يتوقع أي هدر قابل للقياس خلال \\1. حافظ على كفاءتك الحالية واستمر في مراقبة استهلاكك لضمان عدم استهلاك غير ضروري.',

    RegExp(
      r'Your predicted waste is low \((.*?)%, (.*?) (.*?)\)\. To prevent this waste, which could cost (.*?), turn off unused equipment such as the (.*?)\. Reduce standby consumption and avoid unnecessary operation\.',
    ): 'الهدر المتوقع لديك منخفض (\\1%, \\2 \\3).\n\nلمنع هذا الهدر، والذي قد يكلفك \\4، قم بإيقاف تشغيل المعدات غير المستخدمة مثل \\5.\n\nقلل من استهلاك وضع الاستعداد وتجنب التشغيل غير الضروري.',

    RegExp(
      r'Your predicted waste is moderate \((.*?)%, (.*?) (.*?)\), with an estimated cost of (.*?)\. Reduce unnecessary operating hours and optimize schedules for equipment like the (.*?)\. Turn off equipment when not required\.',
    ): 'الهدر المتوقع لديك معتدل (\\1%, \\2 \\3)، بتكلفة تقديرية \\4.\n\nقلل ساعات التشغيل غير الضرورية وحسّن جداول المعدات مثل \\5.\n\nأوقف تشغيل المعدات عند عدم الحاجة.',

    RegExp(
      r'Your predicted waste is high \((.*?)%, (.*?) (.*?)\), representing a potential cost of (.*?)\. Focus on high-consumption equipment such as the (.*?)\. Review operating schedules, perform preventive maintenance, and check for unnecessary standby consumption\.',
    ): 'الهدر المتوقع لديك مرتفع (\\1%, \\2 \\3)، ويمثل تكلفة محتملة تبلغ \\4.\n\nركز على المعدات ذات الاستهلاك العالي مثل \\5.\n\nراجع جداول التشغيل، وقم بإجراء صيانة وقائية، وتحقق من استهلاك وضع الاستعداد غير الضروري.',

    RegExp(
      r'Your predicted waste is very high \((.*?)%, (.*?) (.*?)\), which could cost you (.*?)\. Prioritize checking the (.*?)\. Identify the main sources of waste and take steps to reduce unnecessary consumption immediately\.',
    ): 'الهدر المتوقع لديك مرتفع جداً (\\1%, \\2 \\3)، والذي قد يكلفك \\4.\n\nأعط الأولوية لفحص \\5.\n\nحدد المصادر الرئيسية للهدر واتخذ خطوات لتقليل الاستهلاك غير الضروري فوراً.',

    RegExp(
      r'Your predicted waste is extremely high \((.*?)%, (.*?) (.*?)\)\. The predicted waste represents an estimated cost of (.*?)\. Take immediate action: investigate your equipment such as the (.*?), implement operational improvements, and monitor your usage closely\.',
    ): 'الهدر المتوقع لديك مرتفع للغاية (\\1%, \\2 \\3).\n\nيمثل الهدر المتوقع تكلفة تقديرية تبلغ \\4.\n\nاتخذ إجراءً فورياً: افحص معداتك مثل \\5، ونفذ تحسينات تشغيلية، وراقب استهلاكك عن كثب.',

    RegExp(
      r'Your predicted waste is exceptionally high \((.*?)%, (.*?) (.*?)\), representing a severe potential cost of (.*?)\. Investigate equipment operation and verify meter readings\. Look for abnormal behavior in the (.*?)\. If this continues, we recommend inspection by a qualified professional\.',
    ): 'الهدر المتوقع لديك استثنائي ومفرط (\\1%, \\2 \\3)، ويمثل تكلفة محتملة شديدة تبلغ \\4.\n\nافحص تشغيل المعدات وتحقق من قراءات العداد. ابحث عن سلوك غير طبيعي في \\5.\n\nإذا استمر هذا، نوصي بالفحص من قبل متخصص مؤهل.',

    RegExp(
      r'You are currently in Category 1 for this horizon, with a predicted consumption of (.*?) (.*?)\. You are already in the most efficient category\. Keep up the good work and maintain your efficient habits to avoid higher costs\.',
    ): 'أنت حالياً في الفئة 1 لهذه الفترة، باستهلاك متوقع يبلغ \\1 \\2.\n\nأنت بالفعل في الفئة الأكثر كفاءة.\n\nواصل العمل الجيد وحافظ على عاداتك الفعالة لتجنب ارتفاع التكاليف.',

    RegExp(
      r'Your predicted consumption is (.*?) (.*?) \(Category (.*?)\)\. You need to reduce your consumption by approximately (.*?) (.*?) to reach Category (.*?)\. Consider optimizing the usage of the (.*?)\. Reducing this predicted waste could help lower your cost by approximately (.*?)\.',
    ): 'استهلاكك المتوقع هو \\1 \\2 (الفئة \\3).\n\nتحتاج إلى تقليل استهلاكك بحوالي \\4 \\5 للوصول إلى الفئة \\6.\n\nضع في اعتبارك تحسين استخدام \\7. تقليل هذا الهدر المتوقع يمكن أن يساعد في خفض تكلفتك بحوالي \\8.',

    RegExp(
      r'Your predicted consumption is (.*?) (.*?) \(Category (.*?)\)\. To reduce consumption toward Category (.*?), consider optimizing the usage of the (.*?)\. Reducing this predicted waste could help lower your cost by approximately (.*?)\.',
    ): 'استهلاكك المتوقع هو \\1 \\2 (الفئة \\3).\n\nلتقليل الاستهلاك نحو الفئة \\4، ضع في اعتبارك تحسين استخدام \\5.\n\nتقليل هذا الهدر المتوقع يمكن أن يساعد في خفض تكلفتك بحوالي \\6.',

    RegExp(
      r'Based on a predicted waste of (.*?) (.*?), this could indicate inefficient operation\. Consider checking equipment such as the (.*?)\. It may be useful to inspect them for faults or incorrect settings\. If the abnormal consumption continues, have the equipment inspected by a qualified technician\.',
    ): 'بناءً على هدر متوقع يبلغ \\1 \\2، قد يشير ذلك إلى تشغيل غير فعال.\n\nضع في اعتبارك فحص معدات مثل \\3. قد يكون من المفيد فحصها بحثاً عن أعطال أو إعدادات غير صحيحة.\n\nإذا استمر الاستهلاك غير الطبيعي، اطلب من فني مؤهل فحص المعدات.',
  };

  // Smart Advice sentences mapping
  static Map<String, String> get _smartAdviceMap => {
    "Focus on immediate actions: Turn off unnecessary equipment before leaving, adjust equipment settings for tomorrow, and prevent unnecessary standby consumption.":
        "ركز على الإجراءات الفورية: أوقف تشغيل المعدات غير الضرورية قبل المغادرة، واضبط إعدادات المعدات للغد، وامنع استهلاك وضع الاستعداد غير الضروري.",

    "Review weekly operating behavior: Identify equipment that remains active unnecessarily, create a weekly shutdown routine, and schedule preventive checks.":
        "راجع سلوك التشغيل الأسبوعي: حدد المعدات التي تظل نشطة دون داع، وقم بإنشاء روتين إغلاق أسبوعي، وجدولة الفحوصات الوقائية.",

    "Focus on recurring consumption patterns: Set a monthly consumption target, optimize operating schedules, and perform preventive maintenance on high-consumption equipment.":
        "ركز على أنماط الاستهلاك المتكررة: حدد هدف استهلاك شهري، وحسّن جداول التشغيل، وقم بصيانة وقائية للمعدات عالية الاستهلاك.",

    "Focus on long-term optimization: Perform a utility consumption review, establish quarterly consumption targets, and consider strategic operational improvements.":
        "ركز على التحسين طويل الأمد: قم بمراجعة استهلاك المرافق، وحدد أهداف استهلاك ربع سنوية، وفكر في تحسينات تشغيلية استراتيجية.",

    " As a small business, prioritize simple operational changes, turning off unused equipment, and low-cost improvements.":
        " كشركة صغيرة، أعط الأولوية للتغييرات التشغيلية البسيطة، وإيقاف تشغيل المعدات غير المستخدمة، والتحسينات منخفضة التكلفة.",

    " For a medium-sized operation, focus on equipment scheduling, employee awareness, and monitoring high-consumption equipment.":
        " للعمليات متوسطة الحجم، ركز على جدولة المعدات، وتوعية الموظفين، ومراقبة المعدات عالية الاستهلاك.",

    " As a large facility, implement systematic utility management, equipment-level monitoring, automated controls, and department-level consumption tracking.":
        " كمنشأة كبيرة، نفذ إدارة منهجية للمرافق، ومراقبة على مستوى المعدات، وضوابط آلية، وتتبع الاستهلاك على مستوى الأقسام.",

    " For your household, focus on daily habits, household appliances, and lighting.":
        " بالنسبة لمنزلك، ركز على العادات اليومية، والأجهزة المنزلية، والإضاءة.",
  };

  static String translateMessage(BuildContext context, String englishMessage) {
    if (context.locale.languageCode != 'ar') return englishMessage;

    // The backend uses `.\n\n` instead of just `. ` in some places.
    // Replace \n\n with space for easier regex matching.
    String flatMessage = englishMessage.replaceAll('\n\n', ' ');

    // 1. Try to match full templates (Waste, Consumption, Equipment)
    for (final entry in _messageTemplates.entries) {
      if (entry.key.hasMatch(flatMessage)) {
        final match = entry.key.firstMatch(flatMessage)!;
        String translated = entry.value;

        // Replace capturing groups (\1, \2, etc.)
        for (int i = 1; i <= match.groupCount; i++) {
          String groupValue = match.group(i) ?? '';

          // If the group contains equipment names, translate them
          if (groupValue.contains(',') ||
              groupValue.contains('and') ||
              _equipmentMap.keys.any(
                (k) => groupValue.toLowerCase().contains(k),
              )) {
            groupValue = _translateEquipment(groupValue);
          } else {
            // It might be a unit ('kWh' -> 'كيلوواط/ساعة')
            if (groupValue == 'kWh') {
              groupValue = 'كيلوواط/ساعة';
            } else if (groupValue == 'm³') {
              groupValue = 'م³';
            } else if (groupValue.endsWith(' LE')) {
              groupValue = groupValue.replaceAll(' LE', ' ج.م');
            }
          }

          translated = translated.replaceAll('\\$i', groupValue);
        }
        return translated;
      }
    }

    // 2. Try Smart Advice (which are concatenated strings)
    bool isSmartAdvice = false;
    String smartTranslated = flatMessage;
    for (final entry in _smartAdviceMap.entries) {
      if (smartTranslated.contains(entry.key)) {
        isSmartAdvice = true;
        smartTranslated = smartTranslated.replaceAll(entry.key, entry.value);
      }
    }

    if (isSmartAdvice) {
      // Re-insert \n\n for formatting if it was replaced
      return smartTranslated.replaceAll('. ', '.\n\n');
    }

    // 3. Fallback
    developer.log(
      'AdviceTranslator Warning: Could not find Arabic translation for message: $englishMessage',
      name: 'AdviceTranslator',
    );
    return englishMessage;
  }
}
