class TipOfTheDay {
  const TipOfTheDay({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.ctaText,
    required this.ctaUrl,
    required this.publishedOn,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String category;
  final String ctaText;
  final String ctaUrl;
  final DateTime? publishedOn;
  final bool isActive;
  final DateTime? createdAt;

  factory TipOfTheDay.fromMap(Map<String, dynamic> map) {
    final isActiveValue = map['is_active'];
    final active = isActiveValue is bool
        ? isActiveValue
        : isActiveValue?.toString().toLowerCase() == 'true';

    return TipOfTheDay(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      category: (map['category'] ?? 'care').toString(),
      ctaText: (map['cta_text'] ?? '').toString(),
      ctaUrl: (map['cta_url'] ?? '').toString(),
      publishedOn: DateTime.tryParse((map['published_on'] ?? '').toString()),
      isActive: active,
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
    );
  }
}
