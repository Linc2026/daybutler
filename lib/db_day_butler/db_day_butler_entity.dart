import 'dart:convert';
class Person {
  final int? id;
  final String name;
  final String relationship;
  final String? avatarPath;
  final String? notes;
  final bool isPinned;
  final String? pinnedAt;
  final double? annualGiftBudget;
  final String createdAt;
  const Person({
    this.id,
    required this.name,
    required this.relationship,
    this.avatarPath,
    this.notes,
    this.isPinned = false,
    this.pinnedAt,
    this.annualGiftBudget,
    required this.createdAt,
  });
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as int?,
      name: map['name'] as String,
      relationship: map['relationship'] as String,
      avatarPath: map['avatar_path'] as String?,
      notes: map['notes'] as String?,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      pinnedAt: map['pinned_at'] as String?,
      annualGiftBudget: (map['annual_gift_budget'] as num?)?.toDouble(),
      createdAt: map['created_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'relationship': relationship,
      'avatar_path': avatarPath,
      'notes': notes,
      'is_pinned': isPinned ? 1 : 0,
      'pinned_at': pinnedAt,
      'annual_gift_budget': annualGiftBudget,
      'created_at': createdAt,
    };
  }
}
class SpecialDate {
  final int? id;
  final int personId;
  final String type;
  final String? customName;
  final String date;
  final bool repeatYearly;
  final String reminderDays;
  final String reminderTime;
  final bool cakeReminderEnabled;
  final int cakeReminderDaysBefore;
  final String cakeReminderTime;
  final bool flowerReminderEnabled;
  final int flowerReminderDaysBefore;
  final String flowerReminderTime;
  final String prepChecklist;
  final String createdAt;
  const SpecialDate({
    this.id,
    required this.personId,
    required this.type,
    this.customName,
    required this.date,
    this.repeatYearly = false,
    this.reminderDays = '[1]',
    this.reminderTime = '09:00',
    this.cakeReminderEnabled = false,
    this.cakeReminderDaysBefore = 3,
    this.cakeReminderTime = '09:00',
    this.flowerReminderEnabled = false,
    this.flowerReminderDaysBefore = 2,
    this.flowerReminderTime = '09:00',
    this.prepChecklist =
        '{"gift":false,"cake":false,"flower":false,"wish":false}',
    required this.createdAt,
  });
  List<int> get reminderDaysList {
    try {
      return (jsonDecode(reminderDays) as List<dynamic>)
          .map((e) => e as int)
          .toList();
    } catch (_) {
      return [];
    }
  }
  Map<String, bool> get prepChecklistMap {
    try {
      final map = jsonDecode(prepChecklist) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v == true));
    } catch (_) {
      return {'gift': false, 'cake': false, 'flower': false, 'wish': false};
    }
  }
  factory SpecialDate.fromMap(Map<String, dynamic> map) {
    return SpecialDate(
      id: map['id'] as int?,
      personId: map['person_id'] as int,
      type: map['type'] as String,
      customName: map['custom_name'] as String?,
      date: map['date'] as String,
      repeatYearly: (map['repeat_yearly'] as int? ?? 0) == 1,
      reminderDays: map['reminder_days'] as String? ?? '[1]',
      reminderTime: map['reminder_time'] as String? ?? '09:00',
      cakeReminderEnabled: (map['cake_reminder_enabled'] as int? ?? 0) == 1,
      cakeReminderDaysBefore: map['cake_reminder_days_before'] as int? ?? 3,
      cakeReminderTime: map['cake_reminder_time'] as String? ?? '09:00',
      flowerReminderEnabled: (map['flower_reminder_enabled'] as int? ?? 0) == 1,
      flowerReminderDaysBefore:
          map['flower_reminder_days_before'] as int? ?? 2,
      flowerReminderTime: map['flower_reminder_time'] as String? ?? '09:00',
      prepChecklist: map['prep_checklist'] as String? ??
          '{"gift":false,"cake":false,"flower":false,"wish":false}',
      createdAt: map['created_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'type': type,
      'custom_name': customName,
      'date': date,
      'repeat_yearly': repeatYearly ? 1 : 0,
      'reminder_days': reminderDays,
      'reminder_time': reminderTime,
      'cake_reminder_enabled': cakeReminderEnabled ? 1 : 0,
      'cake_reminder_days_before': cakeReminderDaysBefore,
      'cake_reminder_time': cakeReminderTime,
      'flower_reminder_enabled': flowerReminderEnabled ? 1 : 0,
      'flower_reminder_days_before': flowerReminderDaysBefore,
      'flower_reminder_time': flowerReminderTime,
      'prep_checklist': prepChecklist,
      'created_at': createdAt,
    };
  }
}
class Gift {
  final int? id;
  final int personId;
  final String name;
  final double? price;
  final String status;
  final int? occasionId;
  final String? link;
  final String? notes;
  final String? giftedDate;
  final String? reaction;
  final String createdAt;
  const Gift({
    this.id,
    required this.personId,
    required this.name,
    this.price,
    this.status = 'Idea',
    this.occasionId,
    this.link,
    this.notes,
    this.giftedDate,
    this.reaction,
    required this.createdAt,
  });
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as int?,
      personId: map['person_id'] as int,
      name: map['name'] as String,
      price: (map['price'] as num?)?.toDouble(),
      status: map['status'] as String,
      occasionId: map['occasion_id'] as int?,
      link: map['link'] as String?,
      notes: map['notes'] as String?,
      giftedDate: map['gifted_date'] as String?,
      reaction: map['reaction'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'name': name,
      'price': price,
      'status': status,
      'occasion_id': occasionId,
      'link': link,
      'notes': notes,
      'gifted_date': giftedDate,
      'reaction': reaction,
      'created_at': createdAt,
    };
  }
}
class GiftGuideItem {
  final int? id;
  final String name;
  final int priceMin;
  final int priceMax;
  final String forTags;
  final String occasionTags;
  final String description;
  const GiftGuideItem({
    this.id,
    required this.name,
    required this.priceMin,
    required this.priceMax,
    required this.forTags,
    required this.occasionTags,
    required this.description,
  });
  List<String> get forTagsList {
    try {
      return (jsonDecode(forTags) as List<dynamic>).cast<String>();
    } catch (_) {
      return [];
    }
  }
  List<String> get occasionTagsList {
    try {
      return (jsonDecode(occasionTags) as List<dynamic>).cast<String>();
    } catch (_) {
      return [];
    }
  }
  factory GiftGuideItem.fromMap(Map<String, dynamic> map) {
    return GiftGuideItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      priceMin: map['price_min'] as int,
      priceMax: map['price_max'] as int,
      forTags: map['for_tags'] as String,
      occasionTags: map['occasion_tags'] as String,
      description: map['description'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price_min': priceMin,
      'price_max': priceMax,
      'for_tags': forTags,
      'occasion_tags': occasionTags,
      'description': description,
    };
  }
}
class FlowerRecord {
  final int? id;
  final int personId;
  final String flowers;
  final String date;
  final int? occasionId;
  final String? occasionNote;
  final String? notes;
  final String createdAt;
  const FlowerRecord({
    this.id,
    required this.personId,
    required this.flowers,
    required this.date,
    this.occasionId,
    this.occasionNote,
    this.notes,
    required this.createdAt,
  });
  factory FlowerRecord.fromMap(Map<String, dynamic> map) {
    return FlowerRecord(
      id: map['id'] as int?,
      personId: map['person_id'] as int,
      flowers: map['flowers'] as String,
      date: map['date'] as String,
      occasionId: map['occasion_id'] as int?,
      occasionNote: map['occasion_note'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'flowers': flowers,
      'date': date,
      'occasion_id': occasionId,
      'occasion_note': occasionNote,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
class FlowerLanguageItem {
  final int? id;
  final String name;
  final String emoji;
  final String shortMeaning;
  final String fullMeaning;
  final String? colorVariants;
  final String? tips;
  final String occasions;
  const FlowerLanguageItem({
    this.id,
    required this.name,
    required this.emoji,
    required this.shortMeaning,
    required this.fullMeaning,
    this.colorVariants,
    this.tips,
    required this.occasions,
  });
  List<String> get occasionsList {
    try {
      return (jsonDecode(occasions) as List<dynamic>).cast<String>();
    } catch (_) {
      return [];
    }
  }
  factory FlowerLanguageItem.fromMap(Map<String, dynamic> map) {
    return FlowerLanguageItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      shortMeaning: map['short_meaning'] as String,
      fullMeaning: map['full_meaning'] as String,
      colorVariants: map['color_variants'] as String?,
      tips: map['tips'] as String?,
      occasions: map['occasions'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'emoji': emoji,
      'short_meaning': shortMeaning,
      'full_meaning': fullMeaning,
      'color_variants': colorVariants,
      'tips': tips,
      'occasions': occasions,
    };
  }
}
class WishTemplate {
  final int? id;
  final String category;
  final String content;
  final bool isBuiltIn;
  final bool isFavorite;
  final String createdAt;
  const WishTemplate({
    this.id,
    required this.category,
    required this.content,
    this.isBuiltIn = false,
    this.isFavorite = false,
    required this.createdAt,
  });
  factory WishTemplate.fromMap(Map<String, dynamic> map) {
    return WishTemplate(
      id: map['id'] as int?,
      category: map['category'] as String,
      content: map['content'] as String,
      isBuiltIn: (map['is_built_in'] as int? ?? 0) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'content': content,
      'is_built_in': isBuiltIn ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt,
    };
  }
  WishTemplate copyWith({
    int? id,
    String? category,
    String? content,
    bool? isBuiltIn,
    bool? isFavorite,
    String? createdAt,
  }) {
    return WishTemplate(
      id: id ?? this.id,
      category: category ?? this.category,
      content: content ?? this.content,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
