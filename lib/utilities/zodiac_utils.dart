class ZodiacUtils {
  static String getZodiacSign(DateTime birthDate) {
    int day = birthDate.day;
    int month = birthDate.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  static String getZodiacImage(String zodiacSign) {
    // You can replace these with actual image URLs or asset paths
    Map<String, String> zodiacImages = {
      'Aries': 'assets/zodiac/aries.png',
      'Taurus': 'assets/zodiac/taurus.png',
      'Gemini': 'assets/zodiac/gemini.png',
      'Cancer': 'assets/zodiac/cancer.png',
      'Leo': 'assets/zodiac/leo.png',
      'Virgo': 'assets/zodiac/virgo.png',
      'Libra': 'assets/zodiac/libra.png',
      'Scorpio': 'assets/zodiac/scorpio.png',
      'Sagittarius': 'assets/zodiac/sagittarius.png',
      'Capricorn': 'assets/zodiac/capricorn.png',
      'Aquarius': 'assets/zodiac/aquarius.png',
      'Pisces': 'assets/zodiac/pisces.png',
    };
    return zodiacImages[zodiacSign] ?? 'assets/zodiac/default.png';
  }
}