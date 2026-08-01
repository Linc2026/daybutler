import 'dart:convert';
import 'package:sqflite/sqflite.dart';
Future<void> seedDayButlerDatabase(Database db) async {
  await _seedGiftGuideItems(db);
  await _seedFlowerLanguageItems(db);
  await _seedWishTemplates(db);
}
Future<void> _seedGiftGuideItems(Database db) async {
  final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM gift_guide_items'),
      ) ??
      0;
  if (count > 0) return;
  final items = <Map<String, dynamic>>[
    {
      'name': 'Personalized Jewelry',
      'price_min': 40,
      'price_max': 90,
      'for_tags': ['Partner'],
      'occasion_tags': ['Anniversary'],
      'description': 'A timeless piece engraved with a special date or initials.',
    },
    {
      'name': 'Couple Photo Book',
      'price_min': 30,
      'price_max': 70,
      'for_tags': ['Partner'],
      'occasion_tags': ['Anniversary', "Valentine's Day"],
      'description': 'Turn your favorite memories into a keepsake album.',
    },
    {
      'name': 'Spa Voucher',
      'price_min': 50,
      'price_max': 100,
      'for_tags': ['Partner', 'Mom'],
      'occasion_tags': ['Anniversary', 'Birthday'],
      'description': 'A relaxing escape they can book whenever they need it.',
    },
    {
      'name': 'Scented Candles Set',
      'price_min': 15,
      'price_max': 28,
      'for_tags': ['Partner', 'Friend'],
      'occasion_tags': ["Valentine's Day", 'General'],
      'description': 'Warm, cozy scents for quiet evenings at home.',
    },
    {
      'name': 'Handwritten Letter Kit',
      'price_min': 12,
      'price_max': 25,
      'for_tags': ['Partner'],
      'occasion_tags': ["Valentine's Day"],
      'description': 'Beautiful stationery for a heartfelt handwritten note.',
    },
    {
      'name': 'Skincare Gift Set',
      'price_min': 35,
      'price_max': 85,
      'for_tags': ['Mom', 'Best Friend'],
      'occasion_tags': ['Birthday'],
      'description': 'A pampering set with cleanser, serum, and moisturizer.',
    },
    {
      'name': 'Flower Subscription',
      'price_min': 40,
      'price_max': 90,
      'for_tags': ['Mom', 'Partner'],
      'occasion_tags': ['Birthday', 'Anniversary'],
      'description': 'Fresh blooms delivered monthly for lasting joy.',
    },
    {
      'name': 'Silk Scarf',
      'price_min': 30,
      'price_max': 80,
      'for_tags': ['Mom'],
      'occasion_tags': ['Birthday', 'Christmas'],
      'description': 'Elegant and versatile — perfect for any season.',
    },
    {
      'name': 'Leather Wallet',
      'price_min': 40,
      'price_max': 95,
      'for_tags': ['Dad'],
      'occasion_tags': ['Birthday', 'Christmas'],
      'description': 'Classic craftsmanship that ages beautifully.',
    },
    {
      'name': 'Whiskey Glass Set',
      'price_min': 30,
      'price_max': 70,
      'for_tags': ['Dad'],
      'occasion_tags': ['Birthday', 'Anniversary'],
      'description': 'Premium glasses for savoring special pours.',
    },
    {
      'name': 'BBQ Tool Kit',
      'price_min': 35,
      'price_max': 90,
      'for_tags': ['Dad'],
      'occasion_tags': ['Birthday', 'General'],
      'description': 'Everything needed for the next backyard cookout.',
    },
    {
      'name': 'Funny Mug',
      'price_min': 10,
      'price_max': 20,
      'for_tags': ['Best Friend', 'Friend', 'Colleague'],
      'occasion_tags': ['Birthday', 'General'],
      'description': 'A daily dose of humor with every morning coffee.',
    },
    {
      'name': 'Book by Favorite Author',
      'price_min': 15,
      'price_max': 28,
      'for_tags': ['Best Friend', 'Friend'],
      'occasion_tags': ['Birthday', 'Christmas'],
      'description': 'A thoughtful pick for the bookworm in your life.',
    },
    {
      'name': 'Skincare Mini Kit',
      'price_min': 18,
      'price_max': 29,
      'for_tags': ['Best Friend', 'Friend'],
      'occasion_tags': ['Birthday', 'General'],
      'description': 'Travel-size essentials for glowing skin on the go.',
    },
    {
      'name': 'Desk Plant',
      'price_min': 12,
      'price_max': 25,
      'for_tags': ['Colleague', 'Friend'],
      'occasion_tags': ['General', 'Birthday'],
      'description': 'A low-maintenance green friend for any workspace.',
    },
    {
      'name': 'Gourmet Snack Box',
      'price_min': 15,
      'price_max': 28,
      'for_tags': ['Colleague', 'Friend', 'Best Friend'],
      'occasion_tags': ['General', 'Christmas'],
      'description': 'Curated treats for sharing or solo snacking.',
    },
    {
      'name': 'Coffee Subscription',
      'price_min': 20,
      'price_max': 29,
      'for_tags': ['Colleague', 'Dad', 'Friend'],
      'occasion_tags': ['General', 'Birthday'],
      'description': 'Fresh beans delivered so every cup stays exciting.',
    },
    {
      'name': 'Weekend Getaway',
      'price_min': 150,
      'price_max': 400,
      'for_tags': ['Partner'],
      'occasion_tags': ['Birthday', 'Anniversary'],
      'description': 'A short escape to make unforgettable memories together.',
    },
    {
      'name': 'Smartwatch',
      'price_min': 120,
      'price_max': 350,
      'for_tags': ['Partner', 'Dad', 'Friend'],
      'occasion_tags': ['Birthday', 'Christmas'],
      'description': 'Tech that tracks health and looks great on the wrist.',
    },
    {
      'name': 'Cooking Class',
      'price_min': 100,
      'price_max': 200,
      'for_tags': ['Partner', 'Mom', 'Friend'],
      'occasion_tags': ['Birthday', 'Anniversary'],
      'description': 'Learn a new cuisine together — fun and delicious.',
    },
    {
      'name': 'Board Game',
      'price_min': 30,
      'price_max': 60,
      'for_tags': ['Friend', 'Best Friend'],
      'occasion_tags': ['General', 'Birthday', 'Christmas'],
      'description': 'Perfect for game nights and friendly competition.',
    },
    {
      'name': 'Scented Diffuser',
      'price_min': 35,
      'price_max': 75,
      'for_tags': ['Friend', 'Mom', 'Partner'],
      'occasion_tags': ['General', 'Birthday'],
      'description': 'Fill their space with a calming signature scent.',
    },
    {
      'name': 'Wine Tasting Kit',
      'price_min': 40,
      'price_max': 90,
      'for_tags': ['Friend', 'Partner', 'Dad'],
      'occasion_tags': ['General', 'Anniversary'],
      'description': 'A fun tasting experience without leaving home.',
    },
    {
      'name': 'Custom Star Map',
      'price_min': 45,
      'price_max': 80,
      'for_tags': ['Partner'],
      'occasion_tags': ['Anniversary', "Valentine's Day"],
      'description': 'The night sky from a date that means everything.',
    },
    {
      'name': 'Cozy Blanket',
      'price_min': 35,
      'price_max': 70,
      'for_tags': ['Mom', 'Partner', 'Friend'],
      'occasion_tags': ['Christmas', 'Birthday'],
      'description': 'Ultra-soft comfort for movie nights and chilly mornings.',
    },
    {
      'name': 'Wireless Earbuds',
      'price_min': 50,
      'price_max': 150,
      'for_tags': ['Friend', 'Best Friend', 'Colleague'],
      'occasion_tags': ['Birthday', 'Christmas'],
      'description': 'Great sound for workouts, commute, and focus time.',
    },
    {
      'name': 'Plant Care Set',
      'price_min': 20,
      'price_max': 45,
      'for_tags': ['Friend', 'Mom', 'Colleague'],
      'occasion_tags': ['General', 'Birthday'],
      'description': 'Tools and tips for thriving indoor greenery.',
    },
    {
      'name': 'Gourmet Tea Collection',
      'price_min': 18,
      'price_max': 40,
      'for_tags': ['Mom', 'Colleague', 'Friend'],
      'occasion_tags': ['General', 'Christmas'],
      'description': 'A curated mix of soothing and energizing blends.',
    },
    {
      'name': 'Polaroid Camera',
      'price_min': 70,
      'price_max': 120,
      'for_tags': ['Best Friend', 'Partner', 'Friend'],
      'occasion_tags': ['Birthday', 'Christmas'],
      'description': 'Capture spontaneous moments in print instantly.',
    },
    {
      'name': 'Custom Portrait Illustration',
      'price_min': 40,
      'price_max': 100,
      'for_tags': ['Partner', 'Best Friend'],
      'occasion_tags': ['Anniversary', 'Birthday', "Valentine's Day"],
      'description': 'A unique art piece of them — or of you together.',
    },
    {
      'name': 'Hiking Day Pack',
      'price_min': 45,
      'price_max': 95,
      'for_tags': ['Dad', 'Friend', 'Partner'],
      'occasion_tags': ['Birthday', 'General'],
      'description': 'Lightweight gear for weekend trails and adventures.',
    },
    {
      'name': 'Chocolate Truffle Box',
      'price_min': 20,
      'price_max': 45,
      'for_tags': ['Partner', 'Mom', 'Friend'],
      'occasion_tags': ["Valentine's Day", 'Birthday', 'Christmas'],
      'description': 'Decadent flavors that feel instantly celebratory.',
    },
    {
      'name': 'Yoga Mat & Accessories',
      'price_min': 35,
      'price_max': 80,
      'for_tags': ['Friend', 'Mom', 'Best Friend'],
      'occasion_tags': ['Birthday', 'General'],
      'description': 'Support their wellness routine in style.',
    },
    {
      'name': 'Portable Espresso Maker',
      'price_min': 60,
      'price_max': 130,
      'for_tags': ['Dad', 'Colleague', 'Partner'],
      'occasion_tags': ['Birthday', 'Christmas'],
      'description': 'Café-quality shots wherever the day takes them.',
    },
    {
      'name': 'Memory Jar Kit',
      'price_min': 15,
      'price_max': 28,
      'for_tags': ['Partner', 'Best Friend'],
      'occasion_tags': ['Anniversary', "Valentine's Day", 'General'],
      'description': 'Fill with notes of gratitude throughout the year.',
    },
    {
      'name': 'Leather Journal',
      'price_min': 25,
      'price_max': 55,
      'for_tags': ['Friend', 'Colleague', 'Dad'],
      'occasion_tags': ['Birthday', 'Christmas', 'General'],
      'description': 'A refined place for ideas, plans, and reflections.',
    },
    {
      'name': 'Succulent Terrarium',
      'price_min': 25,
      'price_max': 50,
      'for_tags': ['Colleague', 'Friend', 'Mom'],
      'occasion_tags': ['General', 'Birthday'],
      'description': 'A living décor piece that brightens any desk.',
    },
    {
      'name': 'Concert or Show Tickets',
      'price_min': 80,
      'price_max': 250,
      'for_tags': ['Partner', 'Best Friend', 'Friend'],
      'occasion_tags': ['Birthday', 'Anniversary'],
      'description': 'Shared experiences often outshine material gifts.',
    },
    {
      'name': 'Custom Recipe Book',
      'price_min': 30,
      'price_max': 65,
      'for_tags': ['Mom', 'Partner', 'Dad'],
      'occasion_tags': ['Birthday', 'Christmas', 'Anniversary'],
      'description': 'Collect family favorites into one beautiful volume.',
    },
    {
      'name': 'Bluetooth Speaker',
      'price_min': 40,
      'price_max': 120,
      'for_tags': ['Friend', 'Dad', 'Best Friend'],
      'occasion_tags': ['Birthday', 'Christmas', 'General'],
      'description': 'Big sound for parties, kitchens, and road trips.',
    },
    {
      'name': 'Picnic Basket Set',
      'price_min': 45,
      'price_max': 95,
      'for_tags': ['Partner'],
      'occasion_tags': ['Anniversary', "Valentine's Day", 'General'],
      'description': 'Ready for sunny afternoons and spontaneous dates.',
    },
    {
      'name': 'Artisan Soap & Bath Set',
      'price_min': 20,
      'price_max': 45,
      'for_tags': ['Mom', 'Friend', 'Best Friend'],
      'occasion_tags': ['Birthday', 'Christmas', 'General'],
      'description': 'Spa vibes at home with thoughtfully made essentials.',
    },
  ];
  final batch = db.batch();
  for (final item in items) {
    batch.insert('gift_guide_items', {
      'name': item['name'],
      'price_min': item['price_min'],
      'price_max': item['price_max'],
      'for_tags': jsonEncode(item['for_tags']),
      'occasion_tags': jsonEncode(item['occasion_tags']),
      'description': item['description'],
    });
  }
  await batch.commit(noResult: true);
}
Future<void> _seedFlowerLanguageItems(Database db) async {
  final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM flower_language_items'),
      ) ??
      0;
  if (count > 0) return;
  final items = <Map<String, dynamic>>[
    {
      'name': 'Red Rose',
      'emoji': '🌹',
      'short_meaning': 'Deep love and passion',
      'full_meaning':
          'The classic symbol of romantic love. Red roses express deep affection, desire, and lifelong devotion. Perfect when you want your feelings to be unmistakable.',
      'color_variants':
          'Red = deep love; White = purity; Pink = admiration; Yellow = friendship.',
      'tips': '12 roses = a dozen roses = perfect romantic gesture.',
      'occasions': ['Anniversary', "Valentine's Day"],
    },
    {
      'name': 'White Rose',
      'emoji': '🤍',
      'short_meaning': 'Purity and new beginnings',
      'full_meaning':
          'White roses speak of innocence, reverence, and fresh starts. They are elegant for apologies and meaningful for weddings or new chapters.',
      'color_variants':
          'White = purity; Cream = charm; Blush white = gentle romance.',
      'tips': 'Pair with soft greenery for a calm, sincere message.',
      'occasions': ['Wedding', 'Apology'],
    },
    {
      'name': 'Pink Rose',
      'emoji': '🌸',
      'short_meaning': 'Admiration and gentle love',
      'full_meaning':
          'Pink roses convey grace, gratitude, and tender affection. Softer than red, they suit birthdays and everyday gestures of care.',
      'color_variants':
          'Light pink = sweetness; Hot pink = appreciation; Soft pink = admiration.',
      'tips': 'A mixed pink bouquet feels cheerful without being overly intense.',
      'occasions': ['Birthday', 'Just Because'],
    },
    {
      'name': 'Tulip',
      'emoji': '🌷',
      'short_meaning': 'Declaration of love (red) / Cheerfulness (yellow)',
      'full_meaning':
          'Tulips are elegant messengers of spring feelings. Red tulips declare love, while yellow ones bring cheer and bright energy.',
      'color_variants':
          'Red = true love; Yellow = cheer; Purple = royalty; Pink = happiness.',
      'tips': 'Keep stems trimmed and water fresh — tulips keep growing in the vase.',
      'occasions': ["Valentine's Day", 'Birthday'],
    },
    {
      'name': 'Lily',
      'emoji': '💐',
      'short_meaning': 'Beauty and devotion',
      'full_meaning':
          'Lilies represent refined beauty and devoted care. Their striking form makes any bouquet feel elevated and heartfelt.',
      'color_variants':
          'White = virtue; Pink = prosperity; Orange = confidence; Stargazer = ambition.',
      'tips': 'Remove pollen stamens to avoid stains on clothing and furniture.',
      'occasions': ['Anniversary', 'Birthday'],
    },
    {
      'name': 'Sunflower',
      'emoji': '🌻',
      'short_meaning': 'Warmth, adoration, and loyalty',
      'full_meaning':
          'Sunflowers radiate positivity and steadfast loyalty. They say “you brighten my days” without needing many words.',
      'color_variants':
          'Classic yellow = warmth; Orange-toned = energy; Mini sunflowers = playful affection.',
      'tips': 'Best as a direct, sunny gift for someone who lifts your spirits.',
      'occasions': ['Just Because', 'Birthday'],
    },
    {
      'name': 'Peony',
      'emoji': '🪷',
      'short_meaning': 'Romance and prosperity',
      'full_meaning':
          'Peonies bloom with lush romance and good fortune. They feel luxurious and are treasured for meaningful celebrations.',
      'color_variants':
          'Pink = romance; White = apology/shyness; Red = honor and passion.',
      'tips': 'Seasonal and short-lived — order early for peak bloom months.',
      'occasions': ['Anniversary'],
    },
    {
      'name': 'Orchid',
      'emoji': '🌺',
      'short_meaning': 'Rare beauty and refined love',
      'full_meaning':
          'Orchids suggest elegance, rare beauty, and thoughtful sophistication. A lasting plant gift that keeps blooming with care.',
      'color_variants':
          'Purple = admiration; White = elegance; Pink = grace; Yellow = friendship.',
      'tips': 'Include a simple care card — orchids thrive with the right light and watering.',
      'occasions': ['Anniversary', "Valentine's Day"],
    },
    {
      'name': 'Daisy',
      'emoji': '🌼',
      'short_meaning': 'Innocence and true love',
      'full_meaning':
          'Daisies feel fresh, honest, and joyful. They celebrate simple happiness and sincere affection.',
      'color_variants':
          'White daisy = innocence; Gerbera = cheer by color; Pink daisy = gentle affection.',
      'tips': 'Great for casual “thinking of you” moments and playful birthdays.',
      'occasions': ['Just Because', 'Birthday'],
    },
    {
      'name': 'Lavender',
      'emoji': '💜',
      'short_meaning': 'Serenity and devotion',
      'full_meaning':
          'Lavender calms the senses and speaks of devotion, peace, and quiet care. Ideal when you want comfort more than spectacle.',
      'color_variants':
          'Purple lavender = serenity; Dried lavender = lasting remembrance.',
      'tips': 'Can be gifted as a bouquet, sachet, or bundled with a handwritten note.',
      'occasions': ['Apology', 'Just Because'],
    },
    {
      'name': 'Iris',
      'emoji': '🌸',
      'short_meaning': 'Wisdom and hope',
      'full_meaning':
          'Irises symbolize faith, wisdom, and hopeful beginnings. A graceful choice when encouragement matters most.',
      'color_variants':
          'Blue/purple = wisdom; Yellow = passion; White = purity.',
      'tips': 'Striking on their own in a tall vase — less can feel more elegant.',
      'occasions': ['Apology', 'Birthday'],
    },
    {
      'name': 'Carnation',
      'emoji': '🌷',
      'short_meaning': 'Deep love (red) / Admiration (pink)',
      'full_meaning':
          'Carnations are enduring symbols of love and admiration. Affordable yet expressive, they work for romance and gratitude alike.',
      'color_variants':
          'Red = deep love; Pink = admiration; White = pure love; Yellow = disappointment (use carefully).',
      'tips': 'Long vase life makes them practical for busy weeks.',
      'occasions': ['Anniversary', "Valentine's Day"],
    },
    {
      'name': 'Cherry Blossom',
      'emoji': '🌸',
      'short_meaning': 'Fleeting beauty and cherished moments',
      'full_meaning':
          'Cherry blossoms remind us that beautiful moments are precious because they pass. A poetic gift for appreciation and presence.',
      'color_variants':
          'Soft pink = fleeting beauty; White blossom = pure remembrance.',
      'tips': 'Best as a seasonal gesture or paired with a photo of a shared memory.',
      'occasions': ['Just Because'],
    },
    {
      'name': "Baby's Breath",
      'emoji': '🌫️',
      'short_meaning': 'Everlasting love and purity',
      'full_meaning':
          "Baby's breath softens any arrangement and whispers everlasting love. Often paired with roses for a complete romantic message.",
      'color_variants':
          'White = purity; Dyed pastels = playful accents for birthdays.',
      'tips': '12 red roses + white baby\'s breath is a classic anniversary combo.',
      'occasions': ['Anniversary', 'Wedding'],
    },
    {
      'name': 'Hydrangea',
      'emoji': '💙',
      'short_meaning': 'Heartfelt gratitude and deep understanding',
      'full_meaning':
          'Hydrangeas express gratitude and emotional understanding. Their full blooms feel generous and sincerely apologetic when needed.',
      'color_variants':
          'Blue = apology/gratitude; Pink = sincere emotion; White = grace; Purple = deep understanding.',
      'tips': 'They drink a lot of water — remind the recipient to refill often.',
      'occasions': ['Apology', 'Just Because'],
    },
  ];
  final batch = db.batch();
  for (final item in items) {
    batch.insert('flower_language_items', {
      'name': item['name'],
      'emoji': item['emoji'],
      'short_meaning': item['short_meaning'],
      'full_meaning': item['full_meaning'],
      'color_variants': item['color_variants'],
      'tips': item['tips'],
      'occasions': jsonEncode(item['occasions']),
    });
  }
  await batch.commit(noResult: true);
}
Future<void> _seedWishTemplates(Database db) async {
  final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM wish_templates'),
      ) ??
      0;
  if (count > 0) return;
  final now = DateTime.now().toIso8601String();
  final wishes = <Map<String, String>>[
    {
      'category': 'Birthday',
      'content':
          'Wishing you a day filled with joy and laughter. Happy Birthday! 🎂',
    },
    {
      'category': 'Birthday',
      'content':
          'Another year older, another year more wonderful. Cheers to you! 🥂',
    },
    {
      'category': 'Birthday',
      'content':
          'May all your birthday wishes come true — you deserve nothing but the best!',
    },
    {
      'category': 'Birthday',
      'content':
          "Here's to the amazing person you are. Happy Birthday with all my heart! 🎉",
    },
    {
      'category': 'Birthday',
      'content':
          "On your special day, just know how much you're loved and appreciated. Happy Birthday!",
    },
    {
      'category': 'Birthday',
      'content':
          'Hope your birthday is as bright and beautiful as you are. Celebrate big! ✨',
    },
    {
      'category': 'Birthday',
      'content':
          'Happy Birthday! May this year bring you adventure, peace, and everything you hope for.',
    },
    {
      'category': 'Birthday',
      'content':
          "You're one of a kind — today is the perfect excuse to celebrate you. Happy Birthday!",
    },
    {
      'category': 'Birthday',
      'content':
          'Sending cake, candles, and the warmest wishes your way. Have an incredible birthday!',
    },
    {
      'category': 'Birthday',
      'content':
          'Age is just a number, but the joy you bring is endless. Happy Birthday, friend!',
    },
    {
      'category': 'Anniversary',
      'content':
          'Happy Anniversary! Every moment with you has been a gift. 💕',
    },
    {
      'category': 'Anniversary',
      'content':
          "Here's to another year of love, laughter, and making memories. Happy Anniversary!",
    },
    {
      'category': 'Anniversary',
      'content':
          'You make every year better than the last. Cheers to us! 🥂',
    },
    {
      'category': 'Anniversary',
      'content':
          'Still my favorite person, still my favorite story. Happy Anniversary!',
    },
    {
      'category': 'Anniversary',
      'content':
          'Thank you for a love that grows sweeter with time. Happy Anniversary, my love. 💖',
    },
    {
      'category': "Valentine's",
      'content':
          "Every day with you is Valentine's Day. I love you! 💝",
    },
    {
      'category': "Valentine's",
      'content':
          'You are the reason I smile, today and every day. Happy Valentine\'s Day! 🌹',
    },
    {
      'category': "Valentine's",
      'content':
          'My heart chose you — and it keeps choosing you. Happy Valentine\'s Day!',
    },
    {
      'category': "Valentine's",
      'content':
          'With you, love feels easy, warm, and endlessly exciting. Be mine today and always. 💘',
    },
    {
      'category': 'Christmas',
      'content':
          'Wishing you a magical Christmas filled with warmth and joy! 🎄',
    },
    {
      'category': 'Christmas',
      'content':
          'May your holidays sparkle with love, laughter, and cozy moments. Merry Christmas!',
    },
    {
      'category': 'Christmas',
      'content':
          'Sending festive cheer and grateful hugs your way this Christmas season! ✨',
    },
    {
      'category': 'General',
      'content':
          'Thinking of you and hoping you have a wonderful day! 🌟',
    },
    {
      'category': 'General',
      'content':
          'Just a little note to say you mean so much. Hope today treats you kindly!',
    },
    {
      'category': 'General',
      'content':
          "You're appreciated more than you know. Sending good vibes your way! 💫",
    },
  ];
  final batch = db.batch();
  for (final wish in wishes) {
    batch.insert('wish_templates', {
      'category': wish['category'],
      'content': wish['content'],
      'is_built_in': 1,
      'created_at': now,
    });
  }
  await batch.commit(noResult: true);
}
