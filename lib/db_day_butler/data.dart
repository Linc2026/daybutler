import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_day_butler_entity.dart';
import 'db_day_butler_seed.dart';
class DayButlerDatabase extends GetxService {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'day_butler.db');
    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await _ensureWishFavoriteColumn(db);
      },
    );
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _ensureWishFavoriteColumn(db);
    }
  }
  Future<void> _ensureWishFavoriteColumn(Database db) async {
    try {
      final cols = await db.rawQuery('PRAGMA table_info(wish_templates)');
      final hasFavorite = cols.any((c) => c['name'] == 'is_favorite');
      if (!hasFavorite) {
        await db.execute(
          'ALTER TABLE wish_templates ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
        );
      }
    } catch (e) {
      print('Error ensuring wish favorite column: $e');
    }
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE people (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        avatar_path TEXT,
        notes TEXT,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        pinned_at TEXT,
        annual_gift_budget REAL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE special_dates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        custom_name TEXT,
        date TEXT NOT NULL,
        repeat_yearly INTEGER NOT NULL DEFAULT 0,
        reminder_days TEXT NOT NULL DEFAULT '[1]',
        reminder_time TEXT NOT NULL DEFAULT '09:00',
        cake_reminder_enabled INTEGER NOT NULL DEFAULT 0,
        cake_reminder_days_before INTEGER NOT NULL DEFAULT 3,
        cake_reminder_time TEXT NOT NULL DEFAULT '09:00',
        flower_reminder_enabled INTEGER NOT NULL DEFAULT 0,
        flower_reminder_days_before INTEGER NOT NULL DEFAULT 2,
        flower_reminder_time TEXT NOT NULL DEFAULT '09:00',
        prep_checklist TEXT NOT NULL DEFAULT '{"gift":false,"cake":false,"flower":false,"wish":false}',
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL,
        status TEXT NOT NULL DEFAULT 'Idea',
        occasion_id INTEGER,
        link TEXT,
        notes TEXT,
        gifted_date TEXT,
        reaction TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people (id) ON DELETE CASCADE,
        FOREIGN KEY (occasion_id) REFERENCES special_dates (id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE gift_guide_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price_min INTEGER NOT NULL,
        price_max INTEGER NOT NULL,
        for_tags TEXT NOT NULL,
        occasion_tags TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE flower_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_id INTEGER NOT NULL,
        flowers TEXT NOT NULL,
        date TEXT NOT NULL,
        occasion_id INTEGER,
        occasion_note TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people (id) ON DELETE CASCADE,
        FOREIGN KEY (occasion_id) REFERENCES special_dates (id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE flower_language_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        short_meaning TEXT NOT NULL,
        full_meaning TEXT NOT NULL,
        color_variants TEXT,
        tips TEXT,
        occasions TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE wish_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        content TEXT NOT NULL,
        is_built_in INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_special_dates_person_id ON special_dates(person_id)',
    );
    await db.execute(
      'CREATE INDEX idx_gifts_person_id ON gifts(person_id)',
    );
    await db.execute(
      'CREATE INDEX idx_flower_records_person_id ON flower_records(person_id)',
    );
    await db.execute(
      'CREATE INDEX idx_wish_templates_category ON wish_templates(category)',
    );
    await seedDayButlerDatabase(db);
  }
  Future<List<Person>> getPeople() async {
    try {
      final db = await database;
      final maps = await db.query(
        'people',
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map(Person.fromMap).toList();
    } catch (e) {
      print('Error getting people: $e');
      return [];
    }
  }
  Future<Person?> getPerson(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'people',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Person.fromMap(maps.first);
    } catch (e) {
      print('Error getting person: $e');
      return null;
    }
  }
  Future<int?> insertPerson(Person person) async {
    try {
      final db = await database;
      return await db.insert('people', person.toMap());
    } catch (e) {
      print('Error inserting person: $e');
      return null;
    }
  }
  Future<int?> updatePerson(Person person) async {
    try {
      final db = await database;
      return await db.update(
        'people',
        person.toMap(),
        where: 'id = ?',
        whereArgs: [person.id],
      );
    } catch (e) {
      print('Error updating person: $e');
      return null;
    }
  }
  Future<int?> deletePerson(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'people',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting person: $e');
      return null;
    }
  }
  Future<List<SpecialDate>> getSpecialDates() async {
    try {
      final db = await database;
      final maps = await db.query(
        'special_dates',
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map(SpecialDate.fromMap).toList();
    } catch (e) {
      print('Error getting special dates: $e');
      return [];
    }
  }
  Future<List<SpecialDate>> getSpecialDatesByPersonId(int personId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'special_dates',
        where: 'person_id = ?',
        whereArgs: [personId],
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map(SpecialDate.fromMap).toList();
    } catch (e) {
      print('Error getting special dates by person: $e');
      return [];
    }
  }
  Future<SpecialDate?> getSpecialDate(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'special_dates',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return SpecialDate.fromMap(maps.first);
    } catch (e) {
      print('Error getting special date: $e');
      return null;
    }
  }
  Future<SpecialDate?> getBirthdayByPersonId(int personId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'special_dates',
        where: 'person_id = ? AND type = ?',
        whereArgs: [personId, 'Birthday'],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return SpecialDate.fromMap(maps.first);
    } catch (e) {
      print('Error getting birthday by person: $e');
      return null;
    }
  }
  Future<int?> insertSpecialDate(SpecialDate specialDate) async {
    try {
      final db = await database;
      return await db.insert('special_dates', specialDate.toMap());
    } catch (e) {
      print('Error inserting special date: $e');
      return null;
    }
  }
  Future<int?> updateSpecialDate(SpecialDate specialDate) async {
    try {
      final db = await database;
      return await db.update(
        'special_dates',
        specialDate.toMap(),
        where: 'id = ?',
        whereArgs: [specialDate.id],
      );
    } catch (e) {
      print('Error updating special date: $e');
      return null;
    }
  }
  Future<int?> deleteSpecialDate(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'special_dates',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting special date: $e');
      return null;
    }
  }
  Future<List<Gift>> getGifts() async {
    try {
      final db = await database;
      final maps = await db.query(
        'gifts',
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map(Gift.fromMap).toList();
    } catch (e) {
      print('Error getting gifts: $e');
      return [];
    }
  }
  Future<List<Gift>> getGiftsByPersonId(int personId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'gifts',
        where: 'person_id = ?',
        whereArgs: [personId],
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map(Gift.fromMap).toList();
    } catch (e) {
      print('Error getting gifts by person: $e');
      return [];
    }
  }
  Future<Gift?> getGift(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'gifts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Gift.fromMap(maps.first);
    } catch (e) {
      print('Error getting gift: $e');
      return null;
    }
  }
  Future<int?> insertGift(Gift gift) async {
    try {
      final db = await database;
      return await db.insert('gifts', gift.toMap());
    } catch (e) {
      print('Error inserting gift: $e');
      return null;
    }
  }
  Future<int?> updateGift(Gift gift) async {
    try {
      final db = await database;
      return await db.update(
        'gifts',
        gift.toMap(),
        where: 'id = ?',
        whereArgs: [gift.id],
      );
    } catch (e) {
      print('Error updating gift: $e');
      return null;
    }
  }
  Future<int?> deleteGift(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'gifts',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting gift: $e');
      return null;
    }
  }
  Future<List<GiftGuideItem>> getGiftGuideItems() async {
    try {
      final db = await database;
      final maps = await db.query('gift_guide_items', orderBy: 'id ASC');
      return maps.map(GiftGuideItem.fromMap).toList();
    } catch (e) {
      print('Error getting gift guide items: $e');
      return [];
    }
  }
  Future<List<FlowerRecord>> getFlowerRecords() async {
    try {
      final db = await database;
      final maps = await db.query(
        'flower_records',
        orderBy: 'date DESC, id DESC',
      );
      return maps.map(FlowerRecord.fromMap).toList();
    } catch (e) {
      print('Error getting flower records: $e');
      return [];
    }
  }
  Future<List<FlowerRecord>> getFlowerRecordsByPersonId(int personId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'flower_records',
        where: 'person_id = ?',
        whereArgs: [personId],
        orderBy: 'date DESC, id DESC',
      );
      return maps.map(FlowerRecord.fromMap).toList();
    } catch (e) {
      print('Error getting flower records by person: $e');
      return [];
    }
  }
  Future<FlowerRecord?> getFlowerRecord(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'flower_records',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return FlowerRecord.fromMap(maps.first);
    } catch (e) {
      print('Error getting flower record: $e');
      return null;
    }
  }
  Future<int?> insertFlowerRecord(FlowerRecord record) async {
    try {
      final db = await database;
      return await db.insert('flower_records', record.toMap());
    } catch (e) {
      print('Error inserting flower record: $e');
      return null;
    }
  }
  Future<int?> updateFlowerRecord(FlowerRecord record) async {
    try {
      final db = await database;
      return await db.update(
        'flower_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } catch (e) {
      print('Error updating flower record: $e');
      return null;
    }
  }
  Future<int?> deleteFlowerRecord(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'flower_records',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting flower record: $e');
      return null;
    }
  }
  Future<List<FlowerLanguageItem>> getFlowerLanguageItems() async {
    try {
      final db = await database;
      final maps = await db.query('flower_language_items', orderBy: 'id ASC');
      return maps.map(FlowerLanguageItem.fromMap).toList();
    } catch (e) {
      print('Error getting flower language items: $e');
      return [];
    }
  }
  Future<List<WishTemplate>> getWishTemplates() async {
    try {
      final db = await database;
      final maps = await db.query(
        'wish_templates',
        orderBy: 'is_favorite DESC, created_at DESC, id DESC',
      );
      return maps.map(WishTemplate.fromMap).toList();
    } catch (e) {
      print('Error getting wish templates: $e');
      return [];
    }
  }
  Future<List<WishTemplate>> getWishTemplatesByCategory(
    String category,
  ) async {
    try {
      final db = await database;
      final maps = await db.query(
        'wish_templates',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'is_favorite DESC, created_at DESC, id DESC',
      );
      return maps.map(WishTemplate.fromMap).toList();
    } catch (e) {
      print('Error getting wish templates by category: $e');
      return [];
    }
  }
  Future<int?> setWishFavorite(int id, bool isFavorite) async {
    try {
      final db = await database;
      return await db.update(
        'wish_templates',
        {'is_favorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error setting wish favorite: $e');
      return null;
    }
  }
  Future<WishTemplate?> getWishTemplate(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'wish_templates',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return WishTemplate.fromMap(maps.first);
    } catch (e) {
      print('Error getting wish template: $e');
      return null;
    }
  }
  Future<int?> insertWishTemplate(WishTemplate template) async {
    try {
      final db = await database;
      return await db.insert('wish_templates', template.toMap());
    } catch (e) {
      print('Error inserting wish template: $e');
      return null;
    }
  }
  Future<int?> updateWishTemplate(WishTemplate template) async {
    try {
      final db = await database;
      final data = Map<String, dynamic>.from(template.toMap())..remove('id');
      return await db.update(
        'wish_templates',
        data,
        where: 'id = ?',
        whereArgs: [template.id],
      );
    } catch (e) {
      print('Error updating wish template: $e');
      return null;
    }
  }
  Future<int?> deleteWishTemplate(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'wish_templates',
        where: 'id = ? AND is_built_in = 0',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting wish template: $e');
      return null;
    }
  }
  Future<void> clearAllUserData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('people');
      await txn.delete('wish_templates', where: 'is_built_in = 0');
    });
  }
}
