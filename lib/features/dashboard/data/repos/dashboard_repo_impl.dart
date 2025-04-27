import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/errors/failures.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/network/network_exceptions.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/utils/typedefs.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/models/dashboard_model.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/repos/dashboard_repo.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DashboardRepoImpl implements DashboardRepo {
  const DashboardRepoImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<ChatResponseModel> sendChatMessage(String content) async {
    try {
      final result = await _remoteDataSource.sendChatMessage(content);
      return Right(result);
    } on CustomException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode ?? 500,
      ));
    }
  }

  @override
  Future<WebSocketChannel> connect() async {
    try {
      WebSocketChannel channel = await _remoteDataSource.connect();
      return channel;
    } on CustomException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    }
  }

  @override
  StreamSubscription<dynamic> sendWebSocketMessage(String message) {
    try {
      return _remoteDataSource.sendWebSocketMessage(message);
    } on CustomException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    }
  }

  @override
  Future<WebSocketChannel> disconnect() async {
    try {
      WebSocketChannel channel = await _remoteDataSource.disconnect();
      return channel;
    } on CustomException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode ?? 500,
      );
    }
  }
}
