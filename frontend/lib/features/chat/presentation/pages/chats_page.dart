import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/chat_model.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  String? _selectedChatId;

  static const _mockChats = [
    ChatModel(
      id: '1',
      participantName: 'Metalmecánica del Sur',
      participantTitle: 'Empresa · Santiago',
      lastMessage: 'Hola Matías, nos interesa tu perfil para la práctica.',
      time: '10:32',
      unreadCount: 2,
    ),
    ChatModel(
      id: '2',
      participantName: 'Instalaciones Eléctricas López',
      participantTitle: 'Empresa · Lo Espejo',
      lastMessage: '¿Podrías enviar tu CV actualizado?',
      time: 'Ayer',
      unreadCount: 0,
    ),
    ChatModel(
      id: '3',
      participantName: 'Roberto Castillo',
      participantTitle: 'Jefe UTP · Liceo Técnico',
      lastMessage: 'Recuerda asistir a la feria de prácticas el viernes.',
      time: 'Lun',
      unreadCount: 1,
    ),
  ];

  static final _mockMessages = <String, List<MessageModel>>{
    '1': [
      const MessageModel(
        id: 'm1',
        text: 'Buenos días, vi su oferta de práctica en Kairos.',
        isMine: true,
        time: '10:20',
      ),
      const MessageModel(
        id: 'm2',
        text: 'Hola Matías, nos interesa tu perfil para la práctica. ¿Tienes disponibilidad para una entrevista esta semana?',
        isMine: false,
        time: '10:32',
      ),
    ],
    '2': [
      const MessageModel(
        id: 'm3',
        text: 'Hola, me interesa postular a la práctica de electricidad.',
        isMine: true,
        time: 'Ayer 14:10',
      ),
      const MessageModel(
        id: 'm4',
        text: '¿Podrías enviar tu CV actualizado?',
        isMine: false,
        time: 'Ayer 15:22',
      ),
    ],
    '3': [
      const MessageModel(
        id: 'm5',
        text: 'Recuerda asistir a la feria de prácticas el viernes.',
        isMine: false,
        time: 'Lun 09:00',
      ),
    ],
  };

  ChatModel? get _selectedChat =>
      _selectedChatId == null
          ? null
          : _mockChats.where((c) => c.id == _selectedChatId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  // Chat list panel
                  SizedBox(
                    width: 320,
                    child: _ChatListPanel(
                      chats: _mockChats,
                      selectedId: _selectedChatId,
                      onSelect: (id) => setState(() => _selectedChatId = id),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.divider),
                  // Message panel
                  Expanded(
                    child: _selectedChat == null
                        ? const _EmptyState()
                        : _MessagePanel(
                            chat: _selectedChat!,
                            messages: _mockMessages[_selectedChatId] ?? [],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatListPanel extends StatelessWidget {
  final List<ChatModel> chats;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _ChatListPanel({
    required this.chats,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Mensajes',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar conversación...',
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (_, i) {
              final chat = chats[i];
              final isSelected = chat.id == selectedId;
              return GestureDetector(
                onTap: () => onSelect(chat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  color: isSelected
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        child: Icon(
                          Icons.business,
                          size: 20,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  chat.participantName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: chat.unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  chat.time,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: chat.unreadCount > 0
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.lastMessage,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: chat.unreadCount > 0
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                      fontWeight: chat.unreadCount > 0
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (chat.unreadCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${chat.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MessagePanel extends StatefulWidget {
  final ChatModel chat;
  final List<MessageModel> messages;

  const _MessagePanel({required this.chat, required this.messages});

  @override
  State<_MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<_MessagePanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late List<MessageModel> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.messages);
  }

  @override
  void didUpdateWidget(_MessagePanel old) {
    super.didUpdateWidget(old);
    if (old.chat.id != widget.chat.id) {
      _messages = List.of(widget.messages);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isMine: true,
        time: 'Ahora',
      ));
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.business, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.participantName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.chat.participantTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _MessageBubble(message: _messages[i]),
          ),
        ),
        // Input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMine ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 13,
                color: message.isMine ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 10,
                color: message.isMine
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.divider),
          SizedBox(height: 12),
          Text(
            'Selecciona una conversación',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
