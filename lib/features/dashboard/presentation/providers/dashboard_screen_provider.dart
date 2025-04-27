import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/di/injection_container.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/models/dashboard_model.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/domain/usecases/dashboard_usecase.dart';

final dashboardScreenProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(
    dashboardUseCase: sl(),
  ),
);

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardUseCase _dashboardUseCase;

  DashboardNotifier({
    required DashboardUseCase dashboardUseCase,
  })  : _dashboardUseCase = dashboardUseCase,
        super(DashboardState.initial());

  Future<String> sendChatMessage(String content) async {
    final params = ChatParams(content: content);
    final results = await _dashboardUseCase(params);

    return results.fold(
      (failure) {
        debugPrint("Error: $failure");
        state = DashboardState(isLoading: false, message: failure.message);
        return "Error sending chat message: ${failure.message}";
      },
      (response) {
        state = DashboardState(isLoading: false, dashboardModel: response);
        final chatResponse = response.choices[0].message['content'];
        return chatResponse;
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
