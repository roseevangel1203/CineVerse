import 'dart:ui' show Size;

import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:cineverse/data/demo_catalog.dart';
import 'package:cineverse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('first launch offers guest browsing', (tester) async {
    await tester.pumpWidget(const CineVerseApp());
    await tester.pumpAndSettle();
    expect(find.text('CINEVERSE'), findsOneWidget);
    expect(find.text('Continue browsing as guest'), findsOneWidget);
  });

  test('demo catalogue supports local category and text filtering', () {
    expect(DemoCatalog.browse('movie').length, greaterThan(1));
    expect(DemoCatalog.browse('tv').every((item) => item['media_type'] == 'tv'),
        isTrue);
    expect(
        DemoCatalog.search('monsoon', 'multi')
            .any((item) => item['title'] == 'Midnight in Monsoon City'),
        isTrue);
  });

  testWidgets('no TMDB credential opens demo home and local watchlist works',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'entered': true});
    await tester.pumpWidget(const CineVerseApp());
    await tester.pumpAndSettle();

    expect(find.text('OFFLINE DEMO · ORIGINAL SAMPLE TITLES'), findsOneWidget);
    expect(find.text('Midnight in Monsoon City'), findsWidgets);

    await tester.tap(find.text('Explore title'));
    await tester.pumpAndSettle();
    expect(find.text('DEMO SAMPLE · NOT TMDB DATA'), findsOneWidget);
    await tester.tap(find.text('Add to My List'));
    await tester.pumpAndSettle();
    expect(find.text('In My List'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My List'));
    await tester.pumpAndSettle();
    expect(find.text('Midnight in Monsoon City'), findsWidgets);
  });
}
