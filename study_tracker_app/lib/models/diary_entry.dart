class DiaryEntry {
  String date; // yyyy-MM-dd
  String reflections;
  String studiedToday;
  String thoughts;

  DiaryEntry({
    required this.date,
    this.reflections = '',
    this.studiedToday = '',
    this.thoughts = '',
  });

  bool get isEmpty =>
      reflections.isEmpty && studiedToday.isEmpty && thoughts.isEmpty;

  Map<String, dynamic> toJson() => {
        'date': date,
        'reflections': reflections,
        'studiedToday': studiedToday,
        'thoughts': thoughts,
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        date: json['date'] ?? '',
        reflections: json['reflections'] ?? '',
        studiedToday: json['studiedToday'] ?? '',
        thoughts: json['thoughts'] ?? '',
      );
}
