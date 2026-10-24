/// Small, original sample catalogue used when no TMDB credential is supplied.
/// Demo entries use public Unsplash photographs as illustrative artwork.
class DemoCatalog {
  // These are direct Unsplash CDN image IDs. They are used only for original
  // demo titles; they are thematic illustrations, not official movie posters.
  static const Map<int, String> _photoByTitle = {
    910001: 'photo-1676351119445-0b221c96e638', // rainy taxi and city
    910002: 'photo-1462331940025-496dfbfc7564', // nebula and deep space
    910003: 'photo-1525307932909-fd14b501d8d3', // antique library shelves
    910004: 'photo-1756738758023-97a5c14b492c', // wet city at night
    910005: 'photo-1470252649378-9c29740c9fa8', // golden countryside
    910006: 'photo-1462331940025-496dfbfc7564', // nebula and deep space
    910007: 'photo-1568125341624-be3bb6554abb', // Kyoto lantern alley
    910008: 'photo-1620734631260-5a3915458976', // alpine rescue helicopter
    910009: 'photo-1500375592092-40eb2168fd21', // sea at blue hour
    910010: 'photo-1525307932909-fd14b501d8d3', // antique library shelves
    910011: 'photo-1560537693-d17c10fc668f', // underwater exploration
    910012: 'photo-1500375592092-40eb2168fd21', // ocean and coastline
    920001: 'photo-1764705448662-f74992067ff7', // empty night platform
    920002: 'photo-1556911220-e15b29be8c8f', // restaurant kitchen
    920003: 'photo-1676351119445-0b221c96e638', // late-night city radio mood
    920004: 'photo-1756738758023-97a5c14b492c', // rain-soaked city
    920005: 'photo-1525307932909-fd14b501d8d3', // archive shelves
    920006: 'photo-1620734631260-5a3915458976', // alpine rescue helicopter
    920007: 'photo-1462331940025-496dfbfc7564', // deep-space mission mood
    920008: 'photo-1568125341624-be3bb6554abb', // lantern-lit street
  };

  static Map<String, String> _artwork(int id) {
    final photo = _photoByTitle[id];
    if (photo == null) return const {};
    const base = 'https://images.unsplash.com/';
    return {
      'poster_path': '$base$photo?auto=format&fit=crop&w=540&h=810&q=82',
      'backdrop_path': '$base$photo?auto=format&fit=crop&w=1600&h=900&q=84',
    };
  }

  static final List<Map<String, dynamic>> movies = [
    _movie(
      910001,
      'Midnight in Monsoon City',
      'A radio host and a night-shift taxi driver follow a mysterious broadcast through a rain-soaked city.',
      '2025-06-12',
      8.4,
      ['Drama', 'Mystery'],
      '142 min',
    ),
    _movie(
      910002,
      'The Last Signal',
      'A deep-space engineer receives a message that appears to come from a mission lost decades ago.',
      '2024-11-03',
      8.1,
      ['Science Fiction', 'Thriller'],
      '128 min',
    ),
    _movie(
      910003,
      'Paper Kingdom',
      'A young archivist uncovers a hand-drawn map hidden inside the final book from a closed library.',
      '2023-08-19',
      7.9,
      ['Drama', 'Adventure'],
      '116 min',
    ),
    _movie(
      910004,
      'Redline Protocol',
      'A rescue pilot races to expose a citywide infrastructure plot before the grid goes dark.',
      '2025-02-21',
      7.7,
      ['Action', 'Thriller'],
      '121 min',
    ),
    _movie(
      910005,
      'The Glass Orchard',
      'Returning home to settle an inheritance, two sisters discover that every tree in the orchard marks a family secret.',
      '2022-04-15',
      8.0,
      ['Drama', 'Mystery'],
      '109 min',
    ),
    _movie(
      910006,
      'Orbit House',
      'Six strangers share a research station on the edge of a newly discovered planet.',
      '2024-07-01',
      7.8,
      ['Science Fiction', 'Drama'],
      '134 min',
    ),
    _movie(
      910007,
      'Lanterns Over Kyoto',
      'A ceramic artist takes one last journey with the mentor who taught her to see beauty in imperfection.',
      '2021-10-08',
      8.6,
      ['Drama', 'Romance'],
      '103 min',
    ),
    _movie(
      910008,
      'Northbound',
      'A storm strands a mountain rescue team in a village that has vanished from every map.',
      '2025-01-17',
      7.5,
      ['Adventure', 'Action'],
      '127 min',
    ),
    _movie(
      910009,
      'Blue Hour',
      'Two former friends meet every year at dawn, until one of them fails to arrive.',
      '2020-05-22',
      7.6,
      ['Drama', 'Romance'],
      '98 min',
    ),
    _movie(
      910010,
      'The Seventh Archive',
      'A codebreaker finds a pattern linking seven unsolved disappearances across a century.',
      '2023-12-01',
      8.2,
      ['Mystery', 'Thriller'],
      '139 min',
    ),
    _movie(
      910011,
      'A Quiet Equation',
      'A mathematician and a marine biologist discover an unlikely rhythm in the deep ocean.',
      '2022-09-09',
      7.8,
      ['Science Fiction', 'Drama'],
      '112 min',
    ),
    _movie(
      910012,
      'Wild Coast',
      'A wildlife photographer returns to the coast where one extraordinary migration changed her life.',
      '2019-03-29',
      7.4,
      ['Adventure', 'Drama'],
      '105 min',
    ),
  ];

  static final List<Map<String, dynamic>> shows = [
    _show(
      920001,
      'Platform Nine',
      'Every night, a nearly empty station receives a train with passengers from a different decade.',
      '2025-03-06',
      8.7,
      ['Science Fiction', 'Mystery'],
      2,
      16,
    ),
    _show(
      920002,
      'Kitchen No. 8',
      'An ambitious chef and a mismatched kitchen crew try to keep a tiny neighborhood restaurant alive.',
      '2024-02-14',
      8.2,
      ['Comedy', 'Drama'],
      3,
      24,
    ),
    _show(
      920003,
      'Small Town Frequency',
      'A late-night community radio station becomes the unlikely center of a missing-person investigation.',
      '2023-09-27',
      8.5,
      ['Crime', 'Mystery'],
      2,
      18,
    ),
    _show(
      920004,
      'After the Monsoon',
      'Three neighbors rebuild their lives together after a season of record-breaking storms.',
      '2022-06-10',
      8.1,
      ['Drama', 'Family'],
      4,
      32,
    ),
    _show(
      920005,
      'The Archive Keepers',
      'A team of conservators protects rare collections and the stories hidden between their pages.',
      '2021-11-18',
      7.9,
      ['Drama', 'Mystery'],
      3,
      27,
    ),
    _show(
      920006,
      'Northbound: Rescue',
      'A mountain rescue unit answers calls from the most remote corners of the range.',
      '2024-08-02',
      7.7,
      ['Action', 'Adventure'],
      2,
      20,
    ),
    _show(
      920007,
      'Orbit House: Mission Log',
      'A documentary crew records the personal side of life aboard an experimental space station.',
      '2023-04-12',
      8.0,
      ['Science Fiction', 'Documentary'],
      1,
      8,
    ),
    _show(
      920008,
      'Lantern Street',
      'A small bookshop brings together people who thought they had run out of second chances.',
      '2020-01-25',
      7.8,
      ['Drama', 'Romance'],
      5,
      40,
    ),
  ];

  static final Map<String, List<Map<String, dynamic>>> homeSections = {
    'Trending Now': [...movies.take(5), ...shows.take(2)],
    'Popular Movies': movies,
    'Top Rated Movies': [...movies]..sort((a, b) =>
        (b['vote_average'] as num).compareTo(a['vote_average'] as num)),
    'Action': [...movies, ...shows]
        .where((item) => (item['genres'] as List).contains('Action'))
        .toList(),
    'Drama': [...movies, ...shows]
        .where((item) => (item['genres'] as List).contains('Drama'))
        .toList(),
    'Popular TV Shows': shows,
  };

  static List<Map<String, dynamic>> browse(String kind) {
    if (kind == 'tv') return shows;
    if (kind == 'movie') return movies;
    if (kind == 'multi') return [...movies, ...shows];
    return const [];
  }

  static List<Map<String, dynamic>> search(String query, String kind) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return browse(kind);
    return browse(kind).where((item) {
      final searchable = [
        item['title'],
        item['name'],
        item['overview'],
        ...(item['genres'] as List),
      ].join(' ').toLowerCase();
      return searchable.contains(normalized);
    }).toList();
  }

  static List<Map<String, dynamic>> similar(Map movie, String kind) {
    final id = movie['id'];
    final genres = (movie['genres'] as List?)?.toSet() ?? <Object>{};
    final candidates = browse(kind).where((item) => item['id'] != id);
    final matches = candidates
        .where((item) =>
            (item['genres'] as List).any((genre) => genres.contains(genre)))
        .toList();
    return (matches.isEmpty ? candidates.toList() : matches).take(8).toList();
  }

  static Map<String, dynamic> _movie(int id, String title, String overview,
          String date, double rating, List<String> genres, String runtime) =>
      {
        ..._artwork(id),
        'id': id,
        'media_type': 'movie',
        'title': title,
        'overview': overview,
        'release_date': date,
        'vote_average': rating,
        'genres': genres,
        'runtime': runtime,
        'original_language': 'en',
      };

  static Map<String, dynamic> _show(
          int id,
          String title,
          String overview,
          String date,
          double rating,
          List<String> genres,
          int seasons,
          int episodes) =>
      {
        ..._artwork(id),
        'id': id,
        'media_type': 'tv',
        'name': title,
        'overview': overview,
        'first_air_date': date,
        'vote_average': rating,
        'genres': genres,
        'number_of_seasons': seasons,
        'number_of_episodes': episodes,
        'original_language': 'en',
      };
}
