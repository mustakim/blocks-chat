import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/auth/domain/utils/utils.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/common/domain/models/conversation_mock_data.dart';
import 'package:l3_flutter_selise_blocksconstruct/theme/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  final GlobalKey<ScaffoldState>? _scaffoldKey;
  static const double _minTileHeight = 54;
  static const double _gap = 24;

  const AppDrawer(this._scaffoldKey, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeMode = ref.watch(themeProvider);

    final conversations = Utils.groupConversations(conversationMockData);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EagleGPT',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      _scaffoldKey?.currentState?.closeDrawer();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: conversations.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  minTileHeight: _minTileHeight,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      conversations[index]['label'],
                      style: const TextStyle(
                        color: Color(0xFF959595),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < conversations[index]['items']?.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    conversations[index]['items']?[i]['ConversationTitle'] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
