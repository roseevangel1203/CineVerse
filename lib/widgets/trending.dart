import 'package:flutter/material.dart';
import 'package:cineverse/utils/text.dart';

import '../description.dart';

class TrendingMovies extends StatelessWidget {
  final List<dynamic> trending;
  const TrendingMovies({
    super.key,
    required this.trending,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModifiedText(
            text: 'Trending Movies',
            size: 26,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: trending.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Description(
                          name: trending[index]['title'],
                          bannerurl:
                              'https://image.tmdb.org/t/p/w500${trending[index]['backdrop_path']}',
                          posterurl:
                              'https://image.tmdb.org/t/p/w500${trending[index]['poster_path']}',
                          description: trending[index]['overview'],
                          vote: trending[index]['vote_average'].toString(),
                          launchOn: trending[index]['release_date'],
                        ),
                      ),
                    );
                  },
                  child: trending[index]['title'] != null
                      ? SizedBox(
                          width: 140,
                          child: Column(
                            children: [
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500${trending[index]['poster_path']}',
                                    ),
                                  ),
                                ),
                              ),
                              ModifiedText(
                                  text: trending[index]['title'] ?? 'Loading'),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
