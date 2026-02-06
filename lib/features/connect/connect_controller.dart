import 'package:flutter/material.dart';

/// In-memory fake connection controller.
///
/// Keeps a small state-map and fakes a 2-second “API call” on connect.
class ConnectController with ChangeNotifier {
  ConnectController._();
  static final ConnectController _instance = ConnectController._();
  factory ConnectController() => _instance;

  final Map<Service, ConnectionStatus> _state = {
    Service.hydro:         ConnectionStatus.idle,
    Service.googleFit:     ConnectionStatus.idle,
    Service.samsungHealth: ConnectionStatus.idle,
  };

  ConnectionStatus stateOf(Service s) => _state[s]!;

  /// Starts a fake 2 s connection flow.
  Future<void> connect(Service s) async {
    if (_state[s] != ConnectionStatus.idle) return;
    _state[s] = ConnectionStatus.connecting;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _state[s] = ConnectionStatus.connected;
    notifyListeners();
  }

  /// Resets a service back to *idle* (used by the bottom-sheet demo).
  Future<void> disconnect(Service s) async {
    _state[s] = ConnectionStatus.idle;
    notifyListeners();
  }
}

/// Available third-party services.
enum Service { hydro, googleFit, samsungHealth }

/// UI state per service.
enum ConnectionStatus { idle, connecting, connected }
