import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/network/dio_service.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/network/network_exceptions.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/utils/typedefs.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/common/domain/models/object_response_model.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/models/dashboard_model.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class DashboardRemoteDataSource {
  Future<ChatResponseModel> sendChatMessage(String content);
  Future<WebSocketChannel> connect();
  StreamSubscription<dynamic> sendWebSocketMessage(String message);
  Future<WebSocketChannel> disconnect();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this.dioService, this.channel);

  final DioService dioService;
  WebSocketChannel channel;

  @override
  Future<ChatResponseModel> sendChatMessage(String content) async {
    try {
      final response = await dioService.post<JSON>(
        endpoint: dotenv.get('CHAT_COMPLETION_URL'),
        data: {
          'model': "inference-llama33-70b",
          'messages': [
            {"role": "user", "content": content}
          ],
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${dotenv.get('CHAT_API_KEY')}',
          },
        ),
      );

      return ChatResponseModel.fromJson(response.body, DashboardModel.fromJson);
    } on DioException catch (ex) {
      throw CustomException.fromBlocksException(ex);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  Future<WebSocketChannel> connect() async {
    try {
      channel = WebSocketChannel.connect(Uri.parse(dotenv.get('SELISE_CLOUD_WS_CHAT_URL')));

      return channel;
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  StreamSubscription<dynamic> sendWebSocketMessage(String message) {
    try {
      channel.sink.add(jsonEncode(message));

      return channel.stream.listen(
        (data) {
          print(data);
        },
        onError: (error) => print(error),
      );
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  Future<WebSocketChannel> disconnect() async {
    try {
      channel.sink.close(status.normalClosure);
      return channel;
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }
}
