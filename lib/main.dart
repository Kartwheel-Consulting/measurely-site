import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'data/calculators.dart';
import 'pages/calculators_page.dart';
import 'pages/home_page.dart';
import 'pages/info_pages.dart';
import 'pages/pricing_page.dart';
import 'theme.dart';

void main() {
  // /pricing rather than /#/pricing. Needs the host to send every path to
  // index.html — render.yaml does that.
  usePathUrlStrategy();
  runApp(const MeasurelySite());
}

class MeasurelySite extends StatelessWidget {
  const MeasurelySite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measurely',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      onGenerateRoute: _route,
      // Open exactly the page in the address bar, not a stack of its parents.
      onGenerateInitialRoutes: (name) => [_route(RouteSettings(name: name))],
    );
  }
}

Route<void> _route(RouteSettings settings) {
  final page = pageFor(settings.name ?? '/');
  return PageRouteBuilder<void>(
    settings: settings,
    // Pages change instantly, the way a website does.
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => page,
  );
}

/// Which page a path shows. Public so the widget test can check every route.
Widget pageFor(String rawPath) {
  var path = Uri.tryParse(rawPath)?.path ?? '/';
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  switch (path) {
    case '':
    case '/':
      return const HomePage();
    case '/calculators':
      return const CalculatorsPage();
    case '/pricing':
      return const PricingPage();
    case '/faq':
      return const FaqPage();
    case '/contact':
      return const ContactPage();
    case '/privacy':
      return const PrivacyPage();
  }

  if (path.startsWith('/calculators/')) {
    final info = calculatorBySlug(path.substring('/calculators/'.length));
    if (info != null) {
      return CalculatorDetailPage(info: info);
    }
  }

  return const NotFoundPage();
}
