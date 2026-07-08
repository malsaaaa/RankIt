import '../models/category_model.dart';
import '../models/item_model.dart';
import '../models/ranking_list_model.dart';

// Toggle this to immediately enable or disable mock fallback data.
const bool useMockData = true;

class MockTopicStats {
  final String topicId;
  final int totalVotes;
  final int candidateCount;
  final String aiSummary;

  const MockTopicStats({
    required this.topicId,
    required this.totalVotes,
    required this.candidateCount,
    required this.aiSummary,
  });
}

class MockData {
  static const String _systemUser = 'system';

  static final List<CategoryModel> categories = [
    _category(
      id: '101',
      name: 'Football',
      description: 'Clubs, legends, tactics, and iconic football moments.',
      imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=900',
      dayOffset: 30,
    ),
    _category(
      id: '102',
      name: 'Movies',
      description: 'Blockbusters, directors, classics, and fan favorites.',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&q=80&w=900',
      dayOffset: 29,
    ),
    _category(
      id: '103',
      name: 'Anime',
      description: 'Shonen giants, villains, openings, and unforgettable arcs.',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&q=80&w=900',
      dayOffset: 28,
    ),
    _category(
      id: '104',
      name: 'Food',
      description: 'Regional flavors, comfort dishes, and sweet cravings.',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=900',
      dayOffset: 27,
    ),
    _category(
      id: '105',
      name: 'Smartphones',
      description: 'Flagships, camera kings, and best-value devices.',
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=900',
      dayOffset: 26,
    ),
    _category(
      id: '106',
      name: 'Gaming',
      description: 'Open worlds, mobile hits, and all-time great genres.',
      imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&q=80&w=900',
      dayOffset: 25,
    ),
    _category(
      id: '107',
      name: 'Cars',
      description: 'Performance icons, reliable brands, and EV evolution.',
      imageUrl: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&q=80&w=900',
      dayOffset: 24,
    ),
    _category(
      id: '108',
      name: 'Universities',
      description: 'Top institutions, campus life, and academic reputation.',
      imageUrl: 'https://images.unsplash.com/photo-1498243691581-b145c3f54a5a?auto=format&fit=crop&q=80&w=900',
      dayOffset: 23,
    ),
    _category(
      id: '109',
      name: 'Programming Languages',
      description: 'Developer favorites across backend, mobile, and data.',
      imageUrl: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?auto=format&fit=crop&q=80&w=900',
      dayOffset: 22,
    ),
    _category(
      id: '110',
      name: 'Travel Destinations',
      description: 'Beaches, food capitals, and scenic nature escapes.',
      imageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&q=80&w=900',
      dayOffset: 21,
    ),
  ];

  static final List<RankingListModel> topics = [
    _topic('1001', '101', 'Best Football Player of All Time', 'The greatest footballers based on consistency, trophies, and impact.', 20),
    _topic('1002', '101', 'Greatest Premier League Team', 'Most dominant Premier League squads ever assembled.', 19),
    _topic('1003', '101', 'Best Goalkeeper Ever', 'Shot-stoppers who defined eras with reflexes and leadership.', 18),
    _topic('1101', '102', 'Best Marvel Movie', 'Most rewatchable and impactful films in the Marvel universe.', 17),
    _topic('1102', '102', 'Best Christopher Nolan Film', 'Nolan films ranked by story depth, craft, and legacy.', 16),
    _topic('1103', '102', 'Best Animated Movie', 'Animated films with outstanding story, emotion, and visuals.', 15),
    _topic('1201', '103', 'Best Shonen Anime', 'The most influential and entertaining shonen series.', 14),
    _topic('1202', '103', 'Best Anime Villain', 'Villains judged by writing, presence, and motivations.', 13),
    _topic('1203', '103', 'Best Anime Opening', 'Openings ranked by music, visuals, and iconic status.', 12),
    _topic('1301', '104', 'Best Malaysian Food', 'Beloved Malaysian dishes with the strongest fan support.', 11),
    _topic('1302', '104', 'Best Fast Food Restaurant', 'Fast food brands ranked by taste, value, and consistency.', 10),
    _topic('1303', '104', 'Best Dessert', 'Top dessert picks across local and international favorites.', 9),
    _topic('1401', '105', 'Best Flagship Smartphone 2026', 'Premium phones competing on overall performance.', 8),
    _topic('1402', '105', 'Best Camera Phone', 'Smartphones with the strongest all-around camera systems.', 7),
    _topic('1403', '105', 'Best Budget Smartphone', 'High-value phones with strong everyday usability.', 6),
    _topic('1501', '106', 'Best Open World Game', 'Open world titles with freedom, immersion, and depth.', 5),
    _topic('1502', '106', 'Best Mobile Game', 'Mobile games with longevity, polish, and active communities.', 4),
    _topic('1503', '106', 'Best RPG', 'Role-playing games with the best worldbuilding and progression.', 3),
    _topic('1601', '107', 'Best Supercar', 'Supercars ranked by engineering, design, and driving emotion.', 2),
    _topic('1602', '107', 'Most Reliable Car Brand', 'Brands known for durability and low ownership issues.', 2),
    _topic('1603', '107', 'Best Electric Vehicle', 'EVs balancing range, charging, and driving experience.', 2),
    _topic('1701', '108', 'Best University for Engineering', 'Top institutions for engineering outcomes and research.', 2),
    _topic('1702', '108', 'Best University in Asia', 'Leading universities in Asia by excellence and reputation.', 2),
    _topic('1703', '108', 'Best University Campus Life', 'Universities offering the most vibrant student experience.', 2),
    _topic('1801', '109', 'Most Loved Programming Language', 'Community favorites by developer satisfaction and momentum.', 2),
    _topic('1802', '109', 'Best Language for Backend', 'Backend languages ranked by ecosystem and productivity.', 2),
    _topic('1803', '109', 'Best Language for Mobile Development', 'Languages preferred for modern mobile app delivery.', 2),
    _topic('1901', '110', 'Best Beach Destination', 'Beach destinations ranked for scenery and traveler experience.', 2),
    _topic('1902', '110', 'Best City for Food Tourism', 'Cities with world-class culinary exploration.', 2),
    _topic('1903', '110', 'Best Nature Destination', 'Nature destinations known for landscapes and biodiversity.', 2),
  ];

  static final List<ItemModel> candidates = [
    _candidate('5001', '1001', 'Cristiano Ronaldo', 'Goal-scoring machine with elite longevity.', 'https://source.unsplash.com/600x600/?football,player,stadium', 245, 321),
    _candidate('5002', '1001', 'Lionel Messi', 'Playmaker and finisher with unmatched creativity.', 'https://source.unsplash.com/600x600/?soccer,dribble', 252, 326),
    _candidate('5003', '1001', 'Neymar', 'Technical flair and creativity in one-on-one duels.', 'https://source.unsplash.com/600x600/?football,skills', 169, 298),
    _candidate('5004', '1001', 'Ronaldinho', 'Iconic entertainer with magical close control.', 'https://source.unsplash.com/600x600/?soccer,freestyle', 180, 304),
    _candidate('5005', '1001', 'Diego Maradona', 'Legendary influence in big tournament moments.', 'https://source.unsplash.com/600x600/?football,legend', 188, 310),
    _candidate('5006', '1001', 'Zinedine Zidane', 'Elegant midfield maestro with elite big-game aura.', 'https://source.unsplash.com/600x600/?football,midfielder', 162, 284),

    _candidate('5011', '1002', 'Manchester City 2017-23', 'Dominant possession era under Guardiola.', 'https://source.unsplash.com/600x600/?football,team', 218, 268),
    _candidate('5012', '1002', 'Manchester United 1998-99', 'Historic treble-winning side.', 'https://source.unsplash.com/600x600/?soccer,teamwork', 206, 260),
    _candidate('5013', '1002', 'Arsenal 2003-04', 'The Invincibles completed an unbeaten season.', 'https://source.unsplash.com/600x600/?football,champions', 212, 265),
    _candidate('5014', '1002', 'Chelsea 2004-05', 'Record-setting defensive solidity.', 'https://source.unsplash.com/600x600/?soccer,defense', 173, 241),
    _candidate('5015', '1002', 'Liverpool 2019-20', 'Relentless pressing and title-winning consistency.', 'https://source.unsplash.com/600x600/?football,celebration', 197, 253),
    _candidate('5016', '1002', 'Leicester City 2015-16', 'Greatest underdog title run in modern football.', 'https://source.unsplash.com/600x600/?soccer,trophy', 164, 229),

    _candidate('5021', '1003', 'Gianluigi Buffon', 'Longevity and leadership at elite level.', 'https://source.unsplash.com/600x600/?goalkeeper,football', 231, 287),
    _candidate('5022', '1003', 'Manuel Neuer', 'Revolutionized the sweeper-keeper role.', 'https://source.unsplash.com/600x600/?goalkeeper,soccer', 219, 279),
    _candidate('5023', '1003', 'Iker Casillas', 'Big-match hero with exceptional reflexes.', 'https://source.unsplash.com/600x600/?soccer,goalie', 196, 266),
    _candidate('5024', '1003', 'Petr Cech', 'Premier League icon with title-winning consistency.', 'https://source.unsplash.com/600x600/?football,goal', 173, 248),
    _candidate('5025', '1003', 'Edwin van der Sar', 'Calm distribution and elite shot-stopping.', 'https://source.unsplash.com/600x600/?soccer,keeper', 161, 239),
    _candidate('5026', '1003', 'Lev Yashin', 'The original all-time goalkeeper benchmark.', 'https://source.unsplash.com/600x600/?vintage,goalkeeper', 182, 252),

    _candidate('5101', '1101', 'Avengers: Endgame', 'Massive payoff to a decade-long arc.', 'https://source.unsplash.com/600x600/?cinema,blockbuster', 244, 339),
    _candidate('5102', '1101', 'Avengers: Infinity War', 'Bold storytelling with a shocking ending.', 'https://source.unsplash.com/600x600/?movie,theater', 232, 331),
    _candidate('5103', '1101', 'Captain America: The Winter Soldier', 'Grounded action-thriller tone in Marvel.', 'https://source.unsplash.com/600x600/?movie,action', 187, 289),
    _candidate('5104', '1101', 'Black Panther', 'Cultural impact and strong worldbuilding.', 'https://source.unsplash.com/600x600/?cinema,premiere', 179, 281),
    _candidate('5105', '1101', 'Spider-Man: No Way Home', 'Nostalgia and crowd-pleasing execution.', 'https://source.unsplash.com/600x600/?movie,spiderman', 221, 324),
    _candidate('5106', '1101', 'Guardians of the Galaxy', 'Heart, humor, and a standout soundtrack.', 'https://source.unsplash.com/600x600/?movie,space', 171, 273),

    _candidate('5111', '1102', 'Interstellar', 'Emotional sci-fi with epic scale.', 'https://source.unsplash.com/600x600/?space,film', 248, 302),
    _candidate('5112', '1102', 'The Dark Knight', 'Genre-defining superhero crime drama.', 'https://source.unsplash.com/600x600/?cinema,night', 254, 309),
    _candidate('5113', '1102', 'Inception', 'Layered dream-heist storytelling.', 'https://source.unsplash.com/600x600/?movie,dream', 229, 296),
    _candidate('5114', '1102', 'Oppenheimer', 'Powerful historical drama and performances.', 'https://source.unsplash.com/600x600/?film,drama', 210, 287),
    _candidate('5115', '1102', 'Memento', 'Innovative non-linear narrative.', 'https://source.unsplash.com/600x600/?movie,retro', 176, 244),
    _candidate('5116', '1102', 'Dunkirk', 'Tense, minimal-dialog war filmmaking.', 'https://source.unsplash.com/600x600/?film,war', 169, 231),

    _candidate('5121', '1103', 'Spirited Away', 'Imaginative world and timeless emotional core.', 'https://source.unsplash.com/600x600/?animation,art', 236, 298),
    _candidate('5122', '1103', 'Toy Story 3', 'Emotional finale with universal appeal.', 'https://source.unsplash.com/600x600/?animated,movie', 211, 282),
    _candidate('5123', '1103', 'Into the Spider-Verse', 'Stylized visuals and fresh storytelling.', 'https://source.unsplash.com/600x600/?animation,comics', 228, 291),
    _candidate('5124', '1103', 'Your Name', 'Beautiful romance with strong soundtrack.', 'https://source.unsplash.com/600x600/?anime,sky', 204, 276),
    _candidate('5125', '1103', 'Coco', 'Family, memory, and vibrant visual identity.', 'https://source.unsplash.com/600x600/?festival,colorful', 189, 264),
    _candidate('5126', '1103', 'How to Train Your Dragon', 'Adventure with heartfelt character arcs.', 'https://source.unsplash.com/600x600/?fantasy,animation', 167, 238),

    _candidate('5201', '1201', 'One Piece', 'Epic worldbuilding and long-form payoff.', 'https://source.unsplash.com/600x600/?anime,pirate', 275, 333),
    _candidate('5202', '1201', 'Naruto', 'Iconic rivalry arcs and emotional growth.', 'https://source.unsplash.com/600x600/?anime,ninja', 242, 318),
    _candidate('5203', '1201', 'Attack on Titan', 'High-stakes plot twists and scale.', 'https://source.unsplash.com/600x600/?anime,city', 253, 325),
    _candidate('5204', '1201', 'Hunter x Hunter', 'Strategic fights and layered characters.', 'https://source.unsplash.com/600x600/?anime,adventure', 214, 287),
    _candidate('5205', '1201', 'Fullmetal Alchemist: Brotherhood', 'Near-perfect pacing and themes.', 'https://source.unsplash.com/600x600/?alchemy,anime', 231, 301),
    _candidate('5206', '1201', 'Jujutsu Kaisen', 'Modern pacing with standout animation.', 'https://source.unsplash.com/600x600/?anime,action', 209, 279),

    _candidate('5211', '1202', 'Johan Liebert', 'Psychological menace with quiet intensity.', 'https://source.unsplash.com/600x600/?dark,portrait', 197, 241),
    _candidate('5212', '1202', 'Madara Uchiha', 'Overwhelming power and mythic buildup.', 'https://source.unsplash.com/600x600/?anime,battle', 224, 266),
    _candidate('5213', '1202', 'Meruem', 'Complex growth from tyrant to tragic figure.', 'https://source.unsplash.com/600x600/?chess,shadow', 212, 254),
    _candidate('5214', '1202', 'Sosuke Aizen', 'Master manipulator with perfect poise.', 'https://source.unsplash.com/600x600/?villain,silhouette', 185, 229),
    _candidate('5215', '1202', 'Frieza', 'Classic anime villain with lasting legacy.', 'https://source.unsplash.com/600x600/?space,villain', 179, 223),
    _candidate('5216', '1202', 'Hisoka', 'Unpredictable wild card with presence.', 'https://source.unsplash.com/600x600/?joker,anime', 171, 217),

    _candidate('5221', '1203', 'Gurenge', 'Explosive opener that defined a season.', 'https://source.unsplash.com/600x600/?concert,lights', 241, 289),
    _candidate('5222', '1203', 'Unravel', 'Emotional build and iconic hook.', 'https://source.unsplash.com/600x600/?microphone,stage', 228, 281),
    _candidate('5223', '1203', 'Cruel Angel Thesis', 'All-time classic anime opening.', 'https://source.unsplash.com/600x600/?retro,music', 236, 292),
    _candidate('5224', '1203', 'Kaikai Kitan', 'Stylish visual cuts and energy.', 'https://source.unsplash.com/600x600/?dj,neon', 192, 247),
    _candidate('5225', '1203', 'Silhouette', 'Fan-favorite shonen anthem.', 'https://source.unsplash.com/600x600/?band,performance', 199, 252),
    _candidate('5226', '1203', 'The Rumbling', 'Aggressive opening with strong identity.', 'https://source.unsplash.com/600x600/?rock,concert', 183, 238),

    _candidate('5301', '1301', 'Nasi Lemak', 'Coconut rice classic with sambal and sides.', 'https://source.unsplash.com/600x600/?malaysian,food', 254, 307),
    _candidate('5302', '1301', 'Char Kway Teow', 'Wok hei noodle favorite with smoky flavor.', 'https://source.unsplash.com/600x600/?stir-fry,noodles', 221, 291),
    _candidate('5303', '1301', 'Satay', 'Skewers with rich peanut sauce.', 'https://source.unsplash.com/600x600/?satay,grill', 206, 278),
    _candidate('5304', '1301', 'Roti Canai', 'Crispy layered flatbread with curry.', 'https://source.unsplash.com/600x600/?flatbread,curry', 198, 269),
    _candidate('5305', '1301', 'Laksa', 'Spicy noodle soup with aromatic broth.', 'https://source.unsplash.com/600x600/?laksa,soup', 214, 283),
    _candidate('5306', '1301', 'Nasi Kandar', 'Rice and mixed curries with deep spice.', 'https://source.unsplash.com/600x600/?rice,curry', 187, 255),

    _candidate('5311', '1302', 'McDonald\'s', 'Strong consistency and global menu familiarity.', 'https://source.unsplash.com/600x600/?fastfood,burger', 233, 318),
    _candidate('5312', '1302', 'KFC', 'Fried chicken icon with wide regional reach.', 'https://source.unsplash.com/600x600/?fried,chicken', 219, 304),
    _candidate('5313', '1302', 'Burger King', 'Flame-grilled profile and customizable burgers.', 'https://source.unsplash.com/600x600/?burger,restaurant', 183, 276),
    _candidate('5314', '1302', 'Subway', 'Fast option with lighter customization.', 'https://source.unsplash.com/600x600/?sandwich,food', 165, 251),
    _candidate('5315', '1302', 'Five Guys', 'Premium burger quality and fries reputation.', 'https://source.unsplash.com/600x600/?fries,burger', 176, 259),
    _candidate('5316', '1302', 'A&W', 'Classic fast food with strong nostalgia.', 'https://source.unsplash.com/600x600/?rootbeer,diner', 152, 238),

    _candidate('5321', '1303', 'Tiramisu', 'Coffee-forward Italian dessert favorite.', 'https://source.unsplash.com/600x600/?tiramisu,dessert', 201, 262),
    _candidate('5322', '1303', 'Cheesecake', 'Creamy texture with broad flavor options.', 'https://source.unsplash.com/600x600/?cheesecake', 214, 271),
    _candidate('5323', '1303', 'Ice Cream', 'Universal favorite across all age groups.', 'https://source.unsplash.com/600x600/?ice-cream', 226, 279),
    _candidate('5324', '1303', 'Brownie Sundae', 'Warm-cold contrast and indulgent taste.', 'https://source.unsplash.com/600x600/?brownie,sundae', 178, 245),
    _candidate('5325', '1303', 'Pavlova', 'Light meringue dessert with fruit balance.', 'https://source.unsplash.com/600x600/?meringue,dessert', 159, 231),
    _candidate('5326', '1303', 'Creme Brulee', 'Classic custard with caramelized top.', 'https://source.unsplash.com/600x600/?creme-brulee', 167, 236),

    _candidate('5401', '1401', 'iPhone 17 Pro', 'Balanced flagship with polished ecosystem.', 'https://source.unsplash.com/600x600/?smartphone,premium', 241, 296),
    _candidate('5402', '1401', 'Samsung Galaxy S26 Ultra', 'Top-tier display and zoom versatility.', 'https://source.unsplash.com/600x600/?phone,camera', 236, 291),
    _candidate('5403', '1401', 'Google Pixel 10 Pro', 'Smart software and computational imaging.', 'https://source.unsplash.com/600x600/?android,phone', 214, 278),
    _candidate('5404', '1401', 'Xiaomi 16 Pro', 'Strong value in the flagship segment.', 'https://source.unsplash.com/600x600/?mobile,technology', 188, 257),
    _candidate('5405', '1401', 'OnePlus 14', 'Fast performance and fluid user experience.', 'https://source.unsplash.com/600x600/?smartphone,screen', 179, 248),
    _candidate('5406', '1401', 'HONOR Magic 8 Pro', 'Competitive hardware and battery endurance.', 'https://source.unsplash.com/600x600/?phone,device', 171, 241),

    _candidate('5411', '1402', 'Google Pixel 10 Pro', 'Natural tones and top-tier low-light shots.', 'https://source.unsplash.com/600x600/?phone,photography', 232, 287),
    _candidate('5412', '1402', 'Samsung Galaxy S26 Ultra', 'Versatile camera stack with long zoom.', 'https://source.unsplash.com/600x600/?camera,smartphone', 240, 294),
    _candidate('5413', '1402', 'iPhone 17 Pro Max', 'Reliable video and excellent autofocus.', 'https://source.unsplash.com/600x600/?iphone,camera', 229, 289),
    _candidate('5414', '1402', 'Xiaomi 16 Ultra', 'High-end sensor performance and detail.', 'https://source.unsplash.com/600x600/?mobile,camera-lens', 199, 263),
    _candidate('5415', '1402', 'Vivo X200 Pro', 'Portrait performance and color science.', 'https://source.unsplash.com/600x600/?smartphone,portrait', 191, 254),
    _candidate('5416', '1402', 'OPPO Find X9 Pro', 'Strong night mode and stabilization.', 'https://source.unsplash.com/600x600/?phone,night', 184, 247),

    _candidate('5421', '1403', 'Samsung Galaxy A56', 'Reliable midrange experience and updates.', 'https://source.unsplash.com/600x600/?android,midrange', 197, 266),
    _candidate('5422', '1403', 'Redmi Note 15 Pro', 'Great value with solid battery life.', 'https://source.unsplash.com/600x600/?phone,budget', 209, 274),
    _candidate('5423', '1403', 'Nothing Phone 3a', 'Clean software and unique design identity.', 'https://source.unsplash.com/600x600/?smartphone,minimal', 188, 257),
    _candidate('5424', '1403', 'realme GT Neo 8', 'Strong performance for the price.', 'https://source.unsplash.com/600x600/?mobile,gaming', 182, 249),
    _candidate('5425', '1403', 'POCO X8', 'High refresh display at affordable pricing.', 'https://source.unsplash.com/600x600/?phone,display', 174, 241),
    _candidate('5426', '1403', 'Moto G Power 2026', 'Dependable battery-focused everyday phone.', 'https://source.unsplash.com/600x600/?smartphone,battery', 163, 233),

    _candidate('5501', '1501', 'The Legend of Zelda: Breath of the Wild', 'Open-ended exploration and emergent gameplay.', 'https://source.unsplash.com/600x600/?open-world,game', 258, 311),
    _candidate('5502', '1501', 'Elden Ring', 'High freedom with dense world discovery.', 'https://source.unsplash.com/600x600/?fantasy,game', 252, 306),
    _candidate('5503', '1501', 'Red Dead Redemption 2', 'Narrative depth with immersive simulation.', 'https://source.unsplash.com/600x600/?western,game', 244, 299),
    _candidate('5504', '1501', 'The Witcher 3', 'Quest quality and world richness.', 'https://source.unsplash.com/600x600/?rpg,game', 237, 295),
    _candidate('5505', '1501', 'GTA V', 'Scale, freedom, and enduring popularity.', 'https://source.unsplash.com/600x600/?city,game', 221, 286),
    _candidate('5506', '1501', 'Skyrim', 'Modding ecosystem and replay value.', 'https://source.unsplash.com/600x600/?dragon,game', 213, 279),

    _candidate('5511', '1502', 'Mobile Legends: Bang Bang', 'Strong regional esports and active player base.', 'https://source.unsplash.com/600x600/?mobile,esports', 241, 312),
    _candidate('5512', '1502', 'PUBG Mobile', 'Competitive battle royale with tactical depth.', 'https://source.unsplash.com/600x600/?battle-royale,mobile', 236, 304),
    _candidate('5513', '1502', 'Genshin Impact', 'High production value and frequent updates.', 'https://source.unsplash.com/600x600/?anime,gameplay', 228, 296),
    _candidate('5514', '1502', 'Call of Duty: Mobile', 'Fast-paced action with multiple modes.', 'https://source.unsplash.com/600x600/?fps,mobile', 213, 283),
    _candidate('5515', '1502', 'Clash Royale', 'Quick strategic matches and longevity.', 'https://source.unsplash.com/600x600/?strategy,mobile', 194, 268),
    _candidate('5516', '1502', 'Pokemon GO', 'Location-based gameplay with social events.', 'https://source.unsplash.com/600x600/?outdoor,mobile-game', 186, 257),

    _candidate('5521', '1503', 'Baldur\'s Gate 3', 'Deep role-play freedom and reactive storytelling.', 'https://source.unsplash.com/600x600/?fantasy,rpg', 253, 301),
    _candidate('5522', '1503', 'The Witcher 3', 'Best-in-class side quests and characters.', 'https://source.unsplash.com/600x600/?rpg,adventure', 241, 294),
    _candidate('5523', '1503', 'Persona 5 Royal', 'Stylish turn-based combat and social systems.', 'https://source.unsplash.com/600x600/?jrpg,game', 224, 281),
    _candidate('5524', '1503', 'Final Fantasy VII Rebirth', 'Modern scope with classic emotional beats.', 'https://source.unsplash.com/600x600/?final-fantasy,game', 219, 276),
    _candidate('5525', '1503', 'Divinity: Original Sin 2', 'Tactical depth and co-op flexibility.', 'https://source.unsplash.com/600x600/?turn-based,game', 205, 262),
    _candidate('5526', '1503', 'Chrono Trigger', 'Timeless pacing and memorable soundtrack.', 'https://source.unsplash.com/600x600/?retro,rpg', 198, 255),

    _candidate('5601', '1601', 'Ferrari SF90', 'Hybrid performance benchmark with strong handling.', 'https://source.unsplash.com/600x600/?supercar,ferrari', 222, 271),
    _candidate('5602', '1601', 'Lamborghini Revuelto', 'Aggressive design with electrified power.', 'https://source.unsplash.com/600x600/?supercar,lamborghini', 214, 264),
    _candidate('5603', '1601', 'McLaren 750S', 'Lightweight precision and track confidence.', 'https://source.unsplash.com/600x600/?supercar,mclaren', 207, 258),
    _candidate('5604', '1601', 'Porsche 911 Turbo S', 'Everyday usability with elite speed.', 'https://source.unsplash.com/600x600/?sports-car,porsche', 219, 266),
    _candidate('5605', '1601', 'Bugatti Chiron', 'Engineering icon with immense top-end power.', 'https://source.unsplash.com/600x600/?hypercar,bugatti', 196, 247),
    _candidate('5606', '1601', 'Koenigsegg Jesko', 'Extreme aero and performance innovation.', 'https://source.unsplash.com/600x600/?hypercar,track', 188, 241),

    _candidate('5611', '1602', 'Toyota', 'Long-term reliability and low maintenance costs.', 'https://source.unsplash.com/600x600/?toyota,car', 247, 309),
    _candidate('5612', '1602', 'Honda', 'Consistent durability across core models.', 'https://source.unsplash.com/600x600/?honda,car', 233, 298),
    _candidate('5613', '1602', 'Lexus', 'Premium comfort with proven reliability.', 'https://source.unsplash.com/600x600/?luxury,car', 228, 292),
    _candidate('5614', '1602', 'Mazda', 'Strong reliability paired with enjoyable driving.', 'https://source.unsplash.com/600x600/?sedan,car', 201, 268),
    _candidate('5615', '1602', 'Subaru', 'Dependable drivetrains and all-weather confidence.', 'https://source.unsplash.com/600x600/?subaru,car', 186, 252),
    _candidate('5616', '1602', 'Hyundai', 'Improving quality and ownership value.', 'https://source.unsplash.com/600x600/?hyundai,vehicle', 173, 241),

    _candidate('5621', '1603', 'Tesla Model 3', 'Strong charging ecosystem and software updates.', 'https://source.unsplash.com/600x600/?electric,car', 241, 301),
    _candidate('5622', '1603', 'Hyundai Ioniq 5', 'Practical EV with excellent charging curve.', 'https://source.unsplash.com/600x600/?ev,car', 224, 287),
    _candidate('5623', '1603', 'Kia EV6', 'Performance and design in a daily package.', 'https://source.unsplash.com/600x600/?electric,vehicle', 217, 279),
    _candidate('5624', '1603', 'Porsche Taycan', 'Top-tier EV driving dynamics.', 'https://source.unsplash.com/600x600/?electric,sports-car', 209, 271),
    _candidate('5625', '1603', 'BYD Seal', 'Competitive range and value proposition.', 'https://source.unsplash.com/600x600/?ev,sedan', 198, 263),
    _candidate('5626', '1603', 'BMW i4', 'Balanced premium EV for daily use.', 'https://source.unsplash.com/600x600/?bmw,electric', 189, 255),

    _candidate('5701', '1701', 'MIT', 'Research output and engineering innovation leader.', 'https://source.unsplash.com/600x600/?engineering,university', 258, 296),
    _candidate('5702', '1701', 'Stanford University', 'Strong startup pipeline and interdisciplinary strength.', 'https://source.unsplash.com/600x600/?campus,technology', 246, 289),
    _candidate('5703', '1701', 'ETH Zurich', 'Global engineering reputation and research depth.', 'https://source.unsplash.com/600x600/?university,lab', 224, 271),
    _candidate('5704', '1701', 'NUS', 'Excellent engineering programs in Asia.', 'https://source.unsplash.com/600x600/?college,asia', 211, 263),
    _candidate('5705', '1701', 'Tsinghua University', 'Strong STEM excellence and impact.', 'https://source.unsplash.com/600x600/?campus,science', 206, 258),
    _candidate('5706', '1701', 'Imperial College London', 'High-level engineering and industry links.', 'https://source.unsplash.com/600x600/?university,city', 202, 252),

    _candidate('5711', '1702', 'National University of Singapore', 'Consistent all-round academic excellence.', 'https://source.unsplash.com/600x600/?singapore,university', 239, 281),
    _candidate('5712', '1702', 'Peking University', 'Leading research and academic rigor.', 'https://source.unsplash.com/600x600/?china,university', 226, 273),
    _candidate('5713', '1702', 'Tsinghua University', 'Top engineering and science leadership.', 'https://source.unsplash.com/600x600/?beijing,campus', 231, 276),
    _candidate('5714', '1702', 'University of Tokyo', 'Historic excellence and research quality.', 'https://source.unsplash.com/600x600/?japan,university', 219, 268),
    _candidate('5715', '1702', 'HKU', 'Strong international recognition and outcomes.', 'https://source.unsplash.com/600x600/?hongkong,university', 204, 254),
    _candidate('5716', '1702', 'KAIST', 'Innovation-forward institution with strong tech focus.', 'https://source.unsplash.com/600x600/?korea,university', 197, 247),

    _candidate('5721', '1703', 'UCLA', 'Active student culture with diverse activities.', 'https://source.unsplash.com/600x600/?student,campus', 221, 266),
    _candidate('5722', '1703', 'University of Melbourne', 'Vibrant clubs and balanced student lifestyle.', 'https://source.unsplash.com/600x600/?college,students', 214, 261),
    _candidate('5723', '1703', 'University of British Columbia', 'Scenic campus and strong community culture.', 'https://source.unsplash.com/600x600/?university,park', 208, 257),
    _candidate('5724', '1703', 'Nanyang Technological University', 'Modern campus with active student organizations.', 'https://source.unsplash.com/600x600/?modern,campus', 203, 251),
    _candidate('5725', '1703', 'University of Manchester', 'Energetic city-campus student life.', 'https://source.unsplash.com/600x600/?city,campus-life', 196, 244),
    _candidate('5726', '1703', 'Seoul National University', 'Strong academics and campus engagement.', 'https://source.unsplash.com/600x600/?university,korea', 192, 239),

    _candidate('5801', '1801', 'Python', 'Readable syntax and huge ecosystem adoption.', 'https://source.unsplash.com/600x600/?python,code', 271, 329),
    _candidate('5802', '1801', 'TypeScript', 'Type safety with modern JavaScript tooling.', 'https://source.unsplash.com/600x600/?typescript,developer', 258, 321),
    _candidate('5803', '1801', 'Rust', 'Performance and safety with growing community.', 'https://source.unsplash.com/600x600/?rust,programming', 234, 302),
    _candidate('5804', '1801', 'Go', 'Simple concurrency model and backend popularity.', 'https://source.unsplash.com/600x600/?golang,code', 219, 289),
    _candidate('5805', '1801', 'Kotlin', 'Developer-friendly language with modern design.', 'https://source.unsplash.com/600x600/?kotlin,software', 206, 278),
    _candidate('5806', '1801', 'Java', 'Enterprise stability and broad ecosystem support.', 'https://source.unsplash.com/600x600/?java,developer', 198, 271),

    _candidate('5811', '1802', 'Go', 'Strong concurrency and easy deployment at scale.', 'https://source.unsplash.com/600x600/?backend,server', 239, 286),
    _candidate('5812', '1802', 'Java', 'Mature frameworks and enterprise reliability.', 'https://source.unsplash.com/600x600/?backend,java', 227, 279),
    _candidate('5813', '1802', 'C#', 'Robust ecosystem for scalable web backends.', 'https://source.unsplash.com/600x600/?dotnet,backend', 214, 267),
    _candidate('5814', '1802', 'Node.js', 'Fast iteration with a massive package ecosystem.', 'https://source.unsplash.com/600x600/?nodejs,server', 223, 274),
    _candidate('5815', '1802', 'Python', 'Rapid API development and data integration.', 'https://source.unsplash.com/600x600/?python,backend', 209, 261),
    _candidate('5816', '1802', 'Rust', 'High-performance services with memory safety.', 'https://source.unsplash.com/600x600/?systems,code', 192, 248),

    _candidate('5821', '1803', 'Kotlin', 'Native Android development with clean syntax.', 'https://source.unsplash.com/600x600/?android,developer', 244, 289),
    _candidate('5822', '1803', 'Swift', 'Primary iOS language with strong tooling.', 'https://source.unsplash.com/600x600/?ios,code', 236, 283),
    _candidate('5823', '1803', 'Dart', 'Excellent with Flutter for cross-platform apps.', 'https://source.unsplash.com/600x600/?flutter,mobile-app', 251, 296),
    _candidate('5824', '1803', 'JavaScript', 'Cross-platform flexibility with hybrid stacks.', 'https://source.unsplash.com/600x600/?javascript,mobile', 198, 257),
    _candidate('5825', '1803', 'TypeScript', 'Safer large-scale hybrid mobile projects.', 'https://source.unsplash.com/600x600/?typescript,mobile', 204, 263),
    _candidate('5826', '1803', 'C#', 'Strong option via .NET MAUI and game/mobile crossover.', 'https://source.unsplash.com/600x600/?csharp,mobile', 186, 246),

    _candidate('5901', '1901', 'Bali', 'Mix of beaches, culture, and affordability.', 'https://source.unsplash.com/600x600/?bali,beach', 242, 298),
    _candidate('5902', '1901', 'Maldives', 'Luxury overwater escapes and clear lagoons.', 'https://source.unsplash.com/600x600/?maldives,ocean', 236, 291),
    _candidate('5903', '1901', 'Phuket', 'Accessible island experience with lively beaches.', 'https://source.unsplash.com/600x600/?phuket,beach', 214, 276),
    _candidate('5904', '1901', 'Boracay', 'Powdery sand and vibrant sunset views.', 'https://source.unsplash.com/600x600/?boracay,sea', 207, 268),
    _candidate('5905', '1901', 'Santorini', 'Cliffside views and iconic coastal scenery.', 'https://source.unsplash.com/600x600/?santorini,beach', 219, 281),
    _candidate('5906', '1901', 'Langkawi', 'Relaxed beaches with nature attractions.', 'https://source.unsplash.com/600x600/?langkawi,island', 196, 254),

    _candidate('5911', '1902', 'Tokyo', 'Diversity from street food to Michelin dining.', 'https://source.unsplash.com/600x600/?tokyo,food', 248, 301),
    _candidate('5912', '1902', 'Bangkok', 'Street food depth with strong value.', 'https://source.unsplash.com/600x600/?bangkok,street-food', 239, 296),
    _candidate('5913', '1902', 'Istanbul', 'Rich culinary heritage across cultures.', 'https://source.unsplash.com/600x600/?istanbul,food', 214, 279),
    _candidate('5914', '1902', 'Penang', 'Legendary hawker scene and local classics.', 'https://source.unsplash.com/600x600/?penang,hawker', 226, 288),
    _candidate('5915', '1902', 'Seoul', 'Fast-evolving food culture and nightlife.', 'https://source.unsplash.com/600x600/?seoul,restaurant', 208, 271),
    _candidate('5916', '1902', 'Barcelona', 'Tapas and market culture with Mediterranean flair.', 'https://source.unsplash.com/600x600/?barcelona,food-market', 202, 265),

    _candidate('5921', '1903', 'New Zealand South Island', 'Cinematic mountains, lakes, and road-trip routes.', 'https://source.unsplash.com/600x600/?new-zealand,nature', 237, 284),
    _candidate('5922', '1903', 'Banff National Park', 'Turquoise lakes and alpine landscapes.', 'https://source.unsplash.com/600x600/?banff,mountains', 231, 278),
    _candidate('5923', '1903', 'Swiss Alps', 'Iconic alpine scenery and trail quality.', 'https://source.unsplash.com/600x600/?swiss,alps', 223, 272),
    _candidate('5924', '1903', 'Iceland Ring Road', 'Volcanic terrain and dramatic natural contrasts.', 'https://source.unsplash.com/600x600/?iceland,landscape', 216, 266),
    _candidate('5925', '1903', 'Patagonia', 'Remote wilderness and epic trekking routes.', 'https://source.unsplash.com/600x600/?patagonia,hiking', 209, 259),
    _candidate('5926', '1903', 'Yosemite National Park', 'Granite cliffs and world-class hiking views.', 'https://source.unsplash.com/600x600/?yosemite,nature', 204, 254),
  ];

  static const Map<String, MockTopicStats> topicStats = {
    '1001': MockTopicStats(topicId: '1001', totalVotes: 2431, candidateCount: 6, aiSummary: 'Messi and Ronaldo are virtually neck and neck, while Maradona and Ronaldinho remain strong legacy picks among long-time voters.'),
    '1002': MockTopicStats(topicId: '1002', totalVotes: 1884, candidateCount: 6, aiSummary: 'Arsenal Invincibles and modern Manchester City dominate the top two, with Liverpool and Manchester United close behind.'),
    '1003': MockTopicStats(topicId: '1003', totalVotes: 1652, candidateCount: 6, aiSummary: 'Buffon and Neuer lead by a clear margin, while Casillas remains the most common third choice across ballots.'),
    '1101': MockTopicStats(topicId: '1101', totalVotes: 2730, candidateCount: 6, aiSummary: 'Endgame and Infinity War continue to trade the lead, with No Way Home showing a late surge from newer voters.'),
    '1102': MockTopicStats(topicId: '1102', totalVotes: 2198, candidateCount: 6, aiSummary: 'The Dark Knight edges Interstellar by a slim margin, while Inception holds a stable third place.'),
    '1103': MockTopicStats(topicId: '1103', totalVotes: 2035, candidateCount: 6, aiSummary: 'Spirited Away remains first overall, but Spider-Verse consistently tops younger voter submissions.'),
    '1201': MockTopicStats(topicId: '1201', totalVotes: 2864, candidateCount: 6, aiSummary: 'One Piece leads decisively, with Attack on Titan and Naruto competing tightly for the second position.'),
    '1202': MockTopicStats(topicId: '1202', totalVotes: 1716, candidateCount: 6, aiSummary: 'Madara and Meruem score highly on intensity and writing depth, while Johan remains a niche favorite.'),
    '1203': MockTopicStats(topicId: '1203', totalVotes: 1927, candidateCount: 6, aiSummary: 'Gurenge and Cruel Angel Thesis dominate first-place votes, while Unravel performs strongly in top-three placements.'),
    '1301': MockTopicStats(topicId: '1301', totalVotes: 2241, candidateCount: 6, aiSummary: 'Nasi Lemak is the clear community favorite, with Char Kway Teow and Laksa consistently rounding out the podium.'),
    '1302': MockTopicStats(topicId: '1302', totalVotes: 2014, candidateCount: 6, aiSummary: 'McDonald\'s and KFC lead overall familiarity rankings, while Five Guys scores well among taste-focused voters.'),
    '1303': MockTopicStats(topicId: '1303', totalVotes: 1768, candidateCount: 6, aiSummary: 'Ice Cream and Cheesecake dominate broad appeal votes, while Tiramisu maintains strong support among premium dessert fans.'),
    '1401': MockTopicStats(topicId: '1401', totalVotes: 2126, candidateCount: 6, aiSummary: 'iPhone 17 Pro and Galaxy S26 Ultra are close at the top, with Pixel 10 Pro favored for software intelligence.'),
    '1402': MockTopicStats(topicId: '1402', totalVotes: 1988, candidateCount: 6, aiSummary: 'Galaxy S26 Ultra leads camera versatility, while Pixel 10 Pro wins the most votes for natural color processing.'),
    '1403': MockTopicStats(topicId: '1403', totalVotes: 1632, candidateCount: 6, aiSummary: 'Redmi Note 15 Pro currently tops value rankings, with Galaxy A56 close behind on reliability and updates.'),
    '1501': MockTopicStats(topicId: '1501', totalVotes: 2543, candidateCount: 6, aiSummary: 'Breath of the Wild and Elden Ring dominate first-place ballots, while RDR2 remains highly consistent in top-three picks.'),
    '1502': MockTopicStats(topicId: '1502', totalVotes: 2318, candidateCount: 6, aiSummary: 'Mobile Legends and PUBG Mobile share most of the top slots, with Genshin Impact strong in engagement-heavy regions.'),
    '1503': MockTopicStats(topicId: '1503', totalVotes: 2171, candidateCount: 6, aiSummary: 'Baldur\'s Gate 3 leads by depth and replayability, with The Witcher 3 and Persona 5 Royal forming a strong chasing pack.'),
    '1601': MockTopicStats(topicId: '1601', totalVotes: 1876, candidateCount: 6, aiSummary: 'Ferrari SF90 currently leads the supercar vote, while 911 Turbo S gains points from daily usability supporters.'),
    '1602': MockTopicStats(topicId: '1602', totalVotes: 2440, candidateCount: 6, aiSummary: 'Toyota and Honda remain the top two reliability picks, with Lexus frequently chosen for premium ownership confidence.'),
    '1603': MockTopicStats(topicId: '1603', totalVotes: 2089, candidateCount: 6, aiSummary: 'Tesla Model 3 holds first place on ecosystem strength, while Ioniq 5 rises on charging and practicality metrics.'),
    '1701': MockTopicStats(topicId: '1701', totalVotes: 1734, candidateCount: 6, aiSummary: 'MIT and Stanford are clear frontrunners, with ETH Zurich keeping a stable third across most cohorts.'),
    '1702': MockTopicStats(topicId: '1702', totalVotes: 1641, candidateCount: 6, aiSummary: 'NUS and Tsinghua exchange the lead depending on voter region, while University of Tokyo remains consistently top four.'),
    '1703': MockTopicStats(topicId: '1703', totalVotes: 1526, candidateCount: 6, aiSummary: 'UCLA leads campus life sentiment, while UBC and Melbourne remain close among international student voters.'),
    '1801': MockTopicStats(topicId: '1801', totalVotes: 2891, candidateCount: 6, aiSummary: 'Python leads overall affection, while TypeScript and Rust show the fastest growth in first-place submissions.'),
    '1802': MockTopicStats(topicId: '1802', totalVotes: 2217, candidateCount: 6, aiSummary: 'Go and Java are tied near the top for backend confidence, with Node.js leading among startup-focused teams.'),
    '1803': MockTopicStats(topicId: '1803', totalVotes: 2142, candidateCount: 6, aiSummary: 'Dart and Kotlin dominate mobile-focused voting, with Swift holding strong in iOS-first communities.'),
    '1901': MockTopicStats(topicId: '1901', totalVotes: 2380, candidateCount: 6, aiSummary: 'Bali and Maldives remain top beach choices, while Santorini scores highest on scenic appeal.'),
    '1902': MockTopicStats(topicId: '1902', totalVotes: 2296, candidateCount: 6, aiSummary: 'Tokyo currently leads overall, but Bangkok and Penang are rapidly gaining from value-driven food travelers.'),
    '1903': MockTopicStats(topicId: '1903', totalVotes: 2055, candidateCount: 6, aiSummary: 'New Zealand and Banff dominate nature rankings, with Iceland showing the strongest momentum this month.'),
  };

  static List<CategoryModel> getCategories() {
    return categories.map(_cloneCategory).toList();
  }

  static List<RankingListModel> getTopicsByCategory(String categoryId) {
    return topics
        .where((topic) => topic.categoryId == categoryId)
        .map(_cloneTopicModel)
        .toList();
  }

  static List<ItemModel> getCandidatesByTopic(String topicId) {
    return candidates
        .where((candidate) => candidate.listId == topicId)
        .map(_cloneCandidate)
        .toList();
  }

  static List<Map<String, dynamic>> getLeaderboardByTopic(String topicId) {
    final topicCandidates = getCandidatesByTopic(topicId)
      ..sort((a, b) => b.score.compareTo(a.score));

    final stats = topicStats[topicId];

    return topicCandidates
        .map(
          (item) => {
            'candidate_id': item.id,
            'name': item.name,
            'total_points': item.score,
            'votes_count': item.votesCount,
            'candidate_count': stats?.candidateCount ?? topicCandidates.length,
            'total_votes': stats?.totalVotes ?? 0,
            'ai_summary': stats?.aiSummary ?? '',
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> getDefaultUserRanking(String topicId) {
    final topThree = getCandidatesByTopic(topicId).take(3).toList();
    return List.generate(
      topThree.length,
      (index) => {
        'candidate_id': topThree[index].id,
        'position': index + 1,
      },
    );
  }

  static CategoryModel _category({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required int dayOffset,
  }) {
    return CategoryModel(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdBy: _systemUser,
      createdAt: DateTime.now().subtract(Duration(days: dayOffset)),
    );
  }

  static RankingListModel _topic(
    String id,
    String categoryId,
    String title,
    String description,
    int dayOffset,
  ) {
    return RankingListModel(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description,
      createdBy: _systemUser,
      createdAt: DateTime.now().subtract(Duration(days: dayOffset)),
      itemsCount: 6,
    );
  }

  static ItemModel _candidate(
    String id,
    String topicId,
    String name,
    String description,
    String imageUrl,
    int score,
    int votesCount,
  ) {
    return ItemModel(
      id: id,
      listId: topicId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      score: score.toDouble(),
      votesCount: votesCount,
    );
  }

  static CategoryModel _cloneCategory(CategoryModel item) {
    return CategoryModel(
      id: item.id,
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
    );
  }

  static RankingListModel _cloneTopicModel(RankingListModel item) {
    return RankingListModel(
      id: item.id,
      categoryId: item.categoryId,
      title: item.title,
      description: item.description,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
      itemsCount: item.itemsCount,
    );
  }

  static ItemModel _cloneCandidate(ItemModel item) {
    return ItemModel(
      id: item.id,
      listId: item.listId,
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      score: item.score,
      votesCount: item.votesCount,
    );
  }
}
