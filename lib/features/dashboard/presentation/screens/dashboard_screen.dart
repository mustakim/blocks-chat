import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/common/presentation/providers/form_provider.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/common/presentation/widgets/text_input_form_field_widget.dart';
import 'package:l3_flutter_selise_blocksconstruct/features/dashboard/presentation/widgets/send_message_button_widget.dart';
import 'package:reactive_forms/reactive_forms.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  final chatFormGroup = FormGroup({
    'messageController': FormControl<String>(
      value: '',
    ),
  });

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(formProvider.notifier).setFormGroup(chatFormGroup);
    });
  }

  void _sendMessage(String message) {
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

    // Simulate AI response after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text: message,
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
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _messages[index];
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
                  SendMessageButton(
                    onSendMessage: (message) {
                      _sendMessage(message);
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
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
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
