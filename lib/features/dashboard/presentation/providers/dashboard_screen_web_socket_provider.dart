import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/di/injection_container.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/models/dashboard_model.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/usecases/dashboard_usecase.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final dashboardWebSocketScreenProvider = StateNotifierProvider<DashboardWebSocketNotifier, DashboardState>(
  (ref) => DashboardWebSocketNotifier(
    dashboardWebSocketUseCase: sl(),
  ),
);

class DashboardWebSocketNotifier extends StateNotifier<DashboardState> {
  final DashboardWebSocketUseCase _dashboardWebSocketUseCase;

  DashboardWebSocketNotifier({
    required DashboardWebSocketUseCase dashboardWebSocketUseCase,
  })  : _dashboardWebSocketUseCase = dashboardWebSocketUseCase,
        super(DashboardState.initial());

  Future<WebSocketChannel> sendWebSocketMessage(String content) async {
    final params = ChatParams(content: content);
    final results = await _dashboardWebSocketUseCase(params);

    return results.fold(
      (failure) {
        debugPrint("Error: $failure");
        state = DashboardState(isLoading: false, message: failure.message);
        return WebSocketChannel.connect(Uri.parse(''));
      },
      (response) {
        return response;
      },
    );
  }
}

class DashboardState {
  final bool isLoading;
  final String? message;
  final ChatResponseModel? dashboardModel;

  DashboardState({
    required this.isLoading,
    this.message,
    this.dashboardModel,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? message,
    ChatResponseModel? dashboardModel,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      dashboardModel: dashboardModel ?? this.dashboardModel,
    );
  }

  factory DashboardState.initial() {
    return DashboardState(
      isLoading: false,
      message: '',
      dashboardModel: null,
    );
  }
}
