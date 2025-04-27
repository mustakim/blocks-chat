import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/utils/typedefs.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRepo {
  ResultFuture<ChatResponseModel> sendChatMessage(String content);
  Future<WebSocketChannel> connect();
  StreamSubscription<dynamic> sendWebSocketMessage(String message);
  Future<WebSocketChannel> disconnect();
}
