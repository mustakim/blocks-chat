import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/common/presentation/providers/form_provider.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/presentation/providers/dashboard_screen_provider.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/presentation/providers/dashboard_screen_web_socket_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SendWebSocketMessageButton extends ConsumerWidget {
  // callback function
  final void Function() onSendMessage;
  final WebSocketChannel channel;

  const SendWebSocketMessageButton({
    required this.channel,
    required this.onSendMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final localizationsContext = AppLocalizations.of(context)!;

    return CircleAvatar(
      backgroundColor: Colors.green[700],
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: () async {
          //
          final message = ref.watch(formProvider).formValues['messageController'];

          if (message.toString().trim().isNotEmpty) {
            channel.sink.add(message.toString().trim());
            // message.clear();
          }
          // final result = await ref.read(formProvider.notifier).submitForm<String>(() async {
          //   return ref.read(dashboardWebSocketScreenProvider.notifier).sendWebSocketMessage(
          //         message.toString().trim(),
          //       );
          // });
          // if (result.isNotEmpty) {
          onSendMessage();
          //   // Navigate to Dashboard Screen on successful login
          //   // AppRouter.instance.navigation.goNamed(AppRoutes.dashboard.name);
          // } else {
          //   // Show SnackBar if login fails
          //   if (context.mounted) {
          //     // ScaffoldMessenger.of(context).showSnackBar(
          //     //   SnackBar(
          //     //     content: Text(
          //     //       ref.watch(loginProvider).message ?? localizationsContext.loginFailed,
          //     //       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          //     //             color: Theme.of(context).colorScheme.onError,
          //     //           ),
          //     //     ),
          //     //     backgroundColor: Theme.of(context).colorScheme.error,
          //     //   ),
          //     // );
          //   }
          // }
        },
      ),
    );

    // return SizedBox(
    //   height: 40,
    //   child: AppElevatedButton(
    //     isDisable: !ref.watch(formProvider).isValid ||
    //         ref.watch(loginProvider).isLoading ||
    //         ref.watch(formProvider).isSubmissionInProgress,
    //     isLoading: ref.watch(formProvider).isSubmissionInProgress,
    //     title: AppLocalizations.of(context)!.login,
    //     backgroundColor: Theme.of(context).colorScheme.primary,
    //     foregroundColor: Theme.of(context).colorScheme.onPrimary,
    //     isUppercase: false,
    //     disabledBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
    //     disabledTextColor: Theme.of(context).colorScheme.onPrimaryContainer,
    //     onPressed: () async {
    //       final email = ref.watch(formProvider).formValues['emailController'];
    //       final password = ref.watch(formProvider).formValues['passwordController'];
    //       final result = await ref.read(formProvider.notifier).submitForm<bool>(() async {
    //         return ref.read(loginProvider.notifier).login(
    //               email.toString().trim(),
    //               password.toString().trim(),
    //             );
    //       });
    //       if (result) {
    //         // Navigate to Dashboard Screen on successful login
    //         AppRouter.instance.navigation.goNamed(AppRoutes.dashboard.name);
    //       } else {
    //         // Show SnackBar if login fails
    //         if (context.mounted) {
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               content: Text(
    //                 ref.watch(loginProvider).message ?? localizationsContext.loginFailed,
    //                 style: Theme.of(context).textTheme.bodyMedium!.copyWith(
    //                       color: Theme.of(context).colorScheme.onError,
    //                     ),
    //               ),
    //               backgroundColor: Theme.of(context).colorScheme.error,
    //             ),
    //           );
    //         }
    //       }
    //     },
    //   ),
    // );
  }
}
