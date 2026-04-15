import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/chat_hub_service.dart';
import '../../../../core/theme/kairos_palette.dart';
import '../../../../core/widgets/k_card.dart';
import '../../data/models/chat_model.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key, required this.currentUser});

  final UserProfile currentUser;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final _api = ApiClient();
  List<ChatPreview> _conversations = [];
  bool _loadingConversations = true;
  bool _loadingThread = false;

  ChatPreview? _selected;
  final List<ChatMessage> _thread = [];

  // ── SignalR ────────────────────────────────────────────────────────────────
  final _hub = ChatHubService();
  StreamSubscription<dynamic>? _msgSub;
  StreamSubscription<dynamic>? _typingSub;

  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final data = await _api.getConversations();
      final conversations = data.cast<Map<String, dynamic>>().map((json) {
        final lastAt = DateTime.tryParse(json['lastMessageAt'] as String? ?? '');
        String ts = '';
        if (lastAt != null) {
          final diff = DateTime.now().toUtc().difference(lastAt.toUtc());
          if (diff.inMinutes < 60) {
            ts = 'Hace ${diff.inMinutes} min';
          } else if (diff.inHours < 24) {
            ts = 'Hace ${diff.inHours} h';
          } else {
            ts = 'Hace ${diff.inDays} días';
          }
        }
        final user = UserProfile(
          id: json['otherUserId'].toString(),
          name: json['otherUserName'] as String? ?? 'Usuario',
          role: UserRole.student,
          title: json['otherUserTitle'] as String? ?? '',
          avatarUrl: json['otherUserAvatarUrl'] as String? ?? '',
          skills: const [],
          bio: '',
          location: '',
          connections: 0,
        );
        return ChatPreview(
          id: json['otherUserId'].toString(),
          user: user,
          lastMessage: json['lastMessage'] as String? ?? '',
          timestamp: ts,
          unread: json['hasUnread'] as bool? ?? false,
        );
      }).toList();

      if (mounted) {
        setState(() => _conversations = conversations);
        if (conversations.isNotEmpty && _selected == null) {
          await _selectConversation(conversations.first);
        }
      }
    } catch (_) {
      // Fall back to mock data
      if (mounted) {
        setState(() => _conversations = chatPreviews);
        if (chatPreviews.isNotEmpty && _selected == null) {
          _selected = chatPreviews.first;
          _thread
            ..clear()
            ..addAll(sampleConversation);
          _initHub();
        }
      }
    } finally {
      if (mounted) setState(() => _loadingConversations = false);
    }
  }

  Future<void> _loadThread(String otherUserId) async {
    final otherId = int.tryParse(otherUserId);
    if (otherId == null) {
      // Mock fallback
      setState(() {
        _thread
          ..clear()
          ..addAll(sampleConversation);
      });
      return;
    }

    setState(() => _loadingThread = true);
    try {
      final data = await _api.getMessages(otherId);
      final messages = data.cast<Map<String, dynamic>>().map((json) {
        final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
        final ts = createdAt != null
            ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
            : '';
        final senderId = json['senderId'].toString();
        final isMine = senderId == widget.currentUser.id;
        return ChatMessage(
          id: json['id'].toString(),
          text: json['content'] as String? ?? '',
          timestamp: ts,
          isMine: isMine,
          senderId: senderId,
        );
      }).toList();
      if (mounted) {
        setState(() {
          _thread
            ..clear()
            ..addAll(messages);
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _thread
            ..clear()
            ..addAll(sampleConversation);
        });
      }
    } finally {
      if (mounted) setState(() => _loadingThread = false);
    }
  }

  Future<void> _initHub() async {
    final selected = _selected;
    if (selected == null) return;

    final token = await _api.getToken();
    await _hub.connect(token: token);
    if (!mounted) return;

    // Join initial conversation group
    await _hub.joinConversation(widget.currentUser.id, selected.user.id);

    // Listen for incoming messages
    _msgSub = _hub.onMessage.listen((msg) {
      if (!mounted) return;
      setState(() {
        _thread.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: msg.content,
            timestamp: msg.timestamp,
            isMine: msg.senderId == widget.currentUser.id,
            senderId: msg.senderId,
          ),
        );
      });
      _scrollToBottom();
    });

    // Listen for typing indicator
    _typingSub = _hub.onTyping.listen((senderId) {
      if (!mounted || senderId == widget.currentUser.id) return;
      _typingTimer?.cancel();
      setState(() => _isTyping = true);
      _typingTimer = Timer(
        const Duration(seconds: 3),
        () => setState(() => _isTyping = false),
      );
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _typingTimer?.cancel();
    final selected = _selected;
    if (selected != null) {
      _hub.leaveConversation(widget.currentUser.id, selected.user.id);
    }
    _hub.dispose();
    _inputController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Conversation switch ────────────────────────────────────────────────────

  Future<void> _selectConversation(ChatPreview chat) async {
    final current = _selected;
    if (current?.id == chat.id) return;

    // Leave old group, join new group
    if (current != null && _hub.isConnected) {
      await _hub.leaveConversation(widget.currentUser.id, current.user.id);
    }

    setState(() {
      _selected = chat;
      _isTyping = false;
      _thread.clear();
    });

    // Load messages from API
    await _loadThread(chat.user.id);

    // Join new SignalR group
    if (!_hub.isConnected) {
      await _initHub();
    } else {
      await _hub.joinConversation(widget.currentUser.id, chat.user.id);
    }
  }

  // ── Send message ───────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final selected = _selected;
    if (selected == null) return;

    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();

    // Optimistically add message to UI
    final optimistic = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: _timeNow(),
      isMine: true,
      senderId: widget.currentUser.id,
    );
    setState(() => _thread.add(optimistic));
    _scrollToBottom();

    final receiverId = int.tryParse(selected.user.id);

    if (receiverId != null) {
      // Persist via REST API
      try {
        await _api.sendMessage(receiverId, text);
      } catch (_) {
        // Message was already shown optimistically — keep it
      }
    }

    // Also send via SignalR for real-time delivery to other party
    if (_hub.isConnected) {
      await _hub.sendMessage(widget.currentUser.id, selected.user.id, text);
    }
  }

  // ── Typing notification ────────────────────────────────────────────────────

  void _onInputChanged(String _) {
    final selected = _selected;
    if (_hub.isConnected && selected != null) {
      _hub.sendTyping(widget.currentUser.id, selected.user.id);
    }
    setState(() {}); // rebuild search results if needed
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 1000;
    final pagePadding = mobile
        ? const EdgeInsets.fromLTRB(14, 14, 14, 12)
        : const EdgeInsets.all(20);
    final conversationHeight = (MediaQuery.sizeOf(context).height * 0.27)
        .clamp(180.0, 230.0)
        .toDouble();
    final query = _searchController.text.trim().toLowerCase();

    final allConvs = _conversations.isNotEmpty ? _conversations : chatPreviews;
    final conversations = allConvs
        .where((chat) {
          if (query.isEmpty) return true;
          return chat.user.name.toLowerCase().contains(query) ||
              chat.lastMessage.toLowerCase().contains(query) ||
              chat.user.title.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mensajes',
            style: TextStyle(
              fontSize: mobile ? 26 : 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          if (mobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mantente en contacto con tu red profesional.'),
                if (_hub.isConnected) ...[
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 10),
                      SizedBox(width: 4),
                      Text('En linea', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ],
            )
          else
            Row(
              children: [
                const Text('Mantente en contacto con tu red profesional.'),
                const Spacer(),
                if (_hub.isConnected)
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 10),
                      SizedBox(width: 4),
                      Text('En linea', style: TextStyle(fontSize: 12)),
                    ],
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: KCard(
              padding: EdgeInsets.zero,
              child: mobile
                  ? Column(
                      children: [
                        SizedBox(
                          height: conversationHeight,
                          child: _conversationList(
                            conversations,
                            compact: true,
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(child: _chatPanel()),
                      ],
                    )
                  : Row(
                      children: [
                        SizedBox(
                          width: 340,
                          child: _conversationList(conversations),
                        ),
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

  // ── Conversation list ──────────────────────────────────────────────────────

  Widget _conversationList(
    List<ChatPreview> conversations, {
    bool compact = false,
  }) {
    return Column(
      children: [
        Container(
          padding: compact
              ? const EdgeInsets.fromLTRB(12, 10, 12, 10)
              : const EdgeInsets.all(14),
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
              final selected = chat.id == _selected?.id;
              return InkWell(
                onTap: () => _selectConversation(chat),
                child: Container(
                  padding: compact
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                      : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0x120F766E) : null,
                    border: const Border(
                      bottom: BorderSide(color: KairosPalette.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: chat.user.avatarUrl.trim().isNotEmpty
                            ? NetworkImage(chat.user.avatarUrl)
                            : null,
                        child: chat.user.avatarUrl.trim().isEmpty
                            ? const Icon(Icons.person_rounded)
                            : null,
                      ),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  chat.timestamp,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chat.user.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: KairosPalette.secondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: KairosPalette.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (chat.unread)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: KairosPalette.accent,
                            shape: BoxShape.circle,
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

  // ── Chat panel ─────────────────────────────────────────────────────────────

  Widget _chatPanel() {
    final mobile = MediaQuery.sizeOf(context).width < 1000;
    final selected = _selected;

    if (selected == null) {
      return const Center(
        child: Text(
          'No hay conversaciones disponibles por ahora.',
          style: TextStyle(color: KairosPalette.secondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          height: mobile ? 70 : 76,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0x140F766E),
            border: Border(bottom: BorderSide(color: KairosPalette.border)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: selected.user.avatarUrl.trim().isNotEmpty
                    ? NetworkImage(selected.user.avatarUrl)
                    : null,
                child: selected.user.avatarUrl.trim().isEmpty
                    ? const Icon(Icons.person_rounded)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      selected.user.title,
                      style: const TextStyle(color: KairosPalette.secondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: _loadingThread
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(14),
            itemCount: _thread.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              // Typing indicator as last item
              if (_isTyping && index == _thread.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: KairosPalette.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${selected.user.name} esta escribiendo',
                          style: const TextStyle(
                            color: KairosPalette.secondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: KairosPalette.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final msg = _thread[index];
              return Align(
                alignment: msg.isMine
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: mobile
                        ? MediaQuery.sizeOf(context).width * 0.72
                        : 480,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isMine ? KairosPalette.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: msg.isMine
                        ? null
                        : Border.all(color: KairosPalette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isMine
                              ? Colors.white
                              : KairosPalette.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.timestamp,
                        style: TextStyle(
                          fontSize: 11,
                          color: msg.isMine
                              ? Colors.white70
                              : KairosPalette.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Input bar
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
                  onChanged: _onInputChanged,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un mensaje...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (mobile)
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: KairosPalette.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded, size: 18),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KairosPalette.accent,
                  ),
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
}
