import 'package:thewhsherbiker/api/app_config.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
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
      print('🔄 Socket connection already in progress');
      return;
    }

    // If already connected, don't create a new connection
    if (_socket != null && _socket!.connected) {
      print('✅ Socket already connected');
      return;
    }

    // If socket exists but is disconnected, dispose it first
    if (_socket != null && !_socket!.connected) {
      print('🔄 Socket exists but disconnected, disposing old socket...');
      _socket!.clearListeners();
      _socket!.dispose();
      _socket = null;
    }

    try {
      _isConnecting = true;
      print('🔌 Initiating socket connection...');
      print('🔑 Using token: ${AppShared.token.substring(0, 20)}...');

      var url = AppConfig.getSocketBaseUrl();
      print('🌐 Connecting to: $url');

      _socket = IO.io(url, <String, dynamic>{
        'autoConnect': false,
        'transports': ['websocket'],
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'reconnectionAttempts': 10, // Increased attempts
        'timeout': 20000, // 20 second timeout
      });
      print('🔑 Using token: ${AppShared.token}...');
      _socket!.io.options!['extraHeaders'] = {
        'authorization': 'Bearer ${AppShared.token}'
      };

      // Set up listeners before connecting
      _socket!.onConnect((_) {
        print('✅ Socket connection established');
        print('✅ Socket ID: ${_socket!.id}');
        print('✅ Socket connected: ${_socket!.connected}');
      });

      _socket!.onDisconnect((reason) {
        print('⚠️ Socket disconnected. Reason: $reason');
        print('⚠️ Will auto-reconnect due to reconnection: true setting');
      });

      _socket!.onReconnect((attemptNumber) {
        print('🔄 Socket reconnected after $attemptNumber attempts');
      });

      _socket!.onReconnectAttempt((attemptNumber) {
        print('🔄 Reconnection attempt #$attemptNumber');
      });

      _socket!.onReconnectError((err) {
        print('❌ Reconnection error: $err');
      });

      _socket!.onReconnectFailed((data) {
        print('❌ Reconnection failed after all attempts');
        if (_onErrorCallback != null) {
          _onErrorCallback!('Reconnection failed: $data');
        }
      });

      _socket!.onConnectError((err) {
        print('❌ Socket connection error: $err');
        if (_onErrorCallback != null) {
          _onErrorCallback!('Connection error: $err');
        }
      });

      _socket!.onError((err) {
        print('❌ Socket error: $err');
        if (_onErrorCallback != null) {
          _onErrorCallback!('Socket error: $err');
        }
      });

      _socket!.on('order:published', (data) {
        print('📦 New order received: $data');
        try {
          final order = GenericResponse(
            json: data,
            fromJson: OrderModel.fromJson,
          ).result!;
          if (_onNewOrderCallback != null) {
            _onNewOrderCallback!(order);
          }
        } catch (e) {
          print('❌ Error parsing order data: $e');
          if (_onErrorCallback != null) {
            _onErrorCallback!('Error parsing order: $e');
          }
        }
      });

      // Now connect
      _socket!.connect();
      print('🔌 Socket connect() called');
    } catch (e) {
      print('❌ Socket connection setup error: $e');
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
      print('🔌 Disconnecting socket...');
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      print('✅ Socket disconnected and disposed');
    } else {
      print('⚠️ Socket was already null, no need to disconnect');
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
      print('📤 Emitting event: $event');
      _socket!.emit(event, data);
    } else {
      print('⚠️ Cannot emit event: Socket not connected');
    }
  }

  /// Clean up resources
  void dispose() {
    disconnect();
  }
}
