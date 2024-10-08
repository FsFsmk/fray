enum Language { ar, en }

enum CalendarView { monthly, weekly, daily }

Language stringToLanguage(String languageStr) {
  return Language.values.firstWhere(
    (l) => l.toString().split('.').last == languageStr,
    orElse: () => Language.en,
  );
}
