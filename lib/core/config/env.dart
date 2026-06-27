class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://api-balto.duckdns.org/api',
  );

  static const String signalrHubUrl = String.fromEnvironment(
    'SIGNALR_HUB_URL',
    defaultValue: 'http://api-balto.duckdns.org/hubs',
  );
}
