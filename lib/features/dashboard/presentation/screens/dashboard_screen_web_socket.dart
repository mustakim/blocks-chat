import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/common/presentation/providers/form_provider.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/presentation/widgets/send_web_socket_message_button_widget.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_markdown/flutter_markdown.dart';

class DashboardScreenWebSocket extends ConsumerStatefulWidget {
  const DashboardScreenWebSocket({super.key});

  @override
  ConsumerState<DashboardScreenWebSocket> createState() => _DashboardScreenWebSocketState();
}

class _DashboardScreenWebSocketState extends ConsumerState<DashboardScreenWebSocket> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // final WebSocketChannel channel = IOWebSocketChannel.connect(Uri.parse(dotenv.get('TEST_WS_URL')));

  final WebSocketChannel channel = IOWebSocketChannel.connect(
    Uri.parse(dotenv.get('SELISE_CLOUD_WS_CHAT_URL')),
    headers: {
      'Sec-WebSocket-Protocol': dotenv.get('SELISE_CLOUD_AUTH_KEY'),
    },
  );
  String chatResponse = '';

  final chatFormGroup = FormGroup({
    'messageController': FormControl<String>(
      value: '',
    ),
  });

  @override
  void initState() {
    super.initState();

    initChannel();

    Future.microtask(() {
      ref.read(formProvider.notifier).setFormGroup(chatFormGroup);
    });
  }

  void initChannel() async {
    await channel.ready;
  }

  void _sendMessage() {
    if (ref.watch(formProvider).formValues['messageController'].toString().trim().isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: ref.watch(formProvider).formValues['messageController'].toString().trim(),
          isUser: true,
        ),
      );
      // clear messageController value
      chatFormGroup.control('messageController').value = '';
    });

    var message = {
      "question": ref.watch(formProvider).formValues['messageController'].toString().trim(),
      "conversation": [],
      "file_ids": [],
      "filter_key_value_pair": [
        {"key": "topic_id", "value": "b37267f6-ffc6-4def-a884-7e3c7af49f25"},
        {"key": "OrganizationId", "value": "1ece8ffd-551b-4fd2-83eb-0eb64f71e8c9"}
      ],
      "model_name": "GPT-4o-mini",
      "is_regenerate": false,
      "conversation_id": "c469d845-54ec-4fb1-9a50-c84dbd4a006b"
    };

    channel.sink.add(jsonEncode(message));

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text: chatResponse,
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Chat history
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.toString() != 'end_of_stream') {
                        chatResponse = snapshot.data.toString();
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _messages[index];
                        },
                      );
                    },
                  ),
          ),
          // Message input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            color: const Color(0xFF444654),
            child: ReactiveForm(
              formGroup: chatFormGroup,
              child: Row(
                children: [
                  Expanded(
                    child: ReactiveTextField(
                      formControlName: 'messageController',
                      decoration: InputDecoration(
                        hintText: 'Ask anything',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF40414F),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      // onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SendWebSocketMessageButton(
                    channel: channel!,
                    onSendMessage: () {
                      _sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          const Text(
            'What can i help with?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Ask anything, get your answer instantly',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  void dispose() {
    chatFormGroup.dispose();
    channel.sink.close(status.goingAway);
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[700] : const Color(0xFF444654),
                borderRadius: BorderRadius.circular(18),
              ),
              // child: Text(
              //   text,
              //   style: const TextStyle(color: Colors.white, fontSize: 16),
              // ),
              child: MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white, fontSize: 16),
                  h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  h2: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  h3: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  em: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                  strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  code: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.grey[800],
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockquote: const TextStyle(color: Colors.grey),
                  listBullet: const TextStyle(color: Colors.white),
                ),
                softLineBreak: true,
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? Colors.blue : Colors.green,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
