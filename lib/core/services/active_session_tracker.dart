/// Tracks which walk session (if any) the user currently has the live
/// tracking / chat screen open for, so push notifications for that session
/// (chat messages, media uploads) can be suppressed while it's already
/// visible in-app.
class ActiveSessionTracker {
  ActiveSessionTracker._();

  static String? _currentSessionId;

  static void enter(String sessionId) => _currentSessionId = sessionId;

  static void leave(String sessionId) {
    if (_currentSessionId == sessionId) _currentSessionId = null;
  }

  static bool isActive(String? sessionId) =>
      sessionId != null && sessionId == _currentSessionId;
}
