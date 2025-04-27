import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/app/bootstrapper_app.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/app/chat_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BootstrapperApp().init();

  runApp(
    ProviderScope(
      child: ChatApp(),
    ),
  );
}
