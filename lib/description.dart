import 'package:flutter/material.dart';
import 'package:cineverse/utils/text.dart';

class Description extends StatelessWidget {
  final String? name, description, bannerurl, posterurl, vote, launchOn;

  const Description({
    super.key,
    this.name,
    this.description,
    this.bannerurl,
    this.posterurl,
    this.vote,
    this.launchOn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Positioned(
                    child: SizedBox(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        bannerurl ?? '', // Provide a default empty string
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: ModifiedText(
                      text: 'Average rating - ${vote ?? 'N/A'}',
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              child: ModifiedText(
                text: name != null ? name! : 'Not Loaded',
                size: 24,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: ModifiedText(
                text: 'Releasing on - ${launchOn ?? 'N/A'}',
                size: 14,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  height: 200,
                  width: 100,
                  child: Image.network(
                      posterurl ?? ''), // Provide a default empty string
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: ModifiedText(
                      text: description ?? '', // Provide a default empty string
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
