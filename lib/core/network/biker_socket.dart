import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:thewhsherbiker/api/app_config.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';

class SocketService {
  IO.Socket? _socket;
  bool _isConnecting = false;
  Function(OrderModel)? _onNewOrderCallback;
  Function(String)? _onErrorCallback;

  bool get isConnected => _socket?.connected ?? false;
  IO.Socket? get socket => _socket;

  /// Connect to the socket server
  Future<void> connect({
    required Function(OrderModel) onNewOrder,
    Function(String)? onError,
  }) async {
    // Store callbacks for reconnection
    _onNewOrderCallback = onNewOrder;
    _onErrorCallback = onError;

    // Prevent multiple simultaneous connection attempts
    if (_isConnecting) {
      debugPrint('🔄 Socket connection already in progress');
      return;
    }

    // If already connected, don't create a new connection
    if (_socket != null && _socket!.connected) {
      debugPrint('✅ Socket already connected');
      return;
    }

    // If socket exists but is disconnected, dispose it first
    if (_socket != null && !_socket!.connected) {
      debugPrint('🔄 Socket exists but disconnected, disposing old socket...');
      _socket!.clearListeners();
      _socket!.dispose();
      _socket = null;
    }

    try {
      _isConnecting = true;
      debugPrint('🔌 Initiating socket connection...');
      debugPrint('🔑 Using token: ${AppShared.token.substring(0, 20)}...');

      var url = AppConfig.getSocketBaseUrl();
      debugPrint('🌐 Connecting to: $url');

      _socket = IO.io(url, <String, dynamic>{
        'autoConnect': false,
        'transports': ['websocket'],
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'reconnectionAttempts': 10, // Increased attempts
        'timeout': 20000, // 20 second timeout
      });
      debugPrint('🔑 Using token: ${AppShared.token}...');
      _socket!.io.options!['extraHeaders'] = {
        'authorization': 'Bearer ${AppShared.token}'
      };

      // Set up listeners before connecting
      _socket!.onConnect((_) {
        debugPrint('✅ Socket connection established');
        debugPrint('✅ Socket ID: ${_socket!.id}');
        debugPrint('✅ Socket connected: ${_socket!.connected}');
      });

      _socket!.onDisconnect((reason) {
        debugPrint('⚠️ Socket disconnected. Reason: $reason');
        debugPrint('⚠️ Will auto-reconnect due to reconnection: true setting');
      });

      _socket!.onReconnect((attemptNumber) {
        debugPrint('🔄 Socket reconnected after $attemptNumber attempts');
      });

      _socket!.onReconnectAttempt((attemptNumber) {
        debugPrint('🔄 Reconnection attempt #$attemptNumber');
      });

      _socket!.onReconnectError((err) {
        debugPrint('❌ Reconnection error: $err');
      });

      _socket!.onReconnectFailed((data) {
        debugPrint('❌ Reconnection failed after all attempts');
        if (_onErrorCallback != null) {
          _onErrorCallback!('Reconnection failed: $data');
        }
      });

      _socket!.onConnectError((err) {
        debugPrint('❌ Socket connection error: $err');
        if (_onErrorCallback != null) {
          _onErrorCallback!('Connection error: $err');
        }
      });

      _socket!.onError((err) {
        debugPrint('❌ Socket error: $err');
        if (_onErrorCallback != null) {
          _onErrorCallback!('Socket error: $err');
        }
      });

      _socket!.on('order:published', (data) {
        debugPrint('📦 New order received: $data');
        try {
          final order = GenericResponse(
            json: data,
            fromJson: OrderModel.fromJson,
          ).result!;
          if (_onNewOrderCallback != null) {
            _onNewOrderCallback!(order);
          }
        } catch (e) {
          debugPrint('❌ Error parsing order data: $e');
          if (_onErrorCallback != null) {
            _onErrorCallback!('Error parsing order: $e');
          }
        }
      });

      // Now connect
      _socket!.connect();
      debugPrint('🔌 Socket connect() called');
    } catch (e) {
      debugPrint('❌ Socket connection setup error: $e');
      if (_onErrorCallback != null) {
        _onErrorCallback!('Setup error: $e');
      }
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect from the socket server
  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Disconnecting socket...');
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      debugPrint('✅ Socket disconnected and disposed');
    } else {
      debugPrint('⚠️ Socket was already null, no need to disconnect');
    }
  }

  /// Reconnect to the socket server
  Future<void> reconnect({
    required Function(OrderModel) onNewOrder,
    Function(String)? onError,
  }) async {
    disconnect();
    await connect(onNewOrder: onNewOrder, onError: onError);
  }

  /// Emit an event to the socket server
  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      debugPrint('📤 Emitting event: $event');
      _socket!.emit(event, data);
    } else {
      debugPrint('⚠️ Cannot emit event: Socket not connected');
    }
  }

  /// Clean up resources
  void dispose() {
    disconnect();
  }
}
