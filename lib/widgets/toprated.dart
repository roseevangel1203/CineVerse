import 'package:flutter/material.dart';
import 'package:cineverse/utils/text.dart';

class TopRatedMovies extends StatelessWidget {
  final List<dynamic> toprated;
  const TopRatedMovies({
    super.key,
    required this.toprated,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModifiedText(
            text: 'Top Rated Movies',
            size: 26,
          ),
          const SizedBox(height: 10),
          SizedBox(
              height: 270,
              child: ListView.builder(
                  itemCount: toprated.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {},
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          'https://image.tmdb.org/t/p/w500${toprated[index]['poster_path']}'))),
                            ),
                            ModifiedText(
                                text: toprated[index]['title'] ?? 'Loading')
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
