// Renders every page at desktop and phone width. Catches layout errors
// (overflows, unbounded sizes) that only show up once a page is drawn.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measurely_site/data/calculators.dart';
import 'package:measurely_site/main.dart';
import 'package:measurely_site/pages/calculators_page.dart';
import 'package:measurely_site/pages/home_page.dart';
import 'package:measurely_site/pages/info_pages.dart';
import 'package:measurely_site/pages/pricing_page.dart';
import 'package:measurely_site/theme.dart';

const sizes = {
  'desktop': Size(1440, 900),
  'phone': Size(390, 844),
};

final routes = <String>[
  '/',
  '/calculators',
  for (final c in calculators) '/calculators/${c.slug}',
  '/pricing',
  '/faq',
  '/contact',
  '/privacy',
];

Future<void> pump(WidgetTester tester, Widget page, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: page));
  await tester.pump();
}

void main() {
  group('routing', () {
    test('every path resolves to the right page', () {
      expect(pageFor('/'), isA<HomePage>());
      expect(pageFor('/calculators'), isA<CalculatorsPage>());
      expect(pageFor('/calculators/'), isA<CalculatorsPage>());
      expect(pageFor('/pricing'), isA<PricingPage>());
      expect(pageFor('/pricing?ref=x'), isA<PricingPage>());
      expect(pageFor('/faq'), isA<FaqPage>());
      expect(pageFor('/contact'), isA<ContactPage>());
      expect(pageFor('/privacy'), isA<PrivacyPage>());
      for (final c in calculators) {
        expect(pageFor('/calculators/${c.slug}'), isA<CalculatorDetailPage>(),
            reason: c.slug);
      }
    });

    test('unknown paths are a 404, not the home page', () {
      expect(pageFor('/nope'), isA<NotFoundPage>());
      expect(pageFor('/calculators/nope'), isA<NotFoundPage>());
    });

    test('calculator slugs are unique', () {
      final slugs = calculators.map((c) => c.slug).toSet();
      expect(slugs.length, calculators.length);
    });
  });

  for (final entry in sizes.entries) {
    for (final route in routes) {
      testWidgets('$route renders on ${entry.key}', (tester) async {
        await pump(tester, pageFor(route), entry.value);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the home demo shows the right starting price', (tester) async {
    await pump(tester, const HomePage(), sizes['desktop']!);
    // 120 × 60 cm = 0.72 m² at $85/m² = $61.20, above the $25 floor.
    expect(find.text(r'$61.20'), findsOneWidget);
  });

  testWidgets('typing a smaller size lifts the price to the floor',
      (tester) async {
    await pump(tester, CalculatorDetailPage(info: calculators.first),
        sizes['desktop']!);
    // 20 × 10 cm = 0.02 m² → $1.70, lifted to the $25.00 product price.
    await tester.enterText(find.widgetWithText(TextField, 'Length'), '20');
    await tester.enterText(find.widgetWithText(TextField, 'Width'), '10');
    await tester.pumpAndSettle(); // the price rolls to its new value
    expect(find.text(r'$25.00'), findsWidgets);
    expect(find.textContaining('the floor'), findsOneWidget);
  });

  testWidgets('an invalid size is flagged at the field itself', (tester) async {
    await pump(tester, CalculatorDetailPage(info: calculators.first),
        sizes['desktop']!);
    expect(find.text('Enter a size above 0'), findsNothing);
    await tester.enterText(find.widgetWithText(TextField, 'Length'), '0');
    await tester.pumpAndSettle();
    expect(find.text('Enter a size above 0'), findsOneWidget);
  });

  testWidgets('the quantity stepper changes the total', (tester) async {
    await pump(tester, CalculatorDetailPage(info: calculators.first),
        sizes['desktop']!);
    final more = find.byTooltip('More');
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(find.text('Total for 3'), findsOneWidget);
  });

  testWidgets('the diagram describes the size for screen readers',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, CalculatorDetailPage(info: calculators.first),
        sizes['desktop']!);
    expect(find.bySemanticsLabel('Diagram of 120 cm by 60 cm'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('filtering calculators narrows the list', (tester) async {
    await pump(tester, const CalculatorsPage(), sizes['desktop']!);
    expect(find.text('Try it live', skipOffstage: false),
        findsNWidgets(calculators.length));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Volume'));
    await tester.pumpAndSettle();
    expect(find.text('Try it live', skipOffstage: false), findsNWidgets(2));
  });

  testWidgets('the yearly toggle shows the yearly saving', (tester) async {
    await pump(tester, const PricingPage(), sizes['desktop']!);
    expect(find.text(r'Save $41 a year'), findsNothing);
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(find.text(r'Save $41 a year'), findsOneWidget);
  });

  testWidgets('a closed FAQ question opens when tapped', (tester) async {
    await pump(tester, const FaqPage(), sizes['desktop']!);
    final question = find.text('Which ways of measuring does it support?');
    expect(find.textContaining('Nine: area'), findsNothing);
    await tester.ensureVisible(question);
    await tester.tap(question);
    await tester.pumpAndSettle();
    expect(find.textContaining('Nine: area'), findsOneWidget);
  });
}
