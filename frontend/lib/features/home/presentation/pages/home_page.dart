import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/pages/chats_page.dart';
import '../../../jobs/presentation/pages/jobs_page.dart';
import '../../../network/presentation/pages/network_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../data/models/post_model.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/post_creator_card.dart';
import '../widgets/profile_card.dart';
import '../widgets/right_sidebar.dart';
import '../widgets/top_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;

  static const _mockPosts = [
    PostModel(
      id: '1',
      authorName: 'Roberto Castillo',
      authorTitle: 'Jefe UTP - Liceo Técnico Cardenal José María Caro',
      authorBadge: 'STAFF',
      timeAgo: 'Hace 3 horas',
      content:
          '🎉 FERIA DE PRÁCTICAS 2026 🎉\n\n'
          'El próximo viernes 28 de marzo realizaremos nuestra tradicional Feria de '
          'Prácticas Profesionales. Más de 20 empresas estarán presentes buscando '
          'estudiantes de 4° medio para sus programas de práctica.\n\n'
          '¡No falten! Es una gran oportunidad para conectar con empresas y asegurar tu '
          'práctica profesional.',
      type: PostType.event,
      eventDate: '28 DE MARZO, 9:00 HRS',
      details: ['📍 Gimnasio del Liceo', '🕐 9:00 - 14:00 hrs'],
    ),
  ];

  Widget get _currentPage => switch (_selectedNavIndex) {
        1 => const JobsPage(),
        2 => const NetworkPage(),
        3 => const ChatsPage(),
        4 => const ProfilePage(),
        _ => _FeedView(posts: _mockPosts),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavBar(
        selectedIndex: _selectedNavIndex,
        onNavItemTapped: (i) => setState(() => _selectedNavIndex = i),
      ),
      body: _currentPage,
    );
  }
}

class _FeedView extends StatelessWidget {
  final List<PostModel> posts;

  const _FeedView({required this.posts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 260,
                  child: ProfileCard(
                    name: 'Matías Silva',
                    subtitle: 'Estudiante de Mecatrónica - 4° Medio',
                    connections: 45,
                    views: 89,
                    inDemandSkills: const [
                      'Soldadura',
                      'PLC',
                      'AutoCAD',
                      'Mantenimiento',
                      'CNC',
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const PostCreatorCard(),
                      const SizedBox(height: 12),
                      ...posts.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FeedPostCard(post: p),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const SizedBox(width: 260, child: RightSidebar()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
