import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/kairos_palette.dart';
import '../widgets/k_card.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late ChatPreview _selected;
  final List<ChatMessage> _thread = List<ChatMessage>.from(sampleConversation);

  @override
  void initState() {
    super.initState();
    _selected = chatPreviews.first;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 1000;
    final query = _searchController.text.trim().toLowerCase();

    final conversations = chatPreviews.where((chat) {
      if (query.isEmpty) {
        return true;
      }
      return chat.user.name.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query) ||
          chat.user.title.toLowerCase().contains(query);
    }).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mensajes', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Mantente en contacto con tu red profesional.'),
          const SizedBox(height: 16),
          Expanded(
            child: KCard(
              padding: EdgeInsets.zero,
              child: mobile
                  ? Column(
                      children: [
                        _conversationList(conversations, compact: true),
                        const Divider(height: 1),
                        Expanded(child: _chatPanel()),
                      ],
                    )
                  : Row(
                      children: [
                        SizedBox(width: 340, child: _conversationList(conversations)),
                        const VerticalDivider(width: 1),
                        Expanded(child: _chatPanel()),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationList(List<ChatPreview> conversations, {bool compact = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0x140F766E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(17),
              topRight: Radius.circular(17),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Buscar mensajes...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final chat = conversations[index];
              final selected = chat.id == _selected.id;
              return InkWell(
                onTap: () => setState(() => _selected = chat),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0x120F766E) : null,
                    border: const Border(bottom: BorderSide(color: KairosPalette.border)),
                    borderRadius: selected && compact ? BorderRadius.circular(12) : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(chat.user.avatarUrl)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.user.name,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(chat.timestamp, style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chat.user.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: KairosPalette.secondary, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: KairosPalette.foreground),
                            ),
                          ],
                        ),
                      ),
                      if (chat.unread)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(color: KairosPalette.accent, shape: BoxShape.circle),
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

  Widget _chatPanel() {
    return Column(
      children: [
        Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0x140F766E),
            border: Border(bottom: BorderSide(color: KairosPalette.border)),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(_selected.user.avatarUrl)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selected.user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(_selected.user.title, style: const TextStyle(color: KairosPalette.secondary)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: _thread.length,
            itemBuilder: (context, index) {
              final msg = _thread[index];
              return Align(
                alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 480),
                  decoration: BoxDecoration(
                    color: msg.isMine ? KairosPalette.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: msg.isMine ? null : Border.all(color: KairosPalette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(color: msg.isMine ? Colors.white : KairosPalette.foreground),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.timestamp,
                        style: TextStyle(
                          fontSize: 11,
                          color: msg.isMine ? Colors.white70 : KairosPalette.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: KairosPalette.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: KairosPalette.accent),
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _thread.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          timestamp: 'Ahora',
          isMine: true,
        ),
      );
      _inputController.clear();
    });
  }
}
