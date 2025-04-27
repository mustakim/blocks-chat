import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/usecase/usecase.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/utils/typedefs.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/models/dashboard_model.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/repos/dashboard_repo.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DashboardUseCase extends UseCaseWithParams<ChatResponseModel, ChatParams> {
  const DashboardUseCase(this._repo);

  final DashboardRepo _repo;

  @override
  ResultFuture<ChatResponseModel> call(ChatParams params) => _repo.sendChatMessage(params.content);
}

class DashboardWebSocketUseCase extends UseCaseWithParams<WebSocketChannel, ChatParams> {
  const DashboardWebSocketUseCase(this._repo);

  final DashboardRepo _repo;

  @override
  ResultFuture<WebSocketChannel> call(ChatParams params) async {
    final result = await _repo.connect();
    return Right(result);
  }

  ResultFuture<StreamSubscription> sendWebSocketMessage(ChatParams params) async {
    final result = _repo.sendWebSocketMessage(params.content);
    return Right(result);
  }

  ResultFuture<WebSocketChannel> disconnect(ChatParams params) async {
    final result = await _repo.disconnect();
    return Right(result);
  }
}
