import 'package:flutter/material.dart';
import 'package:cineverse/utils/text.dart';

class TV extends StatelessWidget {
  final List<dynamic> tv;
  const TV({
    super.key,
    required this.tv,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModifiedText(
            text: 'Popular TV Shows',
            size: 26,
          ),
          const SizedBox(height: 10),
          SizedBox(
              height: 270,
              child: ListView.builder(
                  itemCount: tv.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {},
                      child: SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SizedBox(
                            width: 250,
                            child: Column(
                              children: [
                                Container(
                                  width: 250,
                                  height: 140,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            'https://image.tmdb.org/t/p/w500${tv[index]['backdrop_path']}',
                                          ),
                                          fit: BoxFit.cover)),
                                ),
                                const SizedBox(height: 10),
                                ModifiedText(
                                    text:
                                        tv[index]['original_name'] ?? 'Loading')
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
