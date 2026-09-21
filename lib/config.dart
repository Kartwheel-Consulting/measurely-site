/// Everything about the company and the links that changes without a code
/// change elsewhere. Edit here, rebuild, redeploy.
class SiteConfig {
  SiteConfig._();

  static const product = 'Measurely';
  static const tagline = 'Measurement-based pricing for Shopify';
  static const publisher = 'Kartwheel Consulting';
  static const locations = 'London · Chennai';
  static const publisherWebsite = 'https://kartwheelconsulting.com';

  /// >>> CHANGE THIS TO A MAILBOX THAT EXISTS AND IS MONITORED. <<<
  /// It is the same placeholder the app uses. Keep the two identical.
  static const supportEmail = 'support@kartwheelconsulting.com';
  static const responseTime = 'within one business day, Monday to Friday';

  /// The Shopify App Store listing. Null until the listing is approved.
  ///
  /// While it is null every "Install" button becomes "Request early access"
  /// and opens an email instead, so the site never links to a page that does
  /// not exist yet. Once approved, set it to the listing URL, e.g.
  /// `https://apps.shopify.com/your-app-handle`.
  static const String? appStoreUrl = null;

  static bool get isListed => appStoreUrl != null;

  static String get installLabel =>
      isListed ? 'Install on Shopify' : 'Request early access';

  static String get earlyAccessMailto =>
      'mailto:$supportEmail?subject=${Uri.encodeComponent('Measurely early access')}';

  static String get installHref => appStoreUrl ?? earlyAccessMailto;
}
