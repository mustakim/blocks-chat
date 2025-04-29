import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/common/presentation/providers/form_provider.dart';
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
  final WebSocketChannel channel = IOWebSocketChannel.connect(
    Uri.parse(dotenv.get('SELISE_CLOUD_WS_CHAT_URL')),
    headers: {
      'Sec-WebSocket-Protocol': dotenv.get('SELISE_CLOUD_AUTH_KEY'),
    },
  );

  bool _isConnected = false;
  bool _isStreaming = false;
  String _currentStreamingResponse = "";

  String chatResponse = '';

  final chatFormGroup = FormGroup({
    'messageController': FormControl<String>(
      value: '',
    ),
  });

  @override
  void initState() {
    super.initState();

    _connectWebSocket();

    Future.microtask(() {
      ref.read(formProvider.notifier).setFormGroup(chatFormGroup);
    });
  }

  void _connectWebSocket() {
    try {
      channel!.stream.listen(_handleWebSocketMessage, onDone: _onWebSocketDone, onError: _onWebSocketError);
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    final data = message?.toString() ?? "";

    if (data == 'end_of_stream') {
      setState(() {
        _isStreaming = false;
        _messages.add(
          ChatMessage(
            text: _currentStreamingResponse,
            isUser: false,
          ),
        );
        _currentStreamingResponse = "";
      });
      _scrollToBottom();
    } else if (data != "" && data != "\"" && data.contains('{"data"') == false) {
      setState(() {
        _currentStreamingResponse = data;
        _isStreaming = true;
      });
      _scrollToBottom();
    }
  }

  void _onWebSocketDone() {
    setState(() {
      _isConnected = false;
    });
    print('WebSocket connection closed');
  }

  void _onWebSocketError(error) {
    setState(() {
      _isConnected = false;
    });
    print('WebSocket error: $error');
  }

  void _sendMessage() {
    if (ref.watch(formProvider).formValues['messageController'].toString().trim().isEmpty) {
      return;
    }

    final userMessage = chatFormGroup.control('messageController').value.toString().trim();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
        ),
      );
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
            child: _messages.isEmpty && _currentStreamingResponse.isEmpty
                ? _buildWelcomeScreen()
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._messages,
                      if (_isStreaming)
                        ChatMessage(
                          text: _currentStreamingResponse,
                          isUser: false,
                          isStreaming: true,
                        ),
                    ],
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
                        hintText: _isConnected ? 'Message ChatGPT...' : 'Connecting...',
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
                      // enabled: _isConnected,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _isConnected ? _sendMessage() : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _isConnected ? Colors.green[700] : Colors.grey,
                    child: IconButton(
                      icon: _isStreaming
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isConnected && !_isStreaming ? _sendMessage : null,
                    ),
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
  final bool isStreaming;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    this.isStreaming = false,
  }) : super(key: key);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
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
                  if (isStreaming && !isUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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
