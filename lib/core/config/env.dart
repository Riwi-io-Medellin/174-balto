class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-balto.duckdns.org/api',
  );

  static const String signalrHubUrl = String.fromEnvironment(
    'SIGNALR_HUB_URL',
    defaultValue: 'https://api-balto.duckdns.org/hubs',
  );
}
